<template>
  <div class="chat-widget-container">
    <!-- 悬浮聊天入口按钮 -->
    <div class="chat-entry-btn" @click="toggleChat" v-if="!isChatOpen">
      <img src="/images/联系我们.png" alt="联系客服" style="width: 28px; height: 28px;" />
      <span v-if="unreadCount > 0" class="unread-badge">{{ unreadCount }}</span>
      <span class="btn-text">联系客服</span>
    </div>

    <!-- 聊天窗口 -->
    <div class="chat-window" :class="{ 'is-open': isChatOpen }">
      <div class="chat-header">
        <div class="title-area">
          <span class="title">客服对话</span>
        </div>
        <div class="close-btn" @click="handleCloseChat">✕</div>
      </div>
      
      <div class="msg-list" ref="msgListRef">
        <div v-if="messages.length === 0" class="empty-tip">您好，请问有什么可以帮您？</div>
        <div 
          v-for="msg in messages" 
          :key="msg.id" 
          class="msg-item"
          :class="{ 'msg-mine': msg.sender_type === 'visitor' }"
        >
          <div class="msg-bubble">
            <div class="msg-sender">{{ msg.sender_type === 'visitor' ? '我' : (msg.sender_name || '客服') }}</div>
            <div v-if="msg.message_type === 'model' && msg.model_data" class="model-card">
              <div class="model-card-header">
                <span class="model-icon">🔧</span>
                <span class="model-name">{{ msg.model_data.model_name || msg.model_data.model_key }}</span>
              </div>
              <div class="model-card-body">
                <div class="model-param-highlight">
                  <span class="param-label">当前售价</span>
                  <span class="param-value">{{ msg.model_data.model_params?.capacity || '-' }} <small>{{ msg.model_data.model_params?.capacity_unit || '' }}</small></span>
                </div>
                <div class="model-param-grid">
                  <div class="model-param-item">
                    <span class="param-label">上架日期</span>
                    <span class="param-value">{{ msg.model_data.model_params?.runtime || '-' }} {{ msg.model_data.model_params?.runtime_unit || '' }}</span>
                  </div>
                  <div class="model-param-item">
                    <span class="param-label">好评率</span>
                    <span class="param-value">{{ msg.model_data.model_params?.speed || '-' }} {{ msg.model_data.model_params?.speed_unit || '' }}</span>
                  </div>
                  <div class="model-param-item">
                    <span class="param-label">型号</span>
                    <span class="param-value">{{ msg.model_data.model_params?.model_type || '-' }}</span>
                  </div>
                  <div class="model-param-item">
                    <span class="param-label">已售出</span>
                    <span class="param-value">{{ msg.model_data.model_params?.batch || '-' }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="msg-content">{{ msg.content }}</div>
            <div class="msg-time">{{ formatTime(msg.created_at) }}</div>
          </div>
        </div>
      </div>

      <div class="msg-input-area">
        <input 
          type="text" 
          v-model="inputMsg" 
          placeholder="请输入您的问题..." 
          @keyup.enter="sendMessage"
        />
        <button @click="sendMessage" :disabled="!inputMsg.trim()">发送</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { io } from 'socket.io-client'
import { useAuthStore } from '../stores/auth'
import request from '../utils/request'

// 连接初始化
const isChatOpen = ref(false)
const messages = ref([])
const inputMsg = ref('')
const msgListRef = ref(null)
const unreadCount = ref(0)

const authStore = useAuthStore()
const { currentUser } = storeToRefs(authStore)

let socket = null
let sessionId = ''

//  控制聊天面板的开关及权限拦截
const toggleChat = () => {
  if (!currentUser.value) {
    authStore.openLogin()
    return
  }

  isChatOpen.value = !isChatOpen.value
  if (isChatOpen.value) {
    unreadCount.value = 0
    scrollToBottom()
  }
}

const handleCloseChat = () => {
  isChatOpen.value = false
}

//  滚动至最新消息
const scrollToBottom = () => {
  nextTick(() => {
    if (msgListRef.value) {
      msgListRef.value.scrollTop = msgListRef.value.scrollHeight
    }
  })
}

//  获取当前用户的聊天记录
const fetchHistory = async () => {
  try {
    const data = await request.get(`/chat/history/visitor/${sessionId}`)
    if (data.data) {
      messages.value = data.data
      scrollToBottom()
    }
  } catch (error) {
    console.error('获取历史记录失败', error)
  }
}

//  建立并初始化 WebSocket 实时连接
const initSocket = () => {
  if (!currentUser.value) return
  // 获取当前用户的id
  sessionId = currentUser.value.username
  
  const baseURL = `http://${window.location.hostname}:3000`
  socket = io(baseURL)
  
  socket.on('connect', () => {
    // 加入聊天室
    socket.emit('join_room', { role: 'visitor', sessionId })
  })

  socket.on('receive_message', (msg) => {
    if (msg.session_id === sessionId) {
      messages.value.push(msg)
      // 如果聊天窗口关闭，且收到消息，则标记未读
      if (!isChatOpen.value && msg.sender_type !== 'visitor') {
        unreadCount.value++
      }
      scrollToBottom()
    }
  })
}

//  发送文本消息
const sendMessage = () => {
  if (!inputMsg.value.trim() || !socket) return
  
  if (!currentUser.value) return

  const msgData = {
    sessionId: currentUser.value.username,
    senderType: 'visitor',
    senderName: currentUser.value.username,
    content: inputMsg.value.trim()
  }
  
  socket.emit('send_message', msgData)
  inputMsg.value = ''
}

const formatTime = (timeStr) => {
  if (!timeStr) return ''
  const d = new Date(timeStr)
  return `${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`
}

// 监听状态变化重新连接
watch(currentUser, (newUser) => {
  if (newUser) {
    if (socket) socket.disconnect()
    initSocket()
    fetchHistory()
  } else {
    if (socket) socket.disconnect()
    isChatOpen.value = false
    messages.value = []
  }
})

onMounted(() => {
  if (currentUser.value) {
    initSocket()
    fetchHistory()
  }
})

onUnmounted(() => {
  if (socket) socket.disconnect()
})
</script>

<style scoped>
.chat-widget-container {
  position: absolute;
  bottom: 20px;
  right: 20px;
  z-index: 10005; /* 确保它始终悬浮在所有3D模型之上 */
}

.chat-entry-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
  background: rgba(15, 23, 42, 0.3);
  color: #38bdf8;
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  transition: all 0.3s ease;
  position: relative;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}
.chat-entry-btn:hover {
  background: rgba(15, 23, 42, 0.8);
  transform: scale(1.05);
}
.btn-text {
  font-size: 10px;
  margin-top: 2px;
}
.unread-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #f56c6c;
  color: white;
  font-size: 12px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #fff;
}

.chat-window {
  position: absolute;
  bottom: 80px;
  right: 0;
  width: 320px;
  height: 450px;
  background: rgba(15, 23, 42, 0.9);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  transform: scale(0.9);
  opacity: 0;
  pointer-events: none;
  transform-origin: bottom right;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}
.chat-window.is-open {
  transform: scale(1);
  opacity: 1;
  pointer-events: auto;
}

.chat-header {
  background: rgba(255, 255, 255, 0.1);
  padding: 12px 15px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}
.title-area {
  display: flex;
  align-items: center;
  gap: 10px;
}
.chat-header .title {
  color: #fff;
  font-weight: bold;
  font-size: 15px;
}
.login-tip {
  font-size: 10px;
  color: #38bdf8;
  cursor: pointer;
  text-decoration: underline;
}
.login-tip:hover {
  color: #fff;
}
.close-btn {
  color: rgba(255, 255, 255, 0.6);
  cursor: pointer;
  font-size: 18px;
}
.close-btn:hover {
  color: #fff;
}

.msg-list {
  flex: 1;
  padding: 15px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.msg-list::-webkit-scrollbar {
  width: 4px;
}
.msg-list::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 2px;
}

.empty-tip {
  text-align: center;
  color: rgba(255, 255, 255, 0.5);
  font-size: 12px;
  margin-top: 20px;
}

.msg-item {
  display: flex;
  width: 100%;
}
.msg-mine {
  justify-content: flex-end;
}
.msg-bubble {
  max-width: 80%;
  background: rgba(255, 255, 255, 0.1);
  padding: 8px 12px;
  border-radius: 8px;
  border-top-left-radius: 2px;
  position: relative;
}
.msg-mine .msg-bubble {
  background: #38bdf8;
  border-radius: 8px;
  border-top-right-radius: 2px;
}
.msg-sender {
  font-size: 10px;
  color: rgba(255, 255, 255, 0.5);
  margin-bottom: 4px;
}
.msg-mine .msg-sender {
  color: rgba(255, 255, 255, 0.8);
}
.msg-content {
  font-size: 13px;
  color: #fff;
  line-height: 1.4;
  word-break: break-all;
}
.msg-time {
  font-size: 9px;
  color: rgba(255, 255, 255, 0.4);
  text-align: right;
  margin-top: 4px;
}
.msg-mine .msg-time {
  color: rgba(255, 255, 255, 0.7);
}

.model-card {
  background: rgba(56, 189, 248, 0.12);
  border: 1px solid rgba(56, 189, 248, 0.3);
  border-radius: 8px;
  overflow: hidden;
  min-width: 200px;
  margin: 4px 0;
}
.model-card-header {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 10px;
  background: rgba(56, 189, 248, 0.18);
  font-weight: 600;
  font-size: 13px;
  color: #38bdf8;
}
.model-card-body {
  padding: 8px 10px;
}
.model-param-highlight {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 6px;
  padding-bottom: 6px;
  border-bottom: 1px solid rgba(56, 189, 248, 0.2);
}
.model-param-highlight .param-label {
  font-size: 10px;
  color: rgba(255, 255, 255, 0.5);
}
.model-param-highlight .param-value {
  font-size: 18px;
  font-weight: 700;
  color: #38bdf8;
  font-family: 'Courier New', Courier, monospace;
}
.model-param-highlight .param-value small {
  font-size: 10px;
  color: rgba(255, 255, 255, 0.5);
  font-weight: 400;
}
.model-param-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px;
}
.model-param-item {
  display: flex;
  flex-direction: column;
  gap: 1px;
}
.model-param-item .param-label {
  font-size: 9px;
  color: rgba(255, 255, 255, 0.4);
}
.model-param-item .param-value {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.85);
  font-weight: 500;
}

.msg-input-area {
  padding: 12px;
  background: rgba(0, 0, 0, 0.2);
  display: flex;
  gap: 8px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}
.msg-input-area input {
  flex: 1;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #fff;
  border-radius: 16px;
  padding: 0 12px;
  font-size: 13px;
  outline: none;
}
.msg-input-area input:focus {
  border-color: #38bdf8;
}
.msg-input-area button {
  background: #38bdf8;
  color: white;
  border: none;
  border-radius: 16px;
  padding: 0 15px;
  font-size: 13px;
  cursor: pointer;
}
.msg-input-area button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 弹窗样式 */
.auth-modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
}
.auth-modal {
  background: #fff;
  padding: 25px;
  border-radius: 12px;
  width: 300px;
  color: #333;
  box-shadow: 0 10px 30px rgba(0,0,0,0.5);
}
.auth-modal h3 {
  margin: 0 0 20px 0;
  font-size: 16px;
  text-align: center;
  color: #333;
}
.auth-modal input {
  width: 100%;
  padding: 10px;
  margin-bottom: 15px;
  border: 1px solid #ccc;
  border-radius: 6px;
  box-sizing: border-box;
  font-size: 14px;
}
.auth-actions {
  display: flex;
  justify-content: space-between;
  gap: 10px;
}
.auth-actions button {
  flex: 1;
  padding: 10px;
  border: none;
  border-radius: 6px;
  background: #f0f0f0;
  color: #666;
  cursor: pointer;
  font-size: 14px;
}
.auth-actions button:hover {
  background: #e0e0e0;
}
.auth-actions button.primary {
  background: #38bdf8;
  color: #fff;
}
.auth-actions button.primary:hover {
  background: #0ea5e9;
}

/* 移动端适配 */
@media screen and (max-width: 768px) {
  .chat-widget-container {
    bottom: 70px;
    right: 20px;
  }
  .chat-window {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    width: 100%;
    height: 100%;
    border-radius: 0;
    z-index: 1000;
  }
  .model-card {
    min-width: unset;
    width: 100%;
  }
}
</style>