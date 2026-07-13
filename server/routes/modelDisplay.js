const express = require('express');
const { authMiddleware } = require('./auth');
const pool = require('../db');
const router = express.Router();

//   获取所有 3D 模型展示配置项 (管理后台使用)
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM model_display ORDER BY module_key, model_key'
    );
    res.json({ data: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: '服务器错误' });
  }
});

//   获取对外公开的 3D 模型展示状态 (前端展示使用)
router.get('/public', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT module_key, model_key, is_enabled, disable_reason, model_params FROM model_display ORDER BY module_key, model_key'
    );
    res.json({ data: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: '服务器错误' });
  }
});

//   更新 3D 模型参数及可用状态
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: '仅管理员可修改' });
    }

    const { id } = req.params;
    const { is_enabled, disable_reason, model_params } = req.body;

    const [existing] = await pool.query('SELECT * FROM model_display WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: '记录不存在' });
    }

    const existingRecord = existing[0];
    const updatedBy = req.user.username;

    if (model_params !== undefined && is_enabled === undefined) {
      await pool.query(
        'UPDATE model_display SET model_params = ?, updated_by = ? WHERE id = ?',
        [JSON.stringify(model_params), updatedBy, id]
      );
    } else {
      if (is_enabled === 0 || is_enabled === false) {
        if (!disable_reason || !disable_reason.trim()) {
          return res.status(400).json({ message: '禁用时必须填写禁用理由' });
        }
      }

      const newEnabled = is_enabled ? 1 : 0;
      const newReason = is_enabled ? null : (disable_reason || null);

      await pool.query(
        'UPDATE model_display SET is_enabled = ?, disable_reason = ?, updated_by = ? WHERE id = ?',
        [newEnabled, newReason, updatedBy, id]
      );

      if (existingRecord.model_key === null && !is_enabled) {
        await pool.query(
          'UPDATE model_display SET is_enabled = 0, disable_reason = ?, updated_by = ? WHERE module_key = ? AND model_key IS NOT NULL',
          [`模块"${existingRecord.module_name}"已被禁用`, updatedBy, existingRecord.module_key]
        );
      }
      if (existingRecord.model_key === null && is_enabled) {
        await pool.query(
          'UPDATE model_display SET is_enabled = 1, disable_reason = NULL, updated_by = ? WHERE module_key = ? AND model_key IS NOT NULL AND disable_reason = ?',
          [updatedBy, existingRecord.module_key, `模块"${existingRecord.module_name}"已被禁用`]
        );
      }
    }

    const [updated] = await pool.query('SELECT * FROM model_display ORDER BY module_key, model_key');
    res.json({ data: updated, message: '更新成功' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: '服务器错误' });
  }
});

module.exports = router;
