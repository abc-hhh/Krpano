const express = require('express');
const pool = require('../db');
const { authMiddleware } = require('./auth');
const xss = require('xss');
const { actionLimiter } = require('../middlewares/rateLimit');
const router = express.Router();

// 0. 公开接口: 获取已通过的留言列表 (前台展示，支持分页和排序)
router.get('/public', async (req, res) => {
  try {
    const sort = req.query.sort || 'heat';
    const offset = parseInt(req.query.offset) || 0;
    const limit = parseInt(req.query.limit) || 5;

    // 置顶留言
    let pinned = [];
    if (offset === 0) {
      const [pinnedRows] = await pool.query('SELECT * FROM messages WHERE status = 1 AND is_top = 1 ORDER BY created_at DESC');
      pinned = pinnedRows;
    }

    // 普通留言排序
    let orderBy = 'likes DESC, created_at DESC';
    if (sort === 'time') {
      orderBy = 'created_at DESC';
    }

    const [normal] = await pool.query(`SELECT * FROM messages WHERE status = 1 AND is_top = 0 ORDER BY ${orderBy} LIMIT ? OFFSET ?`, [limit, offset]);
    
    // 检查是否还有更多
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM messages WHERE status = 1 AND is_top = 0');
    const total = countResult[0].total;
    const hasMore = (offset + limit) < total;

    res.json({ data: { pinned, normal, hasMore } });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

// 0. 公开接口: 留言点赞/取消点赞
// 使用 actionLimiter 进行限流，防止被恶意刷赞
router.put('/public/:id/like', actionLimiter, async (req, res, next) => {
  try {
    const { id } = req.params;
    const { action } = req.body; // 'like' 或 'unlike'
    
    // 如果是 like，加 1；如果是 unlike，减 1，并且保证 likes 不会小于 0
    if (action === 'unlike') {
      await pool.query('UPDATE messages SET likes = GREATEST(likes - 1, 0) WHERE id = ?', [id]);
      res.json({ message: '取消点赞成功' });
    } else {
      await pool.query('UPDATE messages SET likes = likes + 1 WHERE id = ?', [id]);
      res.json({ message: '点赞成功' });
    }
  } catch (error) {
    next(error); // 抛给全局错误处理中间件
  }
});

// 0. 公开接口: 提交新留言 (前台提交)
// 使用 actionLimiter 防止恶意疯狂发留言
router.post('/public', actionLimiter, async (req, res, next) => {
  try {
    let { nickname, content } = req.body;
    if (!nickname || !content) {
      return res.status(400).json({ message: '昵称和留言内容不能为空' });
    }
    
    // 输入校验与长度截断
    nickname = String(nickname).substring(0, 20);
    content = String(content).substring(0, 200);

    // XSS 防护，过滤掉恶意脚本
    nickname = xss(nickname);
    content = xss(content);

    await pool.query('INSERT INTO messages (nickname, content, status) VALUES (?, ?, 0)', [nickname, content]);
    res.json({ message: '留言提交成功，等待审核' });
  } catch (error) {
    next(error); // 抛给全局错误处理中间件
  }
});

// 1. 获取留言列表 (后台管理，需登录)
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM messages ORDER BY is_top DESC, created_at DESC');
    res.json({ data: rows });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

// 2. 审核留言
router.put('/:id/status', authMiddleware, async (req, res) => {
  try {
    const { status } = req.body; // 1-通过, 2-拒绝
    const { id } = req.params;
    await pool.query('UPDATE messages SET status = ? WHERE id = ?', [status, id]);
    res.json({ message: '状态更新成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

// 3. 回复留言
router.put('/:id/reply', authMiddleware, async (req, res) => {
  try {
    const { reply_content } = req.body;
    const { id } = req.params;
    const replier_role = req.user.role; // admin 或 cs

    await pool.query(
      'UPDATE messages SET reply_content = ?, replier_role = ?, reply_time = NOW() WHERE id = ?',
      [reply_content, replier_role, id]
    );
    res.json({ message: '回复成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

// 4. 置顶/取消置顶留言
router.put('/:id/top', authMiddleware, async (req, res) => {
  try {
    const { is_top } = req.body; // 1-置顶, 0-取消
    const { id } = req.params;
    await pool.query('UPDATE messages SET is_top = ? WHERE id = ?', [is_top, id]);
    res.json({ message: '置顶状态更新成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

// 5. 删除留言 (仅管理员可操作)
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: '权限不足，仅管理员可删除' });
    }
    const { id } = req.params;
    await pool.query('DELETE FROM messages WHERE id = ?', [id]);
    res.json({ message: '删除成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

module.exports = router;
