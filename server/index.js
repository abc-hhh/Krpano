const express = require('express');
const cors = require('cors');
require('dotenv').config();
const http = require('http');
const { Server } = require('socket.io');
const pool = require('./db');
const xss = require('xss');
const { loadSettings } = require('./utils/settingsCache');
const { apiLimiter } = require('./middlewares/rateLimit');
const errorHandler = require('./middlewares/errorHandler');

//   检查并强制要求环境变量 JWT_SECRET
if (!process.env.JWT_SECRET) {
  console.error('\n❌ FATAL ERROR: JWT_SECRET 环境变量未配置！');
  console.error('为了系统安全，请在 .env 文件中配置随机的 JWT_SECRET 字符串，系统已强制退出。\n');
  process.exit(1);
}

const app = express();
const server = http.createServer(app);

//   CORS 跨域配置
const allowedOrigins = process.env.CORS_ORIGINS 
  ? process.env.CORS_ORIGINS.split(',') 
  : ['http://localhost:5173', 'http://localhost:5174', 'http://localhost:5175', 'http://localhost:5176'];

const corsOptions = {
  origin: function (origin, callback) {
    const isLocalIP = origin && origin.match(/^https?:\/\/(127\.0\.0\.1|192\.168\.\d+\.\d+|10\.\d+\.\d+\.\d+|172\.(1[6-9]|2[0-9]|3[0-1])\.\d+\.\d+)(:\d+)?$/);
    if (!origin || allowedOrigins.includes(origin) || allowedOrigins.includes('*') || origin.startsWith('http://localhost:') || origin.startsWith('https://localhost:') || isLocalIP) {
      callback(null, true);
    } else {
      console.warn(`[CORS 拦截] 未授权的来源尝试访问: ${origin}`);
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"]
};

//   初始化 WebSocket 实例
const io = new Server(server, {
  cors: corsOptions
});

//   注册中间件
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.text()); // 解析 text/plain，为了支持 sendBeacon
app.use(express.urlencoded({ extended: true }));

//   配置全局 API 限流策略
app.use('/api', apiLimiter);

//   注册业务路由模块
const authRoutes = require('./routes/auth');
const messageRoutes = require('./routes/messages');
const analyticsRoutes = require('./routes/analytics');
const userRoutes = require('./routes/users');
const settingsRoutes = require('./routes/settings');
const chatRoutes = require('./routes/chat');
const modelDisplayRoutes = require('./routes/modelDisplay');

app.use('/api/auth', authRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/users', userRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/model-display', modelDisplayRoutes);

//   Socket.io 实时聊天业务逻辑
io.on('connection', (socket) => {
  console.log('有新的 WebSocket 连接:', socket.id);

  //   处理客户端加入聊天室 (访客与管理员逻辑分离)
  socket.on('join_room', (data) => {
    const { role, sessionId } = data;
    if (role === 'visitor') {
      socket.join(sessionId);
      console.log(`访客 ${sessionId} 加入房间`);
    } else {
      socket.join('admin_room');
      console.log(`客服/管理员 加入管理房间`);
    }
  });

  //   处理并分发新消息
  socket.on('send_message', async (data) => {
    let { sessionId, senderType, senderName, content, messageType, modelData } = data;
    
    //   XSS 防护与输入内容校验
    if (content) {
      content = xss(String(content).substring(0, 500));
    }
    if (senderName) {
      senderName = xss(String(senderName).substring(0, 20));
    }

    try {
      const msgType = messageType || 'text';
      const mData = modelData ? JSON.stringify(modelData) : null;
      
      //   将消息持久化至数据库
      const [result] = await pool.query(
        'INSERT INTO chat_messages (session_id, sender_type, sender_name, content, message_type, model_data) VALUES (?, ?, ?, ?, ?, ?)',
        [sessionId, senderType, senderName, content, msgType, mData]
      );
      
      const savedMsg = {
        id: result.insertId,
        session_id: sessionId,
        sender_type: senderType,
        sender_name: senderName,
        content: content,
        message_type: msgType,
        model_data: modelData || null,
        created_at: new Date().toISOString()
      };

      //   广播消息至对应房间
      if (senderType === 'visitor') {
        io.to(sessionId).emit('receive_message', savedMsg);
        io.to('admin_room').emit('receive_message', savedMsg);
      } else {
        io.to(sessionId).emit('receive_message', savedMsg);
        io.to('admin_room').emit('receive_message', savedMsg);
      }
    } catch (err) {
      console.error('保存聊天消息失败', err);
    }
  });

  socket.on('disconnect', () => {
    console.log('WebSocket 连接断开:', socket.id);
  });
});

//   注册全局错误处理中间件 (需置于路由尾部)
app.use(errorHandler);

const os = require('os');

//   获取本机局域网 IPv4 地址
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

const PORT = process.env.PORT || 3000;

//   启动服务，监听端口
loadSettings().then(() => {
  server.listen(PORT, '0.0.0.0', () => {
    const ip = getLocalIP();
    console.log('\n=============================================');
    console.log('🚀 服务启动成功!');
    console.log(`- 🌟 后端服务本地地址: http://localhost:${PORT}`);
    console.log(`- 📱 局域网访问地址(答辩演示用): http://${ip}:${PORT}`);
    console.log(`\n💡 提示：`);
    console.log(`外部设备访问前台，请在手机浏览器输入前台项目地址`);
    console.log(`例如前台运行在 5173 端口，请访问: http://${ip}:5173`);
    console.log(`当前是否开启演示模式: ${require('./utils/settingsCache').isDemoMode() ? '✅ 是' : '❌ 否'}`);
    console.log('=============================================\n');
  });
});
