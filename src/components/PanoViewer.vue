<template>
  <!-- Krpano 挂载容器 -->
  <div id="pano-container" style="width: 100%; height: 100%;"></div>
</template>

<script setup>
import { onMounted, ref, onBeforeUnmount } from 'vue'

const krpanoObj = ref(null)

//   暴露 krpano 实例供外部调用
const getKrpano = () => krpanoObj.value

defineExpose({
  getKrpano
})

onMounted(() => {
  //   动态注入 Krpano 核心脚本
  const script = document.createElement('script')
  script.src = '/tour.js'
  script.onload = () => {
    //   初始化全景播放器
    window.embedpano({
      swf: "tour.swf",
      xml: "tour.xml",
      target: "pano-container",
      html5: "auto",
      mobilescale: 1.0,
      passQueryParameters: true,
      onready: (krpanoInterface) => {
        //   保存引擎实例用于组件通信
        krpanoObj.value = krpanoInterface;
        
        //   注册全局方法供 Krpano XML 调用
        krpanoInterface.set('js_open_model', (id, name) => {
          if (window.openThreeModel) {
            window.openThreeModel(id, name)
          }
        })

        krpanoInterface.set('js_on_fullscreen_change', (state) => {
          if (window.onPanoFullscreenChange) {
            window.onPanoFullscreenChange(state)
          }
        })
        
        //   监听全景全屏状态变化
        krpanoInterface.call('set(events.onenterfullscreen, js_on_fullscreen_change(true))')
        krpanoInterface.call('set(events.onexitfullscreen, js_on_fullscreen_change(false))')

        console.log('Krpano is ready, instance:', krpanoInterface);
      }
    })
  }
  document.body.appendChild(script)
})

onBeforeUnmount(() => {
  //   组件销毁时释放内存
  if (krpanoObj.value) {
    window.removepano("pano-container")
  }
})
</script>