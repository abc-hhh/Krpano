import { ref, computed, onMounted } from 'vue'
import request from '../utils/request'

export function useModelConfig() {
  const modelDisplayConfig = ref([])
  const siteSettings = ref({
    title: '',
    logo_url: '',
    target_url: '#'
  })

  const disabledModules = computed(() => {
    return modelDisplayConfig.value
      .filter(row => row.model_key === null && !row.is_enabled)
      .map(row => row.module_key)
  })

  const disabledModels = computed(() => {
    return modelDisplayConfig.value
      .filter(row => row.model_key !== null && !row.is_enabled)
      .map(row => row.model_key)
  })

  const fetchModelDisplayConfig = async () => {
    try {
      const data = await request.get('/model-display/public')
      if (data.data) {
        modelDisplayConfig.value = data.data
      }
    } catch (error) {
      console.error('获取模型展示配置失败', error)
    }
  }

  const fetchSettings = async () => {
    try {
      const data = await request.get('/settings')
      if (data.data) {
        siteSettings.value = data.data
        document.title = data.data.title || '企业360全景线上展厅'
      }
    } catch (error) {
      console.error('获取网站配置失败', error)
    }
  }

  onMounted(() => {
    fetchModelDisplayConfig()
    fetchSettings()
  })

  return {
    modelDisplayConfig,
    siteSettings,
    disabledModules,
    disabledModels,
    fetchModelDisplayConfig,
    fetchSettings
  }
}
