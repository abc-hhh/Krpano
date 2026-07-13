<template>
  <!-- 移动端悬浮入口按钮 -->
  <div class="mobile-entry-btn" @click="toggleMobileWall" v-if="!isMobileWallOpen">
    <img src="/images/留言.png" alt="留言墙" style="width: 28px; height: 28px;" />
    <span class="btn-text">留言墙</span>
  </div>

  <!-- 留言墙主体容器 -->
  <div class="message-wall-container" :class="{ 'is-commenting': isCommenting, 'mobile-open': isMobileWallOpen }" ref="messageWallRef">
    <!-- 移动端顶部关闭条 -->
    <div class="mobile-close-bar" @click="toggleMobileWall">
      <div class="close-handle"></div>
    </div>

    <!-- 上半部分：留言展示区 -->
    <div 
      class="message-list" 
      ref="messageListRef"
    >
      <div class="message-header">
        <span class="title">留言墙</span>
        <div class="sort-controls">
          <span :class="{ active: sortBy === 'heat' }" @click="changeSort('heat')">最热</span>
          <span class="divider">|</span>
          <span :class="{ active: sortBy === 'time' }" @click="changeSort('time')">最新</span>
        </div>
      </div>
      <div v-if="pinnedMessages.length === 0 && normalMessages.length === 0" class="empty-tip">暂无留言，快来抢沙发吧~</div>
      <div 
        v-for="item in [...pinnedMessages, ...normalMessages]" 
        :key="item.id" 
        class="message-item"
        :class="{ 'is-top': item.is_top }"
      >
        <div class="msg-top-row">
          <span class="nickname">{{ item.nickname }}</span>
          <span class="time">{{ formatTime(item.created_at) }}</span>
          <span v-if="item.is_top" class="top-tag">置顶</span>
        </div>
        <div class="msg-content">{{ item.content }}</div>

        <!-- 点赞区域 -->
        <div class="msg-actions">
          <span class="like-btn" :class="{ liked: isLiked(item.id) }" @click="likeMessage(item.id)">
            <svg viewBox="0 0 24 24" width="12" height="12" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" :style="isLiked(item.id) ? 'fill: currentColor' : ''">
              <path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path>
            </svg>
            {{ item.likes || 0 }}
          </span>
        </div>
        
        <!-- 管理员/客服 回复区域 -->
        <div v-if="item.reply_content" class="reply-box">
          <div class="reply-header">
            <span class="replier-role" :class="item.replier_role">
              {{ item.replier_role === 'admin' ? '管理员回复' : '客服回复' }}
            </span>
            <span class="time">{{ formatTime(item.reply_time) }}</span>
          </div>
          <div class="reply-content">{{ item.reply_content }}</div>
        </div>
      </div>
      
      <div v-if="hasMore" class="load-more" @click="loadMore">点击加载更多</div>
      <div v-else-if="normalMessages.length > 0" class="no-more">- 没有更多留言了 -</div>
    </div>

    <!-- 下半部分：留言输入区 -->
    <div class="message-input-area">
      <div v-if="!isCommenting" class="input-trigger" @click.stop="handleCommentClick">
        写点什么吧...
      </div>
      <div v-else class="input-form">
        <div class="current-user-info">当前用户: {{ currentUser?.username }}</div>
        <textarea 
          v-model="form.content" 
          placeholder="请输入留言内容..." 
          class="form-textarea"
          rows="3"
          maxlength="200"
        ></textarea>
        <div class="form-actions">
          <button class="btn-cancel" @click="cancelComment">取消</button>
          <button class="btn-submit" @click="submitMessage" :disabled="isSubmitting">提交</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { storeToRefs } from 'pinia'
import request from '../utils/request'
import { useAuthStore } from '../stores/auth'

//   获取用户认证状态
const authStore = useAuthStore()
const { currentUser } = storeToRefs(authStore)

//   留言数据与分页状态
const pinnedMessages = ref([])
const normalMessages = ref([])
const hasMore = ref(false)
const offset = ref(0)
const sortBy = ref('heat') // 'heat' or 'time'
const likedMessages = ref(JSON.parse(localStorage.getItem('likedMessages') || '[]'))

const messageListRef = ref(null)
const messageWallRef = ref(null)
const isCommenting = ref(false)
const isSubmitting = ref(false)
const isMobileWallOpen = ref(false)

//   拦截未登录用户的评论操作并拉起登录框
const handleCommentClick = () => {
  if (!currentUser.value) {
    authStore.openLogin()
    return
  }
  form.value.nickname = currentUser.value.username
  isCommenting.value = true
}

//   响应移动端留言墙显示/隐藏切换
const toggleMobileWall = () => {
  isMobileWallOpen.value = !isMobileWallOpen.value
  if (!isMobileWallOpen.value) {
    cancelComment()
  }
}

const form = ref({
  nickname: '',
  content: ''
})

//   获取留言数据
const fetchMessages = async (isLoadMore = false) => {
  if (!isLoadMore) {
    offset.value = 0
  }
  try {
    const data = await request.get('/messages/public', { sort: sortBy.value, offset: offset.value, limit: 5 })
    if (data.data) {
      if (!isLoadMore) {
        pinnedMessages.value = data.data.pinned || []
        normalMessages.value = data.data.normal || []
      } else {
        normalMessages.value = [...normalMessages.value, ...(data.data.normal || [])]
      }
      hasMore.value = data.data.hasMore
    }
  } catch (error) {
    console.error('获取留言失败', error)
  }
}

const loadMore = () => {
  offset.value += 5
  fetchMessages(true)
}

const changeSort = (sortType) => {
  if (sortBy.value === sortType) return
  sortBy.value = sortType
  fetchMessages()
}

const isLiked = (id) => {
  return likedMessages.value.includes(id)
}

// 点赞功能
const likeMessage = async (id) => {
  const currentlyLiked = isLiked(id)
  const action = currentlyLiked ? 'unlike' : 'like'
  
  try {
    const res = await request.put(`/messages/public/${id}/like`, { action })
    
    if (res) {
      if (currentlyLiked) {
        // 取消点赞
        likedMessages.value = likedMessages.value.filter(msgId => msgId !== id)
      } else {
        // 点赞
        likedMessages.value.push(id)
      }
      localStorage.setItem('likedMessages', JSON.stringify(likedMessages.value))
      
      // 前端更新数量
      const updateList = (list) => {
        const item = list.find(m => m.id === id)
        if (item) {
          if (currentlyLiked) {
            item.likes = Math.max((item.likes || 0) - 1, 0)
          } else {
            item.likes = (item.likes || 0) + 1
          }
        }
      }
      updateList(pinnedMessages.value)
      updateList(normalMessages.value)
    }
  } catch (error) {
    console.error('操作失败', error)
  }
}

const cancelComment = () => {
  isCommenting.value = false
  form.value.content = ''
}

// 提交留言功能
const submitMessage = async () => {
  if (!form.value.nickname.trim() || !form.value.content.trim()) {
    alert('留言内容不能为空！')
    return
  }
  
  isSubmitting.value = true
  try {
    const data = await request.post('/messages/public', form.value)
    if (data) {
      alert('留言提交成功，等待管理员审核！')
      cancelComment()
    }
  } catch (error) {
    console.error('提交留言失败', error)
    alert('提交留言失败，请稍后重试')
  } finally {
    isSubmitting.value = false
  }
}

const formatTime = (timeStr) => {
  if (!timeStr) return ''
  const date = new Date(timeStr)
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}

const handleClickOutside = (e) => {
  if (isCommenting.value && messageWallRef.value && !messageWallRef.value.contains(e.target)) {
    // 只有当点击的目标元素还在文档中时，才认为是真正的“点击外部”。
    // 这样可以防止点击留言墙内部某个会导致自身被移除的元素时（比如按钮消失），错误触发退出编辑。
    if (document.contains(e.target)) {
      // 退出编辑状态但保留输入内容
      isCommenting.value = false
    }
  }
}

onMounted(async () => {
  fetchMessages()
  // 每隔30秒静默刷新一次（重置回第一页）
  fetchTimer = setInterval(() => fetchMessages(), 30000)
  document.addEventListener('click', handleClickOutside)
  
  // 检查是否开启了演示模式，如果开启，则清空本地的点赞记录
  try {
    const data = await request.get('/settings')
    if (data.data && data.data.demo_mode === 1) {
      likedMessages.value = []
      localStorage.removeItem('likedMessages')
    }
  } catch (error) {
    console.error('获取配置失败', error)
  }
})

onUnmounted(() => {
  if (fetchTimer) clearInterval(fetchTimer)
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
/* 电脑端默认隐藏相关元素 */
.mobile-entry-btn {
  display: none;
}
.mobile-close-bar {
  display: none;
}

.message-wall-container {
  position: absolute;
  top: 95px; /* 避开左上角 Logo */
  left: 20px;
  height: 60vh; /* 高度缩小为三分之二左右 */
  width: 280px;
  display: flex;
  flex-direction: column;
  background: rgba(15, 23, 42, 0.85); /* 统一深色半透明背景 */
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  z-index: 100;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  transition: background-color 0.3s ease;
}

.message-wall-container.is-commenting {
  background: rgba(15, 23, 42, 1); /* 准备留言时100%不透明 */
}

/* 移动端适配 */
@media screen and (max-width: 768px) {
  /* 悬浮入口按钮 */
  .mobile-entry-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: absolute;
    right: 20px;
    bottom: 140px;
    width: 60px;
    height: 60px;
    background: rgba(15, 23, 42, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    color: #38bdf8;
    z-index: 90;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(10px);
    cursor: pointer;
  }
  .mobile-entry-btn .btn-text {
    font-size: 10px;
    margin-top: 2px;
    color: #38bdf8;
  }

  /* 留言墙主容器 (默认隐藏，滑出显示) */
  .message-wall-container {
    top: 100px;
    bottom: 20px; /* 距离底部 20px，不再贴底 */
    left: -100%;
    width: 280px; /* 稍微变窄一点 */
    height: 55vh; /* 高度变短，占屏幕高度的 60% */
    border-radius: 12px; /* 增加圆角 */
    border: 1px solid rgba(255, 255, 255, 0.2);
    transition: left 0.4s cubic-bezier(0.25, 0.8, 0.25, 1), background-color 0.3s ease;
  }
  .message-wall-container.mobile-open {
    left: 10px; /* 滑出时距离左侧留 10px 空隙 */
  }

  /* 顶部关闭条 */
  .mobile-close-bar {
    display: flex;
    justify-content: flex-end;
    padding: 15px;
    cursor: pointer;
  }
  .close-handle {
    width: 20px;
    height: 20px;
    background: transparent;
  }
  .close-handle::before, .close-handle::after {
    content: '';
    position: absolute;
    width: 20px;
    height: 2px;
    background: rgba(255, 255, 255, 0.6);
    top: 24px;
    right: 15px;
  }
  .close-handle::before {
    transform: rotate(45deg);
  }
  .close-handle::after {
    transform: rotate(-45deg);
  }

  .message-list {
    padding: 5px 15px 15px;
    gap: 8px;
  }

  .message-header .title {
    font-size: 14px;
  }

  .nickname {
    font-size: 13px;
  }

  .time, .top-tag, .replier-role, .reply-content {
    font-size: 11px;
  }

  .msg-content {
    font-size: 12px;
  }

  .input-trigger {
    padding: 10px;
    font-size: 13px;
  }

  .message-input-area {
    min-height: 60px;
  }
}

/* 留言展示区 (80%) */
.message-list {
  flex: 1;
  overflow-y: auto;
  padding: 15px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

/* 隐藏滚动条但保留滚动功能 */
.message-list::-webkit-scrollbar {
  display: none;
}

.message-header {
  margin-bottom: 10px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.message-header .title {
  color: #38bdf8;
  font-size: 16px;
  font-weight: bold;
  letter-spacing: 2px;
}
.sort-controls {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
  display: flex;
  gap: 6px;
  align-items: center;
}
.sort-controls span {
  cursor: pointer;
  transition: color 0.2s;
}
.sort-controls span.active {
  color: #38bdf8;
  font-weight: bold;
}
.sort-controls .divider {
  cursor: default;
  color: rgba(255, 255, 255, 0.2);
}

.empty-tip {
  text-align: center;
  color: rgba(255, 255, 255, 0.5);
  font-size: 13px;
  margin-top: 20px;
}

.message-item {
  background: rgba(255, 255, 255, 0.08);
  border-radius: 6px;
  padding: 10px;
  color: #fff;
}
.message-item.is-top {
  border-left: 3px solid #f56c6c;
  background: rgba(245, 108, 108, 0.1);
}

.msg-top-row {
  display: flex;
  align-items: center;
  margin-bottom: 6px;
}
.nickname {
  font-size: 14px;
  font-weight: bold;
  color: #e2e8f0;
  margin-right: 8px;
}
.time {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.4);
}
.top-tag {
  margin-left: auto;
  background: #f56c6c;
  color: #fff;
  font-size: 10px;
  padding: 2px 4px;
  border-radius: 3px;
}

.msg-content {
  font-size: 13px;
  line-height: 1.5;
  color: #cbd5e1;
  word-break: break-all;
}

.msg-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 6px;
}
.like-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  color: rgba(255, 255, 255, 0.5);
  cursor: pointer;
  transition: all 0.2s;
}
.like-btn:hover {
  color: #fff;
}
.like-btn.liked {
  color: #f56c6c;
  cursor: default;
}

.load-more {
  text-align: center;
  font-size: 12px;
  color: #38bdf8;
  cursor: pointer;
  padding: 10px 0;
  transition: color 0.2s;
}
.load-more:hover {
  color: #7dd3fc;
}
.no-more {
  text-align: center;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.3);
  padding: 10px 0;
}

.reply-box {
  margin-top: 10px;
  padding: 8px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 4px;
  border-left: 2px solid #409eff;
}
.reply-header {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
}
.replier-role {
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 3px;
  margin-right: 8px;
}
.replier-role.admin {
  background: #f56c6c;
  color: #fff;
}
.replier-role.cs {
  background: #409eff;
  color: #fff;
}
.reply-content {
  font-size: 12px;
  color: #94a3b8;
  line-height: 1.4;
}

/* 留言输入区 (20%) */
.message-input-area {
  flex-shrink: 0;
  min-height: 80px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(0, 0, 0, 0.2);
  padding: 10px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.input-trigger {
  color: rgba(255, 255, 255, 0.5);
  font-size: 14px;
  text-align: center;
  cursor: pointer;
  padding: 15px;
  border: 1px dashed rgba(255, 255, 255, 0.3);
  border-radius: 4px;
  transition: all 0.3s;
}
.input-trigger:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.input-form {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.current-user-info {
  font-size: 13px;
  color: #38bdf8;
  font-weight: bold;
}

.form-input,
.form-textarea {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #fff;
  border-radius: 4px;
  padding: 8px;
  font-size: 13px;
  outline: none;
  font-family: inherit;
}
.form-input::placeholder, .form-textarea::placeholder {
  color: rgba(255, 255, 255, 0.4);
}
.form-input:focus, .form-textarea:focus {
  border-color: #38bdf8;
  background: rgba(255, 255, 255, 0.15);
}
.form-textarea {
  resize: none;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
.btn-cancel, .btn-submit {
  border: none;
  padding: 6px 12px;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-cancel {
  background: transparent;
  color: rgba(255, 255, 255, 0.6);
}
.btn-cancel:hover {
  color: #fff;
}
.btn-submit {
  background: #38bdf8;
  color: #fff;
}
.btn-submit:hover {
  background: #0ea5e9;
}
.btn-submit:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
