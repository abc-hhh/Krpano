<template>
  <div class="three-modal">
    <!-- 左上角：功能按钮 -->
    <div class="top-left-btns">
      <button class="func-btn" @click="resetView">🔄 重置视角</button>
      <button class="func-btn" @click="showPartsList = !showPartsList">📋 模型列表</button>
    </div>

    <!-- 动画控制面板 -->
    <transition name="slide-left">
      <div v-if="hasAnimation" class="anim-panel">
        <div class="anim-panel-title">🎬 动画控制</div>
        <div class="anim-panel-body">
          <div class="anim-row">
            <label class="anim-label">选择动画</label>
            <select
              class="anim-select"
              :value="animationState.selectedAnim"
              @change="onAnimSelectChange($event.target.value)"
            >
              <option
                v-for="name in animationState.availableAnims"
                :key="name"
                :value="name"
              >{{ name }}</option>
            </select>
          </div>
          <div class="anim-row">
            <button class="anim-play-btn" @click="toggleAnimation">
              <span v-if="animationState.isPlaying">⏸ 暂停</span>
              <span v-else>▶ 播放</span>
            </button>
          </div>
        </div>
      </div>
    </transition>

    <!-- 右上角：全景按钮（保持不变） -->
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
            <span class="part-icon">⚙</span>
            <span class="part-name">{{ part.label }}</span>
          </div>
        </div>
      </div>
    </transition>

    <!-- Three.js 挂载容器 -->
    <div id="three-container" ref="container"></div>

    <!-- 底部交互提示 -->
    <div class="bottom-hint">
      提示：双击零件查看详情，右键返回，鼠标拖拽旋转
    </div>

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
import { onMounted, onBeforeUnmount, computed } from 'vue'
import * as THREE from 'three'
import TWEEN from 'three/examples/jsm/libs/tween.module.js'
import { useModelViewer } from '../composables/useModelViewer'

const emit = defineEmits(['close'])
const props = defineProps({
  modelData: { type: Object, default: null },
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
  hasAnimation,
  animationState,
  animCtx,
  ctx,
  interact,
  initBaseScene,
  getLoader,
  loadModelParams,
  downloadModel,
  onWindowResize,
  getPartFromObject,
  registerAnimations,
  toggleAnimation,
  onAnimSelectChange,
  updateAnimationMixer
} = useModelViewer(props)

const partsList = computed(() => {
  const list = []
  for (let i = 1; i <= 18; i++) {
    const key = `机械零件01-${i}`
    if (!props.disabledModels.includes(key)) {
      list.push({ name: key, label: `零件 ${i}`, isBase: false })
    }
  }
  return list
})

const closeFocus = () => {
  if (interact.isInFocusMode && !interact.isReturning) {
    interact.isInFocusMode = false;
    interact.isReturning = true;
    interact.focusT = 0;
    interact.liftedReturnStartPos.copy(interact.liftedPart.position);
    interact.cameraStartPos.copy(ctx.camera.position);
    interact.controlsStartTarget.copy(ctx.controls.target);
    showInfoPanel.value = false;
    ctx.outlinePass.selectedObjects = [];
  }
}

const resetView = () => {
  closeFocus()
  if (ctx.camera && ctx.controls) {
    ctx.camera.position.set(0, 3, 9)
    ctx.controls.target.set(0, 0, 0)
    ctx.controls.update()
  }
}

const focusOnPart = (partName) => {
  const part = ctx.allParts.find(p => p.name === partName)
  if (!part) return
  if (part.userData.isBase) return

  if (interact.isInFocusMode || interact.isFocusing) {
    closeFocus()
    setTimeout(() => {
      simulatePartClick(part)
    }, 500)
  } else {
    simulatePartClick(part)
  }
}

const simulatePartClick = (part) => {
  modelName.value = part.name
  loadModelParams(part.name)
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
  window.removeEventListener('dblclick', onDoubleClick)
  window.removeEventListener('contextmenu', onRightClick)
})

function initThreeJS() {
  //   初始化基础场景、相机与光照
  initBaseScene()
  
  const loader = getLoader()
  
  //   加载底座模型
  if (!props.disabledModels.includes('机械零件01-底座')) {
    loader.load('/static/机械零件01-底座.glb', (gltf) => {
      const model = gltf.scene;
      model.name = '机械零件01-底座';
      model.userData.isBase = true;
      model.position.set(-0.2, 0.8, 0);
      model.traverse(c => {
        if (c.isMesh) {
          c.castShadow = true;
          c.receiveShadow = true;
        }
      });
      ctx.scene.add(model);
      ctx.allParts.push(model);
    });
  }

  //   遍历加载各个零件模型并注册动画
  for(let i=1; i<=18; i++) {
      const modelKey = `机械零件01-${i}`;
      if (props.disabledModels.includes(modelKey)) continue;
      loader.load(`/static/机械零件01-${i}.glb`, (gltf) => {
        const model = gltf.scene;
        model.name = `机械零件01-${i}`;
        model.userData.isBase = false;
        model.position.set(-0.2, 0.8, 0);
        model.traverse(c => {
          if (c.isMesh) {
            c.castShadow = true;
            c.receiveShadow = true;
          }
        });
        ctx.scene.add(model);
        ctx.allParts.push(model);
        registerAnimations(gltf);
      });
  }

  //   绑定鼠标交互事件
  window.addEventListener('dblclick', onDoubleClick);
  window.addEventListener('contextmenu', onRightClick);
  window.addEventListener('resize', onWindowResize);

  //   启动渲染循环
  animate();
}

function showLiftedPart(part) {
  if (interact.liftedPart) resetLiftedPart();
  interact.liftedPart = part;
  interact.liftedOriginalPos.copy(part.position);
  interact.liftedOriginalQuat.copy(part.quaternion);
  interact.focusBox.setFromObject(part);
  interact.liftedBaseY = interact.focusBox.max.y;
  interact.liftedStartPos.copy(part.position);
  interact.liftedTargetPos.copy(part.position);
  interact.liftedTargetPos.y += (interact.liftedBaseY + 0.3 - part.position.y);
}

function resetLiftedPart() {
  if (interact.liftedPart) {
    interact.liftedPart.position.copy(interact.liftedOriginalPos);
    interact.liftedPart.quaternion.copy(interact.liftedOriginalQuat);
    interact.liftedPart = null;
  }
}

function onRightClick(e) {
  e.preventDefault();
  closeFocus();
}

function onDoubleClick(e) {
  e.preventDefault();
  if (interact.isFocusing || interact.isInFocusMode || interact.isReturning) return;

  //   射线检测计算鼠标点击位置的 3D 坐标
  ctx.mouse.x = (e.clientX / window.innerWidth) * 2 - 1;
  ctx.mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;
  ctx.raycaster.setFromCamera(ctx.mouse, ctx.camera);

  //   获取相交的 3D 对象
  const intersects = ctx.raycaster.intersectObjects(ctx.scene.children, true);
  if (intersects.length > 0) {
    let selectedPart = null;
    for (const hit of intersects) {
      const candidatePart = getPartFromObject(hit.object);
      if (!candidatePart) continue;
      if (!candidatePart.userData.isBase) {
        selectedPart = candidatePart;
        break;
      }
    }
    if (!selectedPart) {
      ctx.outlinePass.selectedObjects = [];
      return;
    }

    //   触发选中状态并加载对应参数
    modelName.value = selectedPart.name;
    loadModelParams(selectedPart.name);
    
    //   启动零件悬浮展示动画
    showLiftedPart(selectedPart);
    interact.focusTarget = interact.liftedPart;

    interact.isFocusing = true;
    interact.focusT = 0;
    interact.cameraStartPos.copy(ctx.camera.position);
    interact.controlsStartTarget.copy(ctx.controls.target);

    interact.focusBox.setFromObject(interact.focusTarget);
    interact.focusBox.getCenter(interact.focusCenter);
    interact.focusBox.getSize(interact.focusSize);

    const maxDim = Math.max(interact.focusSize.x, interact.focusSize.y, interact.focusSize.z);
    interact.focusDistance = maxDim * 1.5;

    const currentDir = new THREE.Vector3().subVectors(ctx.camera.position, interact.focusCenter).normalize();
    currentDir.y = 0;
    if (currentDir.lengthSq() < 0.001) currentDir.set(0, 0, 1);
    currentDir.normalize();

    interact.cameraHorizontalOffset.copy(currentDir).multiplyScalar(interact.focusDistance);
    interact.cameraTargetPos.copy(interact.focusCenter).add(interact.cameraHorizontalOffset);
    interact.cameraTargetPos.y = interact.focusCenter.y + interact.focusDistance * 0.2;

    ctx.outlinePass.selectedObjects = [interact.focusTarget];
  }
}

function updateTagPosition() {}

function animate() {
  ctx.animationId = requestAnimationFrame(animate);
  TWEEN.update();
  updateAnimationMixer();

  if (interact.isFocusing) {
    interact.focusT += 0.02;
    if (interact.focusT >= 1) {
      interact.focusT = 1;
      interact.isFocusing = false;
      interact.isInFocusMode = true;
      showInfoPanel.value = true;
    }
    const t = 1 - Math.pow(1 - interact.focusT, 3);
    if (interact.liftedPart) {
      interact.liftedPart.position.lerpVectors(interact.liftedStartPos, interact.liftedTargetPos, t);
    }
    interact.focusBox.setFromObject(interact.focusTarget);
    interact.focusBox.getCenter(interact.focusCenter);
    interact.currentFocusCameraPos.copy(interact.focusCenter).add(interact.cameraHorizontalOffset);
    interact.currentFocusCameraPos.y = interact.focusCenter.y + interact.focusDistance * 0.2;
    ctx.camera.position.lerpVectors(interact.cameraStartPos, interact.currentFocusCameraPos, t);
    ctx.controls.target.lerpVectors(interact.controlsStartTarget, interact.focusCenter, t);
  } else if (interact.isReturning) {
    interact.focusT += 0.02;
    if (interact.focusT >= 1) {
      interact.focusT = 1;
      interact.isReturning = false;
      resetLiftedPart();
    }
    const t = 1 - Math.pow(1 - interact.focusT, 3);
    if (interact.liftedPart) {
      interact.liftedPart.position.lerpVectors(interact.liftedReturnStartPos, interact.liftedOriginalPos, t);
    }
    ctx.camera.position.lerpVectors(interact.cameraStartPos, new THREE.Vector3(0, 3, 9), t);
    ctx.controls.target.lerpVectors(interact.controlsStartTarget, new THREE.Vector3(0, 0, 0), t);
  } else if (interact.isInFocusMode && interact.focusTarget) {
    interact.focusBox.setFromObject(interact.focusTarget);
    interact.focusBox.getCenter(interact.focusCenter);
    ctx.controls.target.lerp(interact.focusCenter, 0.1);
  }

  updateTagPosition();
  ctx.controls.update();
  ctx.composer.render();
}
</script>

<style scoped>
.three-modal {
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
#three-container {
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
  -webkit-backdrop-filter: blur(10px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  gap: 8px;
}
.close-btn:hover {
  background: rgba(30, 41, 59, 0.85);
  border-color: rgba(255, 255, 255, 0.4);
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}
.close-btn:active {
  transform: translateY(0);
}
.btn-icon {
  font-size: 18px;
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

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 15px;
}

.panel-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 600;
  letter-spacing: 0.5px;
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
  letter-spacing: 1px;
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
  transform: translateY(-1px);
}
.status-badge.close:active {
  transform: translateY(0);
}

.data-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 20px;
}
.data-row .label {
  color: #94a3b8;
  font-size: 14px;
}
.data-row .value {
  font-size: 36px;
  font-weight: 700;
  font-family: 'Courier New', Courier, monospace;
}
.value.cyan { color: #06b6d4; }
.value small { font-size: 16px; color: #94a3b8; }

.data-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  background: rgba(0, 0, 0, 0.2);
  padding: 16px;
  border-radius: 8px;
}

.data-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.data-item .label {
  font-size: 12px;
  color: #64748b;
  text-transform: uppercase;
}
.data-item .value {
  font-size: 15px;
  font-weight: 500;
  color: #e2e8f0;
}

/* 动画过渡 */
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}
.fade-slide-enter-from,
.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}

.anim-panel {
  position: absolute;
  top: 72px;
  left: 30px;
  width: 200px;
  background: rgba(15, 23, 42, 0.85);
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 10px;
  backdrop-filter: blur(12px);
  z-index: 10000;
  overflow: hidden;
}
.anim-panel-title {
  padding: 10px 16px;
  font-size: 13px;
  font-weight: 600;
  color: #94a3b8;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  letter-spacing: 1px;
}
.anim-panel-body {
  padding: 12px 16px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.anim-row {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.anim-label {
  font-size: 12px;
  color: #64748b;
}
.anim-select {
  width: 100%;
  padding: 6px 8px;
  border-radius: 6px;
  background: rgba(30, 41, 59, 0.8);
  color: #e2e8f0;
  border: 1px solid rgba(148, 163, 184, 0.2);
  font-size: 13px;
  outline: none;
  cursor: pointer;
}
.anim-select:focus {
  border-color: rgba(6, 182, 212, 0.5);
}
.anim-play-btn {
  width: 100%;
  padding: 8px 0;
  border: none;
  border-radius: 6px;
  background: rgba(6, 182, 212, 0.15);
  color: #22d3ee;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid rgba(6, 182, 212, 0.3);
}
.anim-play-btn:hover {
  background: rgba(6, 182, 212, 0.25);
}

.anim-entry-btn {
  position: absolute;
  bottom: 140px; /* 和联系客服错开 */
  right: 20px;
  background: rgba(15, 23, 42, 0.85);
  backdrop-filter: blur(8px);
  padding: 10px 16px;
  border-radius: 30px;
  display: flex;
  align-items: center;
  gap: 8px;
  color: white;
  font-size: 14px;
  cursor: pointer;
  z-index: 90;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.3s ease;
}

.anim-entry-btn:hover {
  background: rgba(30, 41, 59, 0.95);
  transform: translateY(-2px);
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
    max-height: calc(100vh - 200px);
  }
  .anim-panel {
    top: auto;
    bottom: 20px;
    left: 10px;
    right: auto;
    width: 320px;
    max-height: 44vh;
    overflow-y: auto;
    padding: 15px;
    transform: scale(0.75);
    transform-origin: bottom left;
  }
  .anim-panel .panel-body {
    flex-direction: column;
    gap: 10px;
    justify-content: flex-start;
  }
  .bottom-right-area {
    bottom: 70px;
    left: 10px;
    right: auto;
    gap: 10px;
    transform: scale(0.5);
    transform-origin: bottom left;
  }
  .info-panel {
    width: 360px;
    max-height: 44vh;
    overflow-y: auto;
  }
  .bottom-hint {
    display: none; /* 手机端隐藏底部提示条 */
  }
}
</style>