const express = require('express');
const pool = require('../db');
const { authMiddleware } = require('./auth');
const os = require('os');
const router = express.Router();

function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

function getDateFilter(range) {
  switch (range) {
    case 'today':
      return "record_date = CURDATE()";
    case '7d':
      return "record_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
    case '30d':
      return "record_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)";
    case 'all':
    default:
      return "1=1";
  }
}

function getVisitDateFilter(range) {
  switch (range) {
    case 'today':
      return "DATE(visit_time) = CURDATE()";
    case '7d':
      return "visit_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
    case '30d':
      return "visit_time >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)";
    case 'all':
    default:
      return "1=1";
  }
}

router.get('/network-info', authMiddleware, (req, res) => {
  const ip = getLocalIP();
  res.json({ data: { ip } });
});

router.post('/record', async (req, res) => {
  try {
    const { deviceId } = req.body;
    const today = new Date().toISOString().split('T')[0];

    const [existingRows] = await pool.query('SELECT * FROM analytics WHERE record_date = ?', [today]);

    if (existingRows.length === 0) {
      await pool.query(
        'INSERT INTO analytics (record_date, page_views, unique_visitors) VALUES (?, 1, 1)',
        [today]
      );
    } else {
      await pool.query(
        'UPDATE analytics SET page_views = page_views + 1 WHERE record_date = ?',
        [today]
      );
      if (deviceId) {
        await pool.query(
          'UPDATE analytics SET unique_visitors = unique_visitors + 1 WHERE record_date = ?',
          [today]
        );
      }
    }

    res.json({ message: '访问记录成功' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: '记录访问失败' });
  }
});

router.post('/stay-duration', async (req, res) => {
  try {
    let body = req.body;
    // 处理 sendBeacon 发送的 text/plain 格式数据
    if (typeof body === 'string') {
      try {
        body = JSON.parse(body);
      } catch (e) {
        return res.status(400).json({ message: '无效的 JSON 格式' });
      }
    }

    const { sessionId, stayDuration } = body;
    if (!sessionId || stayDuration === undefined) {
      return res.status(400).json({ message: '参数不完整' });
    }
    await pool.query(
      'INSERT INTO visit_logs (session_id, stay_duration) VALUES (?, ?)',
      [sessionId, Math.round(stayDuration)]
    );
    res.json({ message: '停留时长记录成功' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: '记录停留时长失败' });
  }
});

router.get('/summary', authMiddleware, async (req, res) => {
  try {
    const range = req.query.range || 'all';
    const dateFilter = getDateFilter(range);

    const [rows] = await pool.query(`
      SELECT
        COALESCE(SUM(page_views), 0) as total_pv,
        COALESCE(SUM(unique_visitors), 0) as total_uv,
        COALESCE(ROUND(AVG(avg_stay_time)), 0) as avg_stay
      FROM analytics
      WHERE ${dateFilter}
    `);

    const visitFilter = getVisitDateFilter(range);
    const [visitRows] = await pool.query(`
      SELECT COALESCE(ROUND(AVG(stay_duration)), 0) as avg_stay_real
      FROM visit_logs
      WHERE ${visitFilter}
    `);

    const data = rows[0] || {};
    if (visitRows[0] && visitRows[0].avg_stay_real) {
      data.avg_stay = visitRows[0].avg_stay_real;
    }

    res.json({ data });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: '获取数据摘要失败' });
  }
});

router.get('/weekly', authMiddleware, async (req, res) => {
  try {
    const range = req.query.range || '7d';
    const dateFilter = getDateFilter(range);

    const [rows] = await pool.query(`
      SELECT DATE_FORMAT(record_date, '%Y-%m-%d') as date, page_views, unique_visitors, avg_stay_time
      FROM analytics
      WHERE ${dateFilter}
      ORDER BY record_date ASC
    `);
    res.json({ data: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: '获取数据分析失败' });
  }
});

router.get('/duration-distribution', authMiddleware, async (req, res) => {
  try {
    const range = req.query.range || 'all';
    const visitFilter = getVisitDateFilter(range);

    const [rows] = await pool.query(`
      SELECT
        SUM(CASE WHEN stay_duration < 10 THEN 1 ELSE 0 END) as lt10s,
        SUM(CASE WHEN stay_duration >= 10 AND stay_duration < 60 THEN 1 ELSE 0 END) as s10to60,
        SUM(CASE WHEN stay_duration >= 60 AND stay_duration < 300 THEN 1 ELSE 0 END) as s60to300,
        SUM(CASE WHEN stay_duration >= 300 AND stay_duration < 600 THEN 1 ELSE 0 END) as s300to600,
        SUM(CASE WHEN stay_duration >= 600 THEN 1 ELSE 0 END) as gt600
      FROM visit_logs
      WHERE ${visitFilter}
    `);

    const data = rows[0] || {};
    res.json({ data });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: '获取停留时长分布失败' });
  }
});

module.exports = router;
