<template>
  <div class="cube-modal">
    <!-- 左上角：功能按钮 -->
    <div class="top-left-btns">
      <button class="func-btn" @click="resetView">🔄 重置视角</button>
      <button class="func-btn" @click="showPartsList = !showPartsList">📋 模型列表</button>
    </div>

    <button class="close-btn" @click="$emit('close')">
      <span class="btn-icon">⬅</span> 返回全景展厅
    </button>

    <!-- 加载提示 -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-content">
        <div class="loading-spinner"></div>
        <div class="loading-text">3D模型加载中...</div>
        <div class="loading-progress">{{ loadingProgress }}%</div>
      </div>
    </div>

    <!-- 左侧可折叠模型列表 -->
    <transition name="slide-left">
      <div v-if="showPartsList" class="parts-sidebar">
        <div class="sidebar-title">模型列表</div>
        <div class="parts-list">
          <div
            v-for="part in partsList"
            :key="part.name"
            :class="['part-item', { active: modelName === part.name }]"
            @click="focusOnPart(part.name)"
          >
            <span class="part-icon">🧊</span>
            <span class="part-name">{{ part.label }}</span>
          </div>
        </div>
      </div>
    </transition>

    <div id="cube-container" ref="container"></div>

    <!-- 底部交互提示 -->
    <div class="bottom-hint">
      提示：双击部件查看详情，右键返回，鼠标拖拽旋转
    </div>

    <!-- 悬浮的动画控制入口按钮 -->
    <div class="anim-entry-btn" @click="showAnimPanel = true" v-if="!showAnimPanel">
      <img src="/images/动画控制.png" alt="动画控制" style="width: 24px; height: 24px;" />
      <span class="btn-text">动画控制</span>
    </div>

    <!-- 动画控制面板 -->
    <transition name="fade-slide">
      <div v-show="showAnimPanel" class="anim-panel">
        <div class="panel-header">
          <div class="panel-title">
            <img src="/images/动画控制.png" alt="动画控制" style="width: 20px; height: 20px;" />
            <span>动画控制</span>
          </div>
          <div class="header-actions">
            <div class="status-badge close" @click="resetAll" title="重置">
              ↺ 重置
            </div>
            <!-- 手机端才显示的关闭按钮 -->
            <div class="status-badge close mobile-only" @click="showAnimPanel = false">
              ✖
            </div>
          </div>
        </div>
        <div class="panel-body">
          <div class="anim-row">
            <span class="label">播放动画</span>
            <button :class="['toggle-btn', { active: isPlaying }]" @click="togglePlay">
              {{ isPlaying ? '暂停' : '播放' }}
            </button>
          </div>
          <div class="anim-row">
            <span class="label">选择动画</span>
            <select v-model="selectedAnim" @change="onAnimChange" class="anim-select">
              <option value="无">无</option>
              <option v-for="name in availableAnims" :key="name" :value="name">{{ name }}</option>
            </select>
          </div>
        </div>
      </div>
    </transition>

    <div class="bottom-right-area">
      <transition name="fade-slide">
        <div v-show="showInfoPanel" class="info-panel">
          <div class="panel-header">
            <div class="panel-title">
              <span class="icon">🔹</span>
              <span id="name">{{ modelName }}</span>
            </div>
            <div class="header-actions">
              <div class="status-badge download" @click="downloadModel" title="下载当前选中的 3D 模型">
                ⬇ 下载模型
              </div>
              <div class="status-badge close" @click="closeFocus" title="取消选中">
                ✖ 关闭
              </div>
            </div>
          </div>
          
          <div class="panel-body">
            <div class="data-row highlight">
              <span class="label">当前售价</span>
              <span class="value cyan">{{ modelParams.capacity }} <small>{{ modelParams.capacity_unit }}</small></span>
            </div>
            
            <div class="data-grid">
              <div class="data-item">
                <span class="label">上架日期</span>
                <span class="value">{{ modelParams.runtime }} {{ modelParams.runtime_unit }}</span>
              </div>
              <div class="data-item">
                <span class="label">好评率</span>
                <span class="value">{{ modelParams.speed }} {{ modelParams.speed_unit }}</span>
              </div>
              <div class="data-item">
                <span class="label">型号</span>
                <span class="value">{{ modelParams.model_type }}</span>
              </div>
              <div class="data-item">
                <span class="label">已售出</span>
                <span class="value">{{ modelParams.batch }}</span>
              </div>
            </div>
          </div>
        </div>
      </transition>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount, ref, computed, watch } from 'vue'
import * as THREE from 'three'
import { useModelViewer } from '../composables/useModelViewer'

const isPlaying = ref(false)
const selectedAnim = ref('无')
const availableAnims = ref([])
const showAnimPanel = ref(window.innerWidth > 768)
const emit = defineEmits(['close'])
const props = defineProps({
  disabledModels: { type: Array, default: () => [] },
  modelDisplayConfig: { type: Array, default: () => [] }
})

const {
  container,
  loading,
  loadingProgress,
  showInfoPanel,
  modelName,
  modelParams,
  showPartsList,
  ctx,
  interact,
  initBaseScene,
  getLoader,
  loadModelParams,
  downloadModel,
  onWindowResize,
  getPartFromObject
} = useModelViewer(props)

// 监听魔方页面独有的动画控制面板，保持互斥
watch(showAnimPanel, (val) => {
  if (val && window.innerWidth <= 768) {
    showPartsList.value = false
    showInfoPanel.value = false
  }
})
watch(showPartsList, (val) => {
  if (val && window.innerWidth <= 768) {
    showAnimPanel.value = false
  }
})
watch(showInfoPanel, (val) => {
  if (val && window.innerWidth <= 768) {
    showAnimPanel.value = false
  }
})

const partsList = computed(() => {
  const list = []
  if (!props.disabledModels.includes('魔方')) {
    list.push({ name: '魔方', label: '魔方', isBase: false })
  }
  return list
})

let mixer = null
const clock = new THREE.Clock()
const animationStore = { actions: {}, currentAction: null }

const togglePlay = () => {
  isPlaying.value = !isPlaying.value
  updateAnimationPlay()
}

const onAnimChange = () => {
  updateAnimationPlay()
}

const resetAll = () => {
  if (animationStore.currentAction) {
    animationStore.currentAction.stop()
    animationStore.currentAction = null
  }
  isPlaying.value = false
  selectedAnim.value = '无'
  if (interact.liftedPart) {
    startReturnAnimation()
  }
  interact.isInFocusMode = false
  interact.isFocusing = false
  interact.focusTarget = null
  ctx.outlinePass.selectedObjects = []
  showAllParts()
}

function updateAnimationPlay() {
  if (animationStore.currentAction) {
    animationStore.currentAction.stop()
    animationStore.currentAction = null
  }
  if (!isPlaying.value || selectedAnim.value === '无') return
  const act = animationStore.actions[selectedAnim.value]
  if (act) {
    animationStore.currentAction = act
    act.play()
  }
}

const resetView = () => {
  resetAll()
  if (ctx.camera && ctx.controls) {
    ctx.camera.position.set(0, 3, 9)
    ctx.controls.target.set(0, 0, 0)
    ctx.controls.update()
  }
}

const focusOnPart = (partName) => {
  const part = ctx.allParts.find(p => p.name === partName)
  if (!part) return

  if (interact.isInFocusMode || interact.isFocusing) {
    resetAll()
    setTimeout(() => {
      simulatePartClick(part)
    }, 500)
  } else {
    simulatePartClick(part)
  }
}

const simulatePartClick = (part) => {
  modelName.value = part.name
  showLiftedPart(part)
  interact.focusTarget = interact.liftedPart
  interact.isFocusing = true
  interact.focusT = 0
  interact.cameraStartPos.copy(ctx.camera.position)
  interact.controlsStartTarget.copy(ctx.controls.target)
  interact.focusBox.setFromObject(interact.focusTarget)
  interact.focusBox.getCenter(interact.focusCenter)
  interact.focusBox.getSize(interact.focusSize)
  const maxDim = Math.max(interact.focusSize.x, interact.focusSize.y, interact.focusSize.z)
  interact.focusDistance = maxDim * 1.5
  const currentDir = new THREE.Vector3().subVectors(ctx.camera.position, interact.focusCenter).normalize()
  currentDir.y = 0
  if (currentDir.lengthSq() < 0.001) currentDir.set(0, 0, 1)
  currentDir.normalize()
  interact.cameraHorizontalOffset.copy(currentDir).multiplyScalar(interact.focusDistance)
  interact.cameraTargetPos.copy(interact.focusCenter).add(interact.cameraHorizontalOffset)
  interact.cameraTargetPos.y = interact.focusCenter.y + interact.focusDistance * 0.2
  ctx.outlinePass.selectedObjects = [interact.focusTarget]
}

onMounted(() => {
  initThreeJS()
})

onBeforeUnmount(() => {
  if (mixer) mixer.stopAllAction()
  window.removeEventListener('dblclick', onDoubleClick)
  window.removeEventListener('contextmenu', onRightClick)
})

function initThreeJS() {
  initBaseScene()

  const loader = getLoader()
  if (!props.disabledModels.includes('魔方')) {
    loader.load('/static/魔方.glb', (gltf) => {
      const model = gltf.scene
      model.name = '魔方'
      model.scale.set(10, 10, 10)
      model.position.set(0, 1.5, 0)
      model.traverse(c => {
        if (c.isMesh) {
          c.castShadow = true
          c.receiveShadow = true
        }
      })
      ctx.scene.add(model)
      ctx.allParts.push(model)
      // 遍历模型动画，获取动画和动画名称
      mixer = new THREE.AnimationMixer(model)
      gltf.animations.forEach(clip => {
        animationStore.actions[clip.name] = mixer.clipAction(clip)
        availableAnims.value.push(clip.name)
      })
    })
  }

  window.addEventListener('dblclick', onDoubleClick)
  window.addEventListener('contextmenu', onRightClick)
  window.addEventListener('resize', onWindowResize)

  animate()
}

function showLiftedPart(selectedPart) {
  if (interact.liftedPart) {
    interact.liftedPart.position.copy(interact.liftedOriginalPos)
    interact.liftedPart.quaternion.copy(interact.liftedOriginalQuat)
  }
  interact.liftedPart = selectedPart
  interact.liftedOriginalPos.copy(interact.liftedPart.position)
  interact.liftedOriginalQuat.copy(interact.liftedPart.quaternion)

  interact.focusBox.setFromObject(interact.liftedPart)
  interact.focusBox.getSize(interact.focusSize)
  const standTopY = 0.35 + 0.35
  interact.liftedBaseY = standTopY + 1.6 + interact.focusSize.y * 0.5
  interact.liftedStartPos.copy(interact.liftedOriginalPos)
  interact.liftedTargetPos.set(0, interact.liftedBaseY, -0.8)
  interact.liftedPart.position.copy(interact.liftedStartPos)
  interact.liftedPart.updateMatrixWorld(true)
}

function showAllParts() {
  if (interact.liftedPart) {
    interact.liftedPart.position.copy(interact.liftedOriginalPos)
    interact.liftedPart.quaternion.copy(interact.liftedOriginalQuat)
    interact.liftedPart.updateMatrixWorld(true)
    interact.liftedPart = null
    interact.liftedBaseY = 0
  }
  for (const part of ctx.allParts) {
    part.visible = true
  }
}

function startReturnAnimation() {
  if (!interact.liftedPart || interact.isReturning) return
  interact.isFocusing = false
  interact.isInFocusMode = false
  interact.isReturning = true
  interact.focusT = 0
  interact.liftedReturnStartPos.copy(interact.liftedPart.position)
  interact.cameraStartPos.copy(ctx.camera.position)
  interact.controlsStartTarget.copy(ctx.controls.target)
  interact.focusTarget = interact.liftedPart
  ctx.outlinePass.selectedObjects = [interact.liftedPart]
}

function onDoubleClick(e) {
  e.preventDefault()
  if (interact.isFocusing || interact.isInFocusMode || interact.isReturning) return

  ctx.mouse.x = (e.clientX / window.innerWidth) * 2 - 1
  ctx.mouse.y = -(e.clientY / window.innerHeight) * 2 + 1
  ctx.raycaster.setFromCamera(ctx.mouse, ctx.camera)

  const intersects = ctx.raycaster.intersectObjects(ctx.scene.children, true)
  if (intersects.length > 0) {
    let selectedPart = null
    const basePart = ctx.allParts[0] || null
    for (const hit of intersects) {
      const candidatePart = getPartFromObject(hit.object)
      if (!candidatePart) continue
      if (candidatePart !== basePart) {
        selectedPart = candidatePart
        break
      }
      if (!selectedPart) {
        selectedPart = candidatePart
      }
    }
    if (!selectedPart) {
      ctx.outlinePass.selectedObjects = []
      return
    }

    showLiftedPart(selectedPart)
    interact.focusTarget = interact.liftedPart

    interact.isFocusing = true
    interact.focusT = 0
    interact.cameraStartPos.copy(ctx.camera.position)
    interact.controlsStartTarget.copy(ctx.controls.target)

    interact.focusBox.setFromObject(interact.focusTarget)
    interact.focusBox.getCenter(interact.focusCenter)
    interact.focusBox.getSize(interact.focusSize)

    interact.focusDistance = Math.max(interact.focusSize.length() * 2.0, 4.8)
    interact.cameraHorizontalOffset.subVectors(ctx.camera.position, ctx.controls.target)
    interact.cameraHorizontalOffset.y = 0
    if (interact.cameraHorizontalOffset.lengthSq() < 0.0001) {
      interact.cameraHorizontalOffset.set(0, 0, interact.focusDistance)
    } else {
      interact.cameraHorizontalOffset.normalize().multiplyScalar(interact.focusDistance)
    }
    interact.cameraTargetPos.copy(interact.focusCenter).add(interact.cameraHorizontalOffset)
    interact.cameraTargetPos.y = interact.focusCenter.y

    ctx.outlinePass.selectedObjects = [interact.focusTarget]
    
    showInfoPanel.value = true
    modelName.value = selectedPart.name || '魔方部件'
    loadModelParams(selectedPart.name)
  }
}

function closeFocus() {
  if (interact.liftedPart) {
    startReturnAnimation()
  }
  showInfoPanel.value = false
}

function onRightClick(e) {
  e.preventDefault()
  if (interact.liftedPart) {
    startReturnAnimation()
    return
  }
  interact.isFocusing = false
  interact.isInFocusMode = false
  interact.focusTarget = null
  ctx.outlinePass.selectedObjects = []
  showAllParts()
}

function updateLiftedPartFloat() {
  if (!interact.liftedPart || !interact.isInFocusMode) return
  interact.liftedPart.position.y = interact.liftedBaseY + Math.sin(performance.now() * 0.003) * 0.08
  interact.liftedPart.updateMatrixWorld(true)
  interact.focusBox.setFromObject(interact.liftedPart)
  interact.focusBox.getCenter(interact.focusCenter)
  if (interact.focusTarget === interact.liftedPart) {
    ctx.controls.target.lerp(interact.focusCenter, 0.08)
    ctx.outlinePass.selectedObjects = [interact.liftedPart]
  }
}

function animate() {
  ctx.animationId = requestAnimationFrame(animate)
  ctx.controls.update()

  const delta = clock.getDelta()
  if (mixer && animationStore.currentAction) {
    mixer.update(delta)
  }

  if (interact.isFocusing && interact.focusTarget) {
    interact.focusT += 0.02
    if (interact.focusT > 1) interact.focusT = 1

    if (interact.liftedPart) {
      interact.liftedPart.position.lerpVectors(interact.liftedStartPos, interact.liftedTargetPos, interact.focusT)
      interact.liftedPart.updateMatrixWorld(true)
    }

    interact.focusBox.setFromObject(interact.focusTarget)
    interact.focusBox.getCenter(interact.focusCenter)
    interact.currentFocusCameraPos.copy(interact.focusCenter).add(interact.cameraHorizontalOffset)
    interact.currentFocusCameraPos.y = interact.focusCenter.y
    ctx.camera.position.lerpVectors(interact.cameraStartPos, interact.currentFocusCameraPos, interact.focusT)
    ctx.controls.target.lerpVectors(interact.controlsStartTarget, interact.focusCenter, interact.focusT)

    if (interact.focusT >= 1) {
      if (interact.liftedPart) interact.liftedPart.position.copy(interact.liftedTargetPos)
      interact.isFocusing = false
      interact.isInFocusMode = true
    }
  }

  if (interact.isReturning && interact.liftedPart) {
    interact.focusT += 0.028
    if (interact.focusT > 1) interact.focusT = 1
    const easedT = 1 - Math.pow(1 - interact.focusT, 3)
    interact.liftedPart.position.lerpVectors(interact.liftedReturnStartPos, interact.liftedOriginalPos, easedT)
    interact.liftedPart.updateMatrixWorld(true)
    ctx.outlinePass.selectedObjects = [interact.liftedPart]
    ctx.camera.position.lerpVectors(interact.cameraStartPos, new THREE.Vector3(0, 3, 9), easedT)
    ctx.controls.target.lerpVectors(interact.controlsStartTarget, new THREE.Vector3(0, 0, 0), easedT)

    if (interact.focusT >= 1) {
      showAllParts()
      interact.isReturning = false
      interact.focusTarget = null
      ctx.outlinePass.selectedObjects = []
      showInfoPanel.value = false
    }
  }

  updateLiftedPartFloat()
  ctx.composer.render()
}
</script>

<style scoped>
.cube-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.85);
  z-index: 9999;
}
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10001;
}
.loading-content {
  text-align: center;
  color: #fff;
}
.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid rgba(255, 255, 255, 0.2);
  border-top-color: #06b6d4;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}
.loading-text {
  font-size: 16px;
  color: #94a3b8;
  margin-bottom: 8px;
}
.loading-progress {
  font-size: 28px;
  font-weight: 700;
  color: #06b6d4;
  font-family: 'Courier New', monospace;
}
#cube-container {
  width: 100%;
  height: 100%;
}
.top-left-btns {
  position: absolute;
  top: 30px;
  left: 30px;
  z-index: 10000;
  display: flex;
  gap: 8px;
}
.func-btn {
  padding: 8px 16px;
  background: rgba(15, 23, 42, 0.7);
  color: rgba(255, 255, 255, 0.85);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  cursor: pointer;
  font-size: 13px;
  backdrop-filter: blur(10px);
  transition: all 0.2s;
  white-space: nowrap;
}
.func-btn:hover {
  background: rgba(30, 41, 59, 0.85);
  color: #fff;
  border-color: rgba(255, 255, 255, 0.4);
}
.parts-sidebar {
  position: absolute;
  top: 72px;
  left: 30px;
  width: 180px;
  max-height: calc(100vh - 140px);
  background: rgba(15, 23, 42, 0.85);
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 10px;
  backdrop-filter: blur(12px);
  z-index: 10000;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
.sidebar-title {
  padding: 12px 16px;
  font-size: 13px;
  font-weight: 600;
  color: #94a3b8;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  letter-spacing: 1px;
}
.parts-list {
  overflow-y: auto;
  padding: 6px 0;
  flex: 1;
}
.parts-list::-webkit-scrollbar {
  width: 4px;
}
.parts-list::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.15);
  border-radius: 2px;
}
.part-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  cursor: pointer;
  transition: all 0.15s;
  color: rgba(255, 255, 255, 0.65);
  font-size: 13px;
}
.part-item:hover {
  background: rgba(255, 255, 255, 0.06);
  color: #fff;
}
.part-item.active {
  background: rgba(6, 182, 212, 0.12);
  color: #22d3ee;
}
.part-icon {
  font-size: 14px;
  flex-shrink: 0;
}
.part-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.slide-left-enter-active,
.slide-left-leave-active {
  transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}
.slide-left-enter-from,
.slide-left-leave-to {
  opacity: 0;
  transform: translateX(-12px);
}

.close-btn {
  position: absolute;
  top: 30px;
  right: 30px;
  z-index: 10000;
  padding: 10px 24px;
  background: rgba(15, 23, 42, 0.7);
  color: #fff;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 500;
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}
.close-btn:hover {
  background: rgba(30, 41, 59, 0.85);
  border-color: rgba(255, 255, 255, 0.4);
  transform: translateY(-2px);
}
.btn-icon {
  font-size: 18px;
}

.bottom-hint {
  position: absolute;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 10000;
  padding: 6px 20px;
  background: rgba(15, 23, 42, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 20px;
  backdrop-filter: blur(8px);
  font-size: 12px;
  color: rgba(255, 255, 255, 0.35);
  pointer-events: none;
  white-space: nowrap;
}

.anim-entry-btn {
  display: none; /* 电脑端默认隐藏，直接显示面板 */
}
.mobile-only {
  display: none;
}

.anim-panel {
  position: absolute;
  bottom: 24px;
  left: 24px;
  transform: none;
  background: rgba(15, 23, 42, 0.85);
  border: 1px solid rgba(148, 163, 184, 0.2);
  backdrop-filter: blur(12px);
  border-radius: 12px;
  padding: 16px 24px;
  color: #f8fafc;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  white-space: nowrap;
  z-index: 9999;
  pointer-events: auto;
}
.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 10px;
}
.panel-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
}
.header-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}
.status-badge {
  padding: 6px 10px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
  cursor: pointer;
  user-select: none;
  transition: all 0.2s;
}
.status-badge.download {
  background-color: rgba(6, 182, 212, 0.15);
  color: #22d3ee;
  border: 1px solid rgba(6, 182, 212, 0.3);
}
.status-badge.download:hover {
  background-color: rgba(6, 182, 212, 0.3);
  transform: translateY(-1px);
}
.status-badge.download:active {
  transform: translateY(0);
}
.status-badge.close {
  background-color: rgba(239, 68, 68, 0.15);
  color: #f87171;
  border: 1px solid rgba(239, 68, 68, 0.3);
}
.status-badge.close:hover {
  background-color: rgba(239, 68, 68, 0.3);
}
.anim-panel .panel-body {
  display: flex;
  flex-direction: row;
  gap: 20px;
  align-items: center;
}
.anim-row {
  display: flex;
  align-items: center;
  gap: 10px;
}
.anim-row .label {
  color: #94a3b8;
  font-size: 14px;
}
.toggle-btn {
  padding: 6px 16px;
  border-radius: 4px;
  font-size: 13px;
  font-weight: bold;
  cursor: pointer;
  background: rgba(255, 255, 255, 0.1);
  color: #94a3b8;
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.2s;
}
.toggle-btn.active {
  background: rgba(56, 189, 248, 0.2);
  color: #38bdf8;
  border-color: rgba(56, 189, 248, 0.4);
}
.anim-select {
  padding: 6px 12px;
  border-radius: 4px;
  font-size: 13px;
  background: rgba(255, 255, 255, 0.1);
  color: #f8fafc;
  border: 1px solid rgba(255, 255, 255, 0.2);
  cursor: pointer;
  outline: none;
}
.anim-select option {
  background: #1e293b;
  color: #f8fafc;
}

.bottom-right-area {
  position: absolute;
  bottom: 40px;
  right: 100px;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 16px;
  z-index: 9999;
  pointer-events: none;
}
.bottom-right-area > * {
  pointer-events: auto;
}

.info-panel {
  width: 320px;
  background: rgba(15, 23, 42, 0.85);
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 12px;
  padding: 20px;
  color: #f8fafc;
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
}

.info-panel .panel-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 15px;
}

.info-panel .panel-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.info-panel .header-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.info-panel .status-badge {
  padding: 6px 10px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
  letter-spacing: 1px;
  cursor: pointer;
  user-select: none;
  transition: all 0.2s;
}
.info-panel .status-badge.download {
  background-color: rgba(6, 182, 212, 0.15);
  color: #22d3ee;
  border: 1px solid rgba(6, 182, 212, 0.3);
}
.info-panel .status-badge.download:hover {
  background-color: rgba(6, 182, 212, 0.3);
  transform: translateY(-1px);
}
.info-panel .status-badge.download:active {
  transform: translateY(0);
}

.info-panel .status-badge.close {
  background-color: rgba(239, 68, 68, 0.15);
  color: #f87171;
  border: 1px solid rgba(239, 68, 68, 0.3);
}
.info-panel .status-badge.close:hover {
  background-color: rgba(239, 68, 68, 0.3);
  transform: translateY(-1px);
}
.info-panel .status-badge.close:active {
  transform: translateY(0);
}

.info-panel .data-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 20px;
}
.info-panel .data-row .label {
  color: #94a3b8;
  font-size: 14px;
}
.info-panel .data-row .value {
  font-size: 36px;
  font-weight: 700;
  font-family: 'Courier New', Courier, monospace;
}
.info-panel .value.cyan { color: #06b6d4; }
.info-panel .value small { font-size: 16px; color: #94a3b8; }

.info-panel .data-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  background: rgba(0, 0, 0, 0.2);
  padding: 16px;
  border-radius: 8px;
}

.info-panel .data-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.info-panel .data-item .label {
  font-size: 12px;
  color: #64748b;
  text-transform: uppercase;
}
.info-panel .data-item .value {
  font-size: 15px;
  font-weight: 500;
  color: #e2e8f0;
}

.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}
.fade-slide-enter-from,
.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}
@media screen and (max-width: 768px) {
  .top-left-btns {
    top: 80px;
    left: 10px;
    flex-wrap: wrap;
    gap: 5px;
  }
  .func-btn {
    padding: 6px 10px;
    font-size: 12px;
  }
  .close-btn {
    top: 80px;
    right: 10px;
    padding: 6px 12px;
    font-size: 13px;
  }
  .parts-sidebar {
    top: 130px;
    left: 10px;
    width: 140px;
    max-height: calc(100vh - 250px);
  }
  .anim-entry-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: absolute;
    right: 20px;
    bottom: 140px; /* 和主页留言墙悬浮按钮位置一致 */
    width: 60px;
    height: 60px;
    background: rgba(15, 23, 42, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    color: #38bdf8;
    z-index: 10000;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(10px);
    cursor: pointer;
  }
  .mobile-only {
    display: block;
  }
  .anim-entry-btn .icon {
    font-size: 20px;
  }
  .anim-entry-btn .btn-text {
    font-size: 10px;
    margin-top: 2px;
    color: #38bdf8;
  }
  .anim-panel {
    top: auto;
    bottom: 70px; 
    left: auto;
    right: 85px;
    width: 230px; 
    padding: 10px 15px;
    transform: none; 
    transform-origin: bottom right;
  }
  .anim-panel .panel-body {
    flex-direction: column; /* 竖向排列 */
    gap: 10px;
    justify-content: flex-start;
  }
  .bottom-right-area {
    bottom: 70px;
    right: 170px;
    gap: 10px;
    transform: scale(0.5);
    transform-origin: bottom right;
  }
  .bottom-hint {
    display: none; /* 手机端隐藏底部提示条 */
  }
}
</style>
