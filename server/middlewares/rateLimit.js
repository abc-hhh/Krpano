const rateLimit = require('express-rate-limit');
const { isDemoMode } = require('../utils/settingsCache');

// 全局 API 限流（防止被 CC 攻击，比如不断刷新接口）
const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 分钟
  max: 200, // 限制每个 IP 1分钟最多请求 200 次
  message: { message: '请求过于频繁，请稍后再试' },
  // 如果开启了演示模式，直接跳过限流检查，方便测试和演示时不被误拦截
  skip: (req, res) => isDemoMode(),
});

// 核心操作动作限流（例如：发表留言、点赞等，防止恶意刷数据）
const actionLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 分钟
  max: 30, // 限制每个 IP 1分钟最多操作 30 次
  message: { message: '操作过于频繁，请稍后再试' },
  // 同样地，开启演示模式时跳过限制，使得演示环境下可以无限点赞或留言
  skip: (req, res) => isDemoMode(),
});

module.exports = {
  apiLimiter,
  actionLimiter,
};