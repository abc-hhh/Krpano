import { ref, reactive, onBeforeUnmount, watch } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
import { OutlinePass } from 'three/examples/jsm/postprocessing/OutlinePass.js'

export function useModelViewer(props) {
  const container = ref(null)
  const loading = ref(true)
  const loadingProgress = ref(0)
  const showInfoPanel = ref(false)
  const modelName = ref('')
  const modelParams = ref({ capacity: '-', capacity_unit: '', runtime: '-', runtime_unit: '', speed: '-', speed_unit: '', model_type: '-', batch: '-' })
  const showPartsList = ref(false)

  // 监听状态，确保在手机端同时只有一个弹窗打开
  watch(showPartsList, (val) => {
    if (val && window.innerWidth <= 768) {
      showInfoPanel.value = false
    }
  })
  watch(showInfoPanel, (val) => {
    if (val && window.innerWidth <= 768) {
      showPartsList.value = false
    }
  })

  const hasAnimation = ref(false)
  const animationState = reactive({
    availableAnims: [],
    selectedAnim: '',
    isPlaying: false
  })

  const animCtx = {
    mixer: null,
    clock: new THREE.Clock(),
    actions: {},
    currentAction: null
  }

  const ctx = {
    scene: null,
    camera: null,
    renderer: null,
    controls: null,
    composer: null,
    outlinePass: null,
    raycaster: new THREE.Raycaster(),
    mouse: new THREE.Vector2(),
    animationId: null,
    allParts: []
  }

  // 交互状态
  const interact = {
    isFocusing: false,
    focusTarget: null,
    isInFocusMode: false,
    isReturning: false,
    liftedPart: null,
    liftedBaseY: 0,
    liftedOriginalPos: new THREE.Vector3(),
    liftedOriginalQuat: new THREE.Quaternion(),
    liftedStartPos: new THREE.Vector3(),
    liftedTargetPos: new THREE.Vector3(),
    liftedReturnStartPos: new THREE.Vector3(),
    focusBox: new THREE.Box3(),
    focusCenter: new THREE.Vector3(),
    focusSize: new THREE.Vector3(),
    cameraStartPos: new THREE.Vector3(),
    controlsStartTarget: new THREE.Vector3(),
    cameraTargetPos: new THREE.Vector3(),
    cameraHorizontalOffset: new THREE.Vector3(),
    currentFocusCameraPos: new THREE.Vector3(),
    focusDistance: 0,
    focusT: 0
  }

  function initBaseScene() {
    ctx.scene = new THREE.Scene()
    ctx.scene.background = new THREE.Color(0xf2f5f9)
    ctx.scene.fog = new THREE.Fog(0xf2f5f9, 12, 45)

    ctx.camera = new THREE.PerspectiveCamera(55, window.innerWidth / window.innerHeight, 0.1, 200)
    ctx.camera.position.set(0, 3, 9)

    ctx.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
    ctx.renderer.setSize(window.innerWidth, window.innerHeight)
    ctx.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    ctx.renderer.shadowMap.enabled = true
    ctx.renderer.shadowMap.type = THREE.PCFSoftShadowMap
    ctx.renderer.toneMapping = THREE.ACESFilmicToneMapping
    ctx.renderer.toneMappingExposure = 1.05
    if (container.value) {
      container.value.appendChild(ctx.renderer.domElement)
    }

    ctx.controls = new OrbitControls(ctx.camera, ctx.renderer.domElement)
    ctx.controls.enableDamping = true
    ctx.controls.dampingFactor = 0.04
    ctx.controls.minDistance = 0.1
    ctx.controls.maxDistance = 22
    ctx.controls.maxPolarAngle = Math.PI / 2.1

    // 灯光系统
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.4)
    ctx.scene.add(ambientLight)

    const sunLight = new THREE.DirectionalLight(0xfff8e6, 0.95)
    sunLight.position.set(10, 18, 8)
    sunLight.castShadow = true
    sunLight.shadow.mapSize.set(2048, 2048)
    sunLight.shadow.camera.left = -25
    sunLight.shadow.camera.right = 25
    sunLight.shadow.camera.top = 25
    sunLight.shadow.camera.bottom = -25
    ctx.scene.add(sunLight)

    const fillLight = new THREE.DirectionalLight(0x80b3ff, 0.28)
    fillLight.position.set(-8, 10, 5)
    ctx.scene.add(fillLight)

    const hemisphereLight = new THREE.HemisphereLight(0xffffff, 0x505050, 0.35)
    ctx.scene.add(hemisphereLight)

    // 地面、墙体、展厅环境
    const ground = new THREE.Mesh(
      new THREE.PlaneGeometry(80, 80),
      new THREE.MeshStandardMaterial({ color: 0xe2e8f0, roughness: 0.7, metalness: 0.05 })
    )
    ground.rotation.x = -Math.PI / 2
    ground.receiveShadow = true
    ground.name = "ground"
    ctx.scene.add(ground)

    const gridHelper = new THREE.GridHelper(80, 80, 0xc8d6e5, 0xe2e8f0)
    gridHelper.position.y = 0.01
    gridHelper.material.opacity = 0.3
    gridHelper.material.transparent = true
    ctx.scene.add(gridHelper)

    const wallMat = new THREE.MeshStandardMaterial({ color: 0xf9fafb, roughness: 0.9 })
    const lineMat = new THREE.MeshStandardMaterial({ color: 0xd1d5db })

    const wallBack = new THREE.Mesh(new THREE.BoxGeometry(24, 9, 0.8), wallMat)
    wallBack.position.set(0, 4.5, -10)
    wallBack.name = "wall"
    ctx.scene.add(wallBack)

    const wallLeft = new THREE.Mesh(new THREE.BoxGeometry(0.8, 9, 20), wallMat)
    wallLeft.position.set(-12, 4.5, 0)
    wallLeft.name = "wall"
    ctx.scene.add(wallLeft)

    const wallRight = wallLeft.clone()
    wallRight.position.set(12, 4.5, 0)
    wallRight.name = "wall"
    ctx.scene.add(wallRight)

    const topLine = new THREE.Mesh(new THREE.BoxGeometry(24, 0.25, 1.2), lineMat)
    topLine.position.set(0, 8.8, -9.8)
    topLine.name = "line"
    ctx.scene.add(topLine)

    const logoTexture = new THREE.TextureLoader().load('/static/logo.png')
    const logoMaterial = new THREE.MeshBasicMaterial({
      map: logoTexture,
      transparent: true,
      side: THREE.DoubleSide
    })
    const logoPlane = new THREE.Mesh(new THREE.PlaneGeometry(3, 3.52), logoMaterial)
    logoPlane.position.set(0, 4, -9.5)
    logoPlane.name = "logo"
    ctx.scene.add(logoPlane)

    const stand = new THREE.Mesh(
      new THREE.CylinderGeometry(2.2, 2.4, 0.7, 36),
      new THREE.MeshStandardMaterial({ color: 0xffffff, roughness: 0.2, metalness: 0.25 })
    )
    stand.position.y = 0.35
    stand.receiveShadow = true
    ctx.scene.add(stand)

    ctx.composer = new EffectComposer(ctx.renderer)
    ctx.composer.addPass(new RenderPass(ctx.scene, ctx.camera))
    ctx.outlinePass = new OutlinePass(new THREE.Vector2(window.innerWidth, window.innerHeight), ctx.scene, ctx.camera)
    ctx.outlinePass.visibleEdgeColor.set(0x0066ff)
    ctx.outlinePass.hiddenEdgeColor.set(0x003399)
    ctx.outlinePass.edgeThickness = 2.5
    ctx.outlinePass.edgeStrength = 4
    ctx.composer.addPass(ctx.outlinePass)
  }

  function getLoader(onLoadCb) {
    const manager = new THREE.LoadingManager()
    manager.onProgress = (url, loaded, total) => {
      loadingProgress.value = Math.round((loaded / total) * 100)
    }
    manager.onLoad = () => {
      loading.value = false
      if (onLoadCb) onLoadCb()
    }
    return new GLTFLoader(manager)
  }

  function loadModelParams(modelKey) {
    if (!props || !props.modelDisplayConfig) return
    const model = props.modelDisplayConfig.find(row => row.model_key === modelKey)
    if (model && model.model_params) {
      try {
        const params = typeof model.model_params === 'string' ? JSON.parse(model.model_params) : model.model_params
        modelParams.value = params
      } catch {
        modelParams.value = { capacity: '-', capacity_unit: '', runtime: '-', runtime_unit: '', speed: '-', speed_unit: '', model_type: '-', batch: '-' }
      }
    } else {
      modelParams.value = { capacity: '-', capacity_unit: '', runtime: '-', runtime_unit: '', speed: '-', speed_unit: '', model_type: '-', batch: '-' }
    }
  }

  function downloadModel() {
    if (!modelName.value) {
      alert('当前未选中可下载的模型')
      return
    }
    const modelUrl = `/static/${modelName.value}.glb`
    const link = document.createElement('a')
    link.href = modelUrl
    link.download = `${modelName.value}.glb`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  function onWindowResize() {
    if (!ctx.camera || !ctx.renderer || !ctx.composer) return
    ctx.camera.aspect = window.innerWidth / window.innerHeight
    ctx.camera.updateProjectionMatrix()
    ctx.renderer.setSize(window.innerWidth, window.innerHeight)
    ctx.composer.setSize(window.innerWidth, window.innerHeight)
    if (ctx.outlinePass) {
      ctx.outlinePass.resolution.set(window.innerWidth, window.innerHeight)
    }
  }

  // 获取动画
  function registerAnimations(gltf) {
    if (!gltf.animations || gltf.animations.length === 0) {
      hasAnimation.value = false
      animationState.availableAnims = []
      animationState.selectedAnim = ''
      animationState.isPlaying = false
      return
    }

    if (!animCtx.mixer) {
      animCtx.mixer = new THREE.AnimationMixer(gltf.scene)
    }

    animCtx.actions = {}
    const animNames = []
    gltf.animations.forEach(clip => {
      animCtx.actions[clip.name] = animCtx.mixer.clipAction(clip)
      animNames.push(clip.name)
    })

    hasAnimation.value = true
    animationState.availableAnims = animNames
    animationState.selectedAnim = animNames[0]
    animationState.isPlaying = false
  }

  function playAnimation() {
    if (!animCtx.mixer || !animationState.selectedAnim) return
    if (animCtx.currentAction) {
      animCtx.currentAction.stop()
    }
    const action = animCtx.actions[animationState.selectedAnim]
    if (action) {
      animCtx.currentAction = action
      action.reset().play()
      animationState.isPlaying = true
    }
  }

  function pauseAnimation() {
    if (animCtx.currentAction) {
      animCtx.currentAction.paused = true
      animationState.isPlaying = false
    }
  }

  function resumeAnimation() {
    if (animCtx.currentAction) {
      animCtx.currentAction.paused = false
      animationState.isPlaying = true
    }
  }

  function toggleAnimation() {
    if (animationState.isPlaying) {
      pauseAnimation()
    } else if (animCtx.currentAction && animCtx.currentAction.paused) {
      resumeAnimation()
    } else {
      playAnimation()
    }
  }

  function onAnimSelectChange(animName) {
    animationState.selectedAnim = animName
    if (animationState.isPlaying) {
      playAnimation()
    }
  }

  function updateAnimationMixer() {
    if (animCtx.mixer) {
      animCtx.mixer.update(animCtx.clock.getDelta())
    }
  }

  function getPartFromObject(obj) {
    let current = obj
    while (current) {
      for (const part of ctx.allParts) {
        if (current === part) return part
      }
      current = current.parent
    }
    return null
  }

  function dispose() {
    if (ctx.animationId) cancelAnimationFrame(ctx.animationId)
    if (ctx.renderer) {
      ctx.renderer.dispose()
      if (container.value && ctx.renderer.domElement.parentNode === container.value) {
        container.value.removeChild(ctx.renderer.domElement)
      }
    }
    window.removeEventListener('resize', onWindowResize)
  }

  onBeforeUnmount(() => {
    dispose()
  })

  return {
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
  }
}
