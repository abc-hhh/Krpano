/**
 * 统一的异常捕获和格式化处理中间件
 * 可以捕获路由中 `next(error)` 抛出的所有异常
 */
const errorHandler = (err, req, res, next) => {
  console.error('\n[统一错误处理捕获异常] ❌', new Date().toLocaleString());
  console.error(`- 请求接口: ${req.method} ${req.originalUrl}`);
  console.error(`- 错误详情:\n`, err.stack || err);

  // 默认返回 500
  const statusCode = err.statusCode || 500;
  const message = err.message || '服务器内部错误';

  res.status(statusCode).json({
    error: true,
    message: message,
    // 在生产环境可以选择性隐藏 stack
    // stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
};

module.exports = errorHandler;