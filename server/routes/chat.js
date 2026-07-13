const express = require('express');
const pool = require('../db');
const { authMiddleware } = require('./auth');
const router = express.Router();

//   获取单个访客的完整聊天记录
router.get('/history/visitor/:sessionId', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const [rows] = await pool.query(
      'SELECT id, session_id, sender_type, sender_name, content, message_type, model_data, created_at, is_read FROM chat_messages WHERE session_id = ? ORDER BY created_at ASC',
      [sessionId]
    );
    rows.forEach(row => {
      if (row.model_data && typeof row.model_data === 'string') {
        try { row.model_data = JSON.parse(row.model_data); } catch(e) { row.model_data = null; }
      }
    });
    res.json({ data: rows });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

//   清除单个访客的聊天记录
router.delete('/history/visitor/:sessionId', async (req, res) => {
  try {
    const { sessionId } = req.params;
    await pool.query('DELETE FROM chat_messages WHERE session_id = ?', [sessionId]);
    res.json({ message: '删除成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

//   账户合并时迁移聊天记录至新账户
router.put('/merge/:oldSessionId/:newSessionId', async (req, res) => {
  try {
    const { oldSessionId, newSessionId } = req.params;
    await pool.query('UPDATE chat_messages SET session_id = ?, sender_name = ? WHERE session_id = ?', [newSessionId, newSessionId, oldSessionId]);
    res.json({ message: '合并成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

//   后台获取所有会话列表 (包含未读消息统计与最新消息)
router.get('/sessions', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT session_id, MAX(created_at) as last_time,
      (SELECT content FROM chat_messages c2 WHERE c2.session_id = c1.session_id ORDER BY created_at DESC LIMIT 1) as last_msg,
      (SELECT sender_name FROM chat_messages c3 WHERE c3.session_id = c1.session_id AND sender_type='visitor' LIMIT 1) as visitor_name,
      SUM(CASE WHEN sender_type = 'visitor' AND is_read = 0 THEN 1 ELSE 0 END) as unread_count
      FROM chat_messages c1
      GROUP BY session_id
      ORDER BY last_time DESC
    `);
    res.json({ data: rows });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

//   将指定会话内的未读消息标记为已读
router.put('/read/:sessionId', authMiddleware, async (req, res) => {
  try {
    const { sessionId } = req.params;
    await pool.query('UPDATE chat_messages SET is_read = 1 WHERE session_id = ? AND sender_type = "visitor"', [sessionId]);
    res.json({ message: '已读状态更新成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

//   获取前台模型展示列表数据用于分享
router.get('/models', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT id, module_key, model_key, module_name, model_name, model_params FROM model_display WHERE model_key IS NOT NULL AND is_enabled = 1 ORDER BY module_key, model_key'
    );
    rows.forEach(row => {
      if (row.model_params && typeof row.model_params === 'string') {
        try { row.model_params = JSON.parse(row.model_params); } catch(e) { row.model_params = null; }
      }
    });
    res.json({ data: rows });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

module.exports = router;