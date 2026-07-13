const express = require('express');
const bcrypt = require('bcryptjs');
const pool = require('../db');
const { authMiddleware } = require('./auth');
const router = express.Router();

const SALT_ROUNDS = 10;

// 管理员权限验证中间件
const adminMiddleware = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: '权限不足，仅管理员可访问' });
  }
  next();
};

// 1. 获取用户列表
router.get('/', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, username, role, created_at FROM users ORDER BY created_at DESC');
    res.json({ data: rows });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

// 2. 新增用户
router.post('/', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { username, password, role } = req.body;
    if (!username || !password || !role) {
      return res.status(400).json({ message: '请填写完整用户信息' });
    }
    
    // 检查用户名是否已存在
    const [existing] = await pool.query('SELECT id FROM users WHERE username = ?', [username]);
    if (existing.length > 0) {
      return res.status(400).json({ message: '用户名已存在' });
    }

    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
    await pool.query('INSERT INTO users (username, password, role) VALUES (?, ?, ?)', [username, hashedPassword, role]);
    res.json({ message: '用户添加成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

// 3. 修改用户信息 (包括修改密码或角色)
router.put('/:id', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { password, role } = req.body;

    if (password) {
      const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
      await pool.query('UPDATE users SET password = ?, role = ? WHERE id = ?', [hashedPassword, role, id]);
    } else {
      await pool.query('UPDATE users SET role = ? WHERE id = ?', [role, id]);
    }
    res.json({ message: '用户信息更新成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

// 4. 删除用户
router.delete('/:id', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    // 不允许删除自己
    if (parseInt(id) === req.user.id) {
      return res.status(400).json({ message: '不能删除当前登录的账号' });
    }

    await pool.query('DELETE FROM users WHERE id = ?', [id]);
    res.json({ message: '用户删除成功' });
  } catch (error) {
    res.status(500).json({ message: '服务器错误' });
  }
});

module.exports = router;
