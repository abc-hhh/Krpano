<template>
  <div class="chat-container">
    <el-row :gutter="20" class="chat-row" style="height: 100%;">
      <el-col :xs="24" :sm="6" class="session-list-col">
        <el-card shadow="never" class="h-100 session-card">
          <template #header>
            <div class="card-header">访客咨询列表</div>
          </template>
          <div class="session-list">
            <div v-if="sessions.length === 0" class="empty-tip">暂无咨询记录</div>
            <div 
              v-for="item in sessions" 
              :key="item.session_id" 
              class="session-item"
              :class="{ active: currentSession === item.session_id }"
              @click="selectSession(item.session_id)"
            >
              <div class="session-info">
                <span class="visitor-name">{{ item.session_id }}</span>
                <span class="time">{{ formatTime(item.last_time) }}</span>
              </div>
              <div class="last-msg">{{ item.last_msg }}</div>
              <el-badge :value="item.unread_count" class="unread-badge" v-if="item.unread_count > 0" />
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="18" class="chat-window-col">
        <el-card shadow="never" class="h-100 chat-card">
          <template #header>
            <div class="card-header">{{ currentSession ? '与访客对话中' : '请选择左侧会话' }}</div>
          </template>
          
          <div class="chat-box" v-if="currentSession">
            <div class="msg-list" ref="msgListRef">
              <div 
                v-for="msg in currentMessages" 
                :key="msg.id" 
                class="msg-item"
                :class="{ 'msg-mine': msg.sender_type !== 'visitor' }"
              >
                <div class="msg-bubble">
                  <div class="msg-sender">{{ msg.sender_name || (msg.sender_type === 'visitor' ? '访客' : '客服') }}</div>
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
            
            <div class="msg-input">
              <el-input 
                v-model="inputMsg" 
                type="textarea" 
                :rows="3" 
                placeholder="请输入回复内容，按 Enter 发送" 
                @keyup.enter.prevent="sendMessage"
              />
              <div class="input-actions">
                <el-button @click="showModelDialog = true" :disabled="!currentSession">
                  🔧 发送模型信息
                </el-button>
                <el-button type="primary" @click="sendMessage" :disabled="!inputMsg.trim()">发送 (Enter)</el-button>
              </div>
            </div>
          </div>
          <div v-else class="empty-chat">
            <el-icon :size="60" color="#c0c4cc"><ChatDotRound /></el-icon>
            <p>选择一个访客开始聊天</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog v-model="showModelDialog" title="选择模型信息发送" width="600px" :close-on-click-modal="false">
      <div class="model-dialog-body">
        <el-collapse v-model="expandedModules">
          <el-collapse-item v-for="group in modelGroups" :key="group.module_key" :title="group.module_name" :name="group.module_key">
            <div class="model-list">
              <div 
                v-for="model in group.models" 
                :key="model.model_key" 
                class="model-select-item"
                :class="{ selected: selectedModelKey === model.model_key }"
                @click="selectedModelKey = model.model_key; selectedModelData = model"
              >
                <div class="model-select-name">{{ model.model_name || model.model_key }}</div>
                <div class="model-select-params">
                  <span v-if="model.model_params?.capacity">售价: {{ model.model_params.capacity }}{{ model.model_params.capacity_unit }}</span>
                  <span v-if="model.model_params?.model_type">型号: {{ model.model_params.model_type }}</span>
                </div>
              </div>
            </div>
          </el-collapse-item>
        </el-collapse>
        <div v-if="modelGroups.length === 0" class="empty-tip">暂无可用模型</div>
      </div>
      <template #footer>
        <el-button @click="showModelDialog = false">取消</el-button>
        <el-button type="primary" @click="sendModelInfo" :disabled="!selectedModelKey">发送</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import request from '../utils/request'
import { useUserStore } from '../store/user'
import { io } from 'socket.io-client'

const userStore = useUserStore()
const sessions = ref([])
const currentSession = ref('')
const currentMessages = ref([])
const inputMsg = ref('')
const msgListRef = ref(null)
let socket = null

const showModelDialog = ref(false)
const modelList = ref([])
const selectedModelKey = ref('')
const selectedModelData = ref(null)
const expandedModules = ref([])

const modelGroups = computed(() => {
  const groups = {}
  for (const model of modelList.value) {
    const key = model.module_key || 'other'
    if (!groups[key]) {
      groups[key] = {
        module_key: key,
        module_name: model.module_name || key,
        models: []
      }
    }
    groups[key].models.push(model)
  }
  return Object.values(groups)
})

const fetchModelList = async () => {
  try {
    const res = await request.get('/chat/models')
    modelList.value = res.data || []
    if (modelGroups.value.length > 0) {
      expandedModules.value = [modelGroups.value[0].module_key]
    }
  } catch (error) {
    console.error('获取模型列表失败', error)
  }
}

const fetchSessions = async () => {
  try {
    const res = await request.get('/chat/sessions')
    sessions.value = res.data || []
  } catch (error) {
    console.error('获取会话列表失败', error)
  }
}

const fetchHistory = async (sessionId) => {
  try {
    const res = await request.get(`/chat/history/visitor/${sessionId}`)
    currentMessages.value = res.data || []
    scrollToBottom()
  } catch (error) {
    console.error('获取聊天记录失败', error)
  }
}

const selectSession = async (sessionId) => {
  currentSession.value = sessionId
  await fetchHistory(sessionId)
  
  try {
    await request.put(`/chat/read/${sessionId}`)
    const target = sessions.value.find(s => s.session_id === sessionId)
    if (target) target.unread_count = 0
  } catch (e) {}

  // 手机端自动滚动到聊天区域
  if (window.innerWidth <= 768) {
    nextTick(() => {
      const chatWindow = document.querySelector('.chat-window-col')
      if (chatWindow) {
        chatWindow.scrollIntoView({ behavior: 'smooth' })
      }
    })
  }
}

const scrollToBottom = () => {
  nextTick(() => {
    if (msgListRef.value) {
      msgListRef.value.scrollTop = msgListRef.value.scrollHeight
    }
  })
}

const sendMessage = () => {
  if (!inputMsg.value.trim() || !currentSession.value || !socket) return
  
  const msgData = {
    sessionId: currentSession.value,
    senderType: userStore.userInfo.role === 'admin' ? 'admin' : 'cs',
    senderName: userStore.userInfo.username,
    content: inputMsg.value.trim(),
    messageType: 'text'
  }
  
  socket.emit('send_message', msgData)
  inputMsg.value = ''
}

const sendModelInfo = () => {
  if (!selectedModelData.value || !currentSession.value || !socket) return

  const model = selectedModelData.value
  const msgData = {
    sessionId: currentSession.value,
    senderType: userStore.userInfo.role === 'admin' ? 'admin' : 'cs',
    senderName: userStore.userInfo.username,
    content: `[模型信息] ${model.model_name || model.model_key}`,
    messageType: 'model',
    modelData: {
      model_key: model.model_key,
      model_name: model.model_name || model.model_key,
      module_key: model.module_key,
      module_name: model.module_name,
      model_params: model.model_params || {}
    }
  }

  socket.emit('send_message', msgData)
  showModelDialog.value = false
  selectedModelKey.value = ''
  selectedModelData.value = null
}

const initSocket = () => {
  const baseURL = `http://${window.location.hostname}:3000`
  socket = io(baseURL)
  
  socket.on('connect', () => {
    console.log('聊天室连接成功')
    socket.emit('join_room', { role: 'admin' })
  })

  socket.on('receive_message', (msg) => {
    fetchSessions()
    
    if (msg.session_id === currentSession.value) {
      currentMessages.value.push(msg)
      scrollToBottom()
      if (msg.sender_type === 'visitor') {
        request.put(`/chat/read/${currentSession.value}`).catch(()=>{})
      }
    }
  })
}

const formatTime = (timeStr) => {
  if (!timeStr) return ''
  const d = new Date(timeStr)
  return `${d.getMonth()+1}-${d.getDate()} ${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`
}

onMounted(() => {
  fetchSessions()
  fetchModelList()
  initSocket()
})

onUnmounted(() => {
  if (socket) socket.disconnect()
})
</script>

<style scoped>
.chat-container {
  height: calc(100vh - 120px);
  display: flex;
  overflow: hidden;
}
.el-row {
  width: 100%;
  margin: 0 !important;
}
.session-list-col {
  height: 100%;
  padding-left: 0 !important;
}
.chat-window-col {
  height: 100%;
  padding-right: 0 !important;
}
.h-100 {
  height: 100%;
  display: flex;
  flex-direction: column;
  border: none;
}
.h-100 :deep(.el-card__body) {
  flex: 1;
  padding: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.session-list {
  flex: 1;
  overflow-y: auto;
}
.session-list::-webkit-scrollbar {
  width: 6px;
}
.session-list::-webkit-scrollbar-thumb {
  background: #dcdfe6;
  border-radius: 3px;
}
.session-item {
  padding: 15px;
  border-bottom: 1px solid #ebeef5;
  cursor: pointer;
  position: relative;
  transition: background-color 0.3s;
}
.session-item:hover {
  background-color: #f5f7fa;
}
.session-item.active {
  background-color: #ecf5ff;
  border-left: 4px solid #409eff;
}
.session-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 5px;
}
.visitor-name {
  font-weight: bold;
  font-size: 14px;
  color: #303133;
}
.time {
  font-size: 12px;
  color: #909399;
}
.last-msg {
  font-size: 13px;
  color: #606266;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  padding-right: 20px;
}
.unread-badge {
  position: absolute;
  right: 15px;
  top: 50%;
  transform: translateY(-50%);
}

.chat-box {
  display: flex;
  flex-direction: column;
  flex: 1;
  height: 100%;
  overflow: hidden;
}
.msg-list {
  flex: 1;
  padding: 15px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 15px;
  background-color: #f5f7fa;
}
.msg-list::-webkit-scrollbar {
  width: 6px;
}
.msg-list::-webkit-scrollbar-thumb {
  background: #dcdfe6;
  border-radius: 3px;
}
.msg-item {
  margin-bottom: 20px;
  display: flex;
}
.msg-mine {
  justify-content: flex-end;
}
.msg-bubble {
  max-width: 70%;
  background-color: #fff;
  padding: 10px 15px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  position: relative;
}
.msg-mine .msg-bubble {
  background-color: #9eea6a;
}
.msg-sender {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}
.msg-content {
  font-size: 14px;
  color: #303133;
  line-height: 1.5;
  word-break: break-all;
}
.msg-time {
  font-size: 10px;
  color: #c0c4cc;
  text-align: right;
  margin-top: 4px;
}

.model-card {
  background: #f0f9ff;
  border: 1px solid #bae6fd;
  border-radius: 8px;
  overflow: hidden;
  min-width: 240px;
  max-width: 100%;
}
.model-card-header {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: #e0f2fe;
  font-weight: 600;
  font-size: 14px;
  color: #0369a1;
}
.model-card-body {
  padding: 10px 12px;
}
.model-param-highlight {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 8px;
  padding-bottom: 8px;
  border-bottom: 1px solid #bae6fd;
}
.model-param-highlight .param-label {
  font-size: 12px;
  color: #64748b;
}
.model-param-highlight .param-value {
  font-size: 22px;
  font-weight: 700;
  color: #0284c7;
  font-family: 'Courier New', Courier, monospace;
}
.model-param-highlight .param-value small {
  font-size: 12px;
  color: #64748b;
  font-weight: 400;
}
.model-param-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 6px;
}
.model-param-item {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.model-param-item .param-label {
  font-size: 11px;
  color: #94a3b8;
}
.model-param-item .param-value {
  font-size: 13px;
  color: #334155;
  font-weight: 500;
}

.msg-input {
  border-top: 1px solid #ebeef5;
  padding: 15px;
  background-color: #fff;
  flex-shrink: 0;
}
.input-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 10px;
}

.empty-chat {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: #909399;
}
.empty-tip {
  text-align: center;
  color: #909399;
  padding: 20px;
}

.model-dialog-body {
  max-height: 400px;
  overflow-y: auto;
}
.model-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.model-select-item {
  padding: 12px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}
.model-select-item:hover {
  border-color: #409eff;
  background-color: #ecf5ff;
}
.model-select-item.selected {
  border-color: #409eff;
  background-color: #ecf5ff;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}
.model-select-name {
  font-weight: 600;
  font-size: 14px;
  color: #303133;
  margin-bottom: 4px;
}
.model-select-params {
  display: flex;
  gap: 12px;
  font-size: 12px;
  color: #909399;
}

@media (max-width: 768px) {
  .chat-container {
    height: calc(100vh - 100px);
    overflow: hidden;
  }
  .chat-row {
    flex-direction: column;
    height: 100% !important;
  }
  .session-list-col {
    height: 35%;
    margin-bottom: 10px;
    padding-right: 0 !important;
  }
  .chat-window-col {
    height: 65%;
    padding-left: 0 !important;
  }
  .h-100 {
    height: 100% !important;
  }
  .session-card {
    height: 100%;
  }
  .model-card {
    min-width: unset;
    width: 100%;
  }
}
</style>
