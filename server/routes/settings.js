const express = require('express');
const pool = require('../db');
const { authMiddleware } = require('./auth');
const { updateSettings } = require('../utils/settingsCache');
const router = express.Router();

// 管理员权限验证中间件
const adminMiddleware = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: '权限不足，仅管理员可访问' });
  }
  next();
};

// 1. 获取网站配置 (前台/后台通用)
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM settings LIMIT 1');
    res.json({ data: rows[0] || {} });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

// 2. 更新网站配置 (仅管理员)
router.put('/', authMiddleware, adminMiddleware, async (req, res, next) => {
  try {
    const { title, logo_url, target_url, demo_mode } = req.body;
    await pool.query(
      'UPDATE settings SET title = ?, logo_url = ?, target_url = ?, demo_mode = ?',
      [title, logo_url, target_url, demo_mode ? 1 : 0]
    );
    
    // 更新后，同步更新内存缓存
    updateSettings({ demo_mode: demo_mode ? 1 : 0 });
    
    res.json({ message: '网站配置更新成功' });
  } catch (error) {
    next(error); // 抛给全局错误处理中间件
  }
});

module.exports = router;
