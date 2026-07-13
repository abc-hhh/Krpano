<template>
  <div id="app-container">
    <!-- 全景渲染器组件 (底层) -->
    <PanoViewer ref="panoRef" />
    
    <!-- 留言墙组件 (左侧) -->
    <MessageWall />

    <!-- 客服聊天悬浮组件 (右下角) -->
    <ChatWidget />

    <!-- 3D 机械零件模型组件 (以弹窗形式覆盖在全景之上) -->
    <ThreeModel v-if="showModel && modelPage === 'mechanical'" @close="showModel = false" :modelData="currentModelData" :disabledModels="disabledModels" :modelDisplayConfig="modelDisplayConfig" />

    <!-- 魔方模型组件 (以弹窗形式覆盖在全景之上) -->
    <CubeModel v-if="showModel && modelPage === 'cube'" @close="showModel = false" :disabledModels="disabledModels" :modelDisplayConfig="modelDisplayConfig" />

    <!-- 3D模型展示页面切换浮层 -->
    <div class="model-switcher" v-if="showModel">
      <button :class="{ active: modelPage === 'mechanical' }" @click="switchModelPage('mechanical')" :disabled="disabledModules.includes('mechanical')">机械零件</button>
      <button :class="{ active: modelPage === 'cube' }" @click="switchModelPage('cube')" :disabled="disabledModules.includes('cube')">魔方动画</button>
    </div>

    <!-- 左上角的动态Logo和标题 -->
    <div class="site-header" v-if="siteSettings.title">
      <a :href="siteSettings.target_url" target="_blank" class="site-link">
        <img v-if="siteSettings.logo_url" :src="siteSettings.logo_url" class="site-logo" alt="Logo" />
        <span class="site-title">{{ siteSettings.title }}</span>
      </a>
    </div>

    <!-- 右上角全局用户登录入口 -->
    <div class="global-auth-btn" @click="handleAuthClick">
      <span v-if="currentUser">{{ currentUser.username }}</span>
      <span v-else>登录/注册</span>
    </div>

    <!-- 右上角工具栏(全屏、VR) -->
    <div class="toolbar-right">
      <div class="tool-btn" @click="toggleFullscreen" @mouseenter="showTooltip('fullscreen')" @mouseleave="hideTooltip">
        <img :src="isFullscreen ? '/images/退出全屏.png' : '/images/全屏.png'" alt="全屏控制" />
        <span class="tool-tooltip" v-show="activeTooltip === 'fullscreen'">{{ isFullscreen ? '退出全屏' : '全屏' }}</span>
      </div>
      <div class="tool-btn" @click="enterVR" @mouseenter="showTooltip('vr')" @mouseleave="hideTooltip">
        <img src="/images/VR.png" alt="VR模式" />
        <span class="tool-tooltip" v-show="activeTooltip === 'vr'">进入VR模式</span>
      </div>
    </div>

    <!-- 登录/注册弹窗 -->
    <div class="auth-modal-overlay" v-if="showAuthModal">
      <div class="auth-modal">
        <h3>{{ isRegistering ? '注册新账号' : '用户登录' }}</h3>
        <input type="text" v-model="authForm.username" placeholder="请输入用户名" />
        <input type="password" v-model="authForm.password" placeholder="请输入密码" />
        <div class="auth-switch" @click="isRegistering = !isRegistering">
          {{ isRegistering ? '已有账号？去登录' : '没有账号？去注册' }}
        </div>
        <div class="auth-actions">
          <button @click="showAuthModal = false">取消</button>
          <button class="primary" @click="submitAuth">{{ isRegistering ? '注册' : '登录' }}</button>
        </div>
      </div>
    </div>

    <!-- 左下角的控制面板 -->
    <div class="control-panel" v-if="!showModel">
      <div class="panel-title">展厅控制台</div>
      
      <div class="control-main-btns">
        <!-- 快速跳转按钮 -->
        <button class="primary-btn" @click.stop="showSceneMenu = !showSceneMenu">
          快速跳转
        </button>
        <!-- 查看产品按钮 -->
        <button class="primary-btn" @click="openProductModel">
          查看产品
        </button>
      </div>

      <!-- 快速跳转弹窗 -->
      <transition name="slide-up">
        <div class="scene-menu" v-if="showSceneMenu" @click.stop>
          <div class="scene-menu-title">选择场景</div>
          <button @click="changeScene('scene_01ytjbxo')">切换到正门</button>
          <button @click="changeScene('scene_02xknxof-1')">切换到大厅</button>
          <button @click="changeScene('scene_04xxvxof-1')">切换到展厅</button>
        </div>
      </transition>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, provide } from 'vue'
import { storeToRefs } from 'pinia'
import PanoViewer from './components/PanoViewer.vue'
import ThreeModel from './components/ThreeModel.vue'
import CubeModel from './components/CubeModel.vue'
import MessageWall from './components/MessageWall.vue'
import ChatWidget from './components/ChatWidget.vue'
import { useAuthStore } from './stores/auth'
import { useAnalytics } from './composables/useAnalytics'
import { useModelConfig } from './composables/useModelConfig'

const authStore = useAuthStore()
const { currentUser, showAuthModal, isRegistering, authForm } = storeToRefs(authStore)
const { handleAuthClick, submitAuth, checkLoginStatus } = authStore

const { } = useAnalytics()
const { modelDisplayConfig, siteSettings, disabledModules, disabledModels, fetchModelDisplayConfig } = useModelConfig()

// 将 fetchModelDisplayConfig 提供给子组件使用，以便在打开模型前强制刷新数据
provide('fetchModelDisplayConfig', fetchModelDisplayConfig)

const showModel = ref(false)
const modelPage = ref('mechanical')
const panoRef = ref(null)
const currentModelData = ref(null)

const showSceneMenu = ref(false)

const isFullscreen = ref(false)
const activeTooltip = ref('')

const showTooltip = (type) => {
  activeTooltip.value = type
}

const hideTooltip = () => {
  activeTooltip.value = ''
}

const toggleFullscreen = () => {
  const krpano = panoRef.value?.getKrpano()
  if (krpano) {
    krpano.call('switch(fullscreen)')
  }
}

const enterVR = () => {
  const krpano = panoRef.value?.getKrpano()
  if (krpano) {
    krpano.call('webvr.enterVR()')
  }
}

// 监听 Krpano 抛出的全屏事件以同步状态
window.onPanoFullscreenChange = (state) => {
  isFullscreen.value = (state === 'true' || state === true)
}

const switchModelPage = (page) => {
  if (disabledModules.value.includes(page)) return
  modelPage.value = page
}

window.openThreeModel = async (modelId, modelName) => {
  console.log(`Krpano 传来的数据: ID=${modelId}, Name=${modelName}`)
  
  // 每次打开 3D 模型前，强制拉取最新的模型配置数据，保证前后台同步
  await fetchModelDisplayConfig()
  
  currentModelData.value = { id: modelId, name: modelName || '未知设备' }

  if (disabledModules.value.includes('mechanical')) {
    if (!disabledModules.value.includes('cube')) {
      modelPage.value = 'cube'
    } else {
      alert('3D模型展示功能暂未开放')
      return
    }
  } else {
    modelPage.value = 'mechanical'
  }

  showModel.value = true
}

window.onPanoSceneChanged = (sceneName) => {
  console.log('Krpano 场景已切换至:', sceneName)
}

const changeScene = (sceneName) => {
  const krpano = panoRef.value?.getKrpano()
  if (krpano) {
    krpano.call(`loadscene(${sceneName}, null, MERGE, BLEND(0.5))`)
    showSceneMenu.value = false // 切换后关闭菜单
  } else {
    console.warn("Krpano 尚未初始化完成")
  }
}

const openProductModel = async () => {
  if (window.openThreeModel) {
    await window.openThreeModel('device_001', '中央控制主机')
  }
}

// 监听全局点击事件，如果点击了控制面板外部，则关闭菜单
const closeSceneMenuOnOutsideClick = () => {
  if (showSceneMenu.value) {
    showSceneMenu.value = false
  }
}

onMounted(() => {
  checkLoginStatus()
  document.addEventListener('click', closeSceneMenuOnOutsideClick)
})

onUnmounted(() => {
  document.removeEventListener('click', closeSceneMenuOnOutsideClick)
})
</script>

<style>
body, html {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  font-family: Arial, sans-serif;
}
#app-container {
  width: 100vw;
  height: 100vh;
  position: relative;
}

/* 全局认证按钮 */
.global-auth-btn {
  position: absolute;
  top: 20px;
  right: 80px; /* 移到工具栏左侧 */
  background: rgba(15, 23, 42, 0.3);
  color: #38bdf8;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  z-index: 100;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  font-weight: bold;
}
.global-auth-btn:hover {
  background: rgba(15, 23, 42, 0.8);
  color: #7dd3fc;
  border-color: rgba(56, 189, 248, 0.5);
}

/* 右上角工具栏 (全屏 & VR) */
.toolbar-right {
  position: absolute;
  top: 20px;
  right: 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  z-index: 100;
}
.tool-btn {
  width: 40px;
  height: 40px;
  background: rgba(15, 23, 42, 0.3);
  border-radius: 8px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  transition: all 0.3s ease;
  position: relative;
}
.tool-btn img {
  width: 24px;
  height: 24px;
  object-fit: contain;
}
.tool-btn:hover {
  background: rgba(15, 23, 42, 0.8);
  transform: scale(1.05);
}
.tool-tooltip {
  position: absolute;
  right: 50px;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(15, 23, 42, 0.8);
  color: white;
  padding: 4px 10px;
  border-radius: 4px;
  font-size: 12px;
  white-space: nowrap;
  pointer-events: none;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}
.tool-tooltip::after {
  content: '';
  position: absolute;
  right: -5px;
  top: 50%;
  transform: translateY(-50%);
  border-width: 5px 0 5px 5px;
  border-style: solid;
  border-color: transparent transparent transparent rgba(15, 23, 42, 0.8);
}

/* 全局弹窗样式 */
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
.auth-switch {
  font-size: 12px;
  color: #38bdf8;
  text-align: right;
  margin-bottom: 15px;
  cursor: pointer;
  text-decoration: underline;
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

/* 演示控制面板的样式 */
.site-header {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 100;
  background: rgba(15, 23, 42, 0.3);
  padding: 8px 16px;
  border-radius: 8px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  transition: background-color 0.3s ease;
}
.site-header:hover {
  background: rgba(15, 23, 42, 0.8);
}
.site-link {
  display: flex;
  align-items: center;
  text-decoration: none;
  color: white;
  gap: 10px;
}
.site-logo {
  height: 30px;
  border-radius: 4px;
}
.site-title {
  font-size: 16px;
  font-weight: bold;
  letter-spacing: 1px;
}

.control-panel {
  position: absolute;
  bottom: 20px;
  left: 20px;
  background: rgba(15, 23, 42, 0.5);
  padding: 15px;
  border-radius: 12px;
  color: white;
  z-index: 100;
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,0.2);
  display: flex;
  flex-direction: column;
  gap: 12px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
  transition: background-color 0.3s ease;
}
.control-panel:hover {
  background: rgba(15, 23, 42, 0.85);
}
.control-panel .panel-title {
  font-size: 15px;
  font-weight: bold;
  margin-bottom: 5px;
  color: #38bdf8;
  text-align: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 8px;
}
.control-main-btns {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.control-main-btns .primary-btn {
  background: rgba(56, 189, 248, 0.15);
  border: 1px solid rgba(56, 189, 248, 0.4);
  color: #38bdf8;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: bold;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}
.control-main-btns .primary-btn:hover {
  background: rgba(56, 189, 248, 0.3);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(56, 189, 248, 0.2);
}

.scene-menu {
  position: absolute;
  left: calc(100% + 15px);
  bottom: 0;
  background: rgba(15, 23, 42, 0.85);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  padding: 15px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  backdrop-filter: blur(12px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
  min-width: 140px;
}
.scene-menu-title {
  font-size: 13px;
  color: #94a3b8;
  margin-bottom: 5px;
  text-align: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 5px;
}
.scene-menu button {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #cbd5e1;
  padding: 8px 15px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.scene-menu button:hover {
  background: rgba(56, 189, 248, 0.2);
  border-color: rgba(56, 189, 248, 0.5);
  color: #fff;
}

.slide-up-enter-active, .slide-up-leave-active {
  transition: all 0.3s ease;
}
.slide-up-enter-from, .slide-up-leave-to {
  opacity: 0;
  transform: translateX(-10px) scale(0.95);
}

.model-switcher {
  position: fixed;
  top: 30px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 10001;
  display: flex;
  gap: 0;
  background: rgba(15, 23, 42, 0.3);
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  transition: background-color 0.3s ease;
}
.model-switcher:hover {
  background: rgba(15, 23, 42, 0.8);
}
.model-switcher button {
  padding: 10px 28px;
  background: transparent;
  border: none;
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.25s;
  position: relative;
}
.model-switcher button:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.08);
}
.model-switcher button.active {
  color: #38bdf8;
  background: rgba(56, 189, 248, 0.15);
}
.model-switcher button.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 20%;
  width: 60%;
  height: 2px;
  background: #38bdf8;
  border-radius: 1px;
}
.model-switcher button:disabled {
  color: rgba(255, 255, 255, 0.25);
  cursor: not-allowed;
  background: transparent;
}
.model-switcher button:disabled:hover {
  color: rgba(255, 255, 255, 0.25);
  background: transparent;
}

/* 移动端适配 */
@media screen and (max-width: 768px) {
  .model-switcher {
    top: 15px; /* 往上抬，避免挡住下面的按钮 */
    transform: translateX(-50%) scale(0.9); /* 稍微缩小一点 */
  }
  .global-auth-btn {
    top: 60px;    /* 控制距离顶部的距离 */
    right: 270px;  /* 控制距离右侧的距离，默认为了避开全屏按钮是80px */
    padding: 6px 12px; /* 可以缩小按钮内边距 */
    font-size: 12px;   /* 可以缩小字体 */
  }
  .toolbar-right {
    top: 10px;   /* 控制距离顶部的距离 */
    right: 20px; /* 控制距离右侧的距离 */
    transform: scale(1); /* 如果觉得按钮在手机上太大，可以缩小它 */
    transform-origin: top right;
  }
  .site-header {
    top: 10px;
    left: 10px;
    padding: 6px 12px;
  }
  .site-logo {
    height: 24px;
  }
  .site-title {
    font-size: 14px;
  }

  .control-panel {
    bottom: 70px; /* 给 Krpano 默认工具栏留出空间 */
    left: 10px;
    padding: 10px;
    gap: 8px;
    transform: scale(0.9);
    transform-origin: left bottom;
  }
}
</style>
