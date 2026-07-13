const pool = require('../db');

let settingsCache = {
  demo_mode: 0,
};

/**
 * 从数据库加载最新配置到内存缓存中
 */
async function loadSettings() {
  try {
    const [rows] = await pool.query('SELECT * FROM settings LIMIT 1');
    if (rows.length > 0) {
      settingsCache = rows[0];
    }
  } catch (error) {
    console.error('加载系统配置缓存失败:', error);
  }
}

/**
 * 判断当前是否开启了演示模式
 * @returns {boolean}
 */
function isDemoMode() {
  return settingsCache.demo_mode === 1;
}

/**
 * 当后台管理员更新配置时，同步更新内存缓存
 * @param {Object} newSettings 最新的配置对象
 */
function updateSettings(newSettings) {
  settingsCache = { ...settingsCache, ...newSettings };
}

module.exports = {
  loadSettings,
  isDemoMode,
  updateSettings,
};