import axios from 'axios'
import { useUserStore } from '../store/user'
import { ElMessage } from 'element-plus'
import router from '../router'

const request = axios.create({
  // 将 localhost 替换为动态的 hostname，以便在局域网内通过 IP 访问时能正确连接到后端
  baseURL: `http://${window.location.hostname}:3000/api`, 
  timeout: 5000
})

request.interceptors.request.use(config => {
  const userStore = useUserStore()
  if (userStore.token) {
    config.headers['Authorization'] = `Bearer ${userStore.token}`
  }
  return config
}, error => {
  return Promise.reject(error)
})

request.interceptors.response.use(response => {
  return response.data
}, error => {
  if (error.response?.status === 401) {
    ElMessage.error('登录失效，请重新登录')
    const userStore = useUserStore()
    userStore.logout()
    router.push('/login')
  } else {
    ElMessage.error(error.response?.data?.message || '请求失败')
  }
  return Promise.reject(error)
})

export default request
