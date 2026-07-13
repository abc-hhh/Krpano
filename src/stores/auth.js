import { defineStore } from 'pinia'
import { ref } from 'vue'
import request from '../utils/request'

export const useAuthStore = defineStore('auth', () => {
  const currentUser = ref(null)
  const showAuthModal = ref(false)
  const isRegistering = ref(false)
  const authForm = ref({ username: '', password: '' })

  //   初始化检查登录状态
  function checkLoginStatus() {
    const userInfo = localStorage.getItem('userInfo')
    if (userInfo) {
      try {
        currentUser.value = JSON.parse(userInfo)
      } catch (e) {
        currentUser.value = null
      }
    }
  }

  //   呼出登录弹窗
  function openLogin() {
    showAuthModal.value = true
  }

  //   关闭登录弹窗
  function closeLogin() {
    showAuthModal.value = false
    authForm.value = { username: '', password: '' }
  }

  //   顶部的点击逻辑
  function handleAuthClick() {
    if (currentUser.value) {
      if (confirm('确定要退出登录吗？退出后将无法继续与客服聊天或留言。')) {
        logout()
      }
    } else {
      openLogin()
    }
  }

  //   提交登录/注册
  async function submitAuth() {
    if (!authForm.value.username || !authForm.value.password) {
      return alert('请输入用户名和密码')
    }
    const endpoint = isRegistering.value ? '/auth/register' : '/auth/login'
    try {
      const data = await request.post(endpoint, authForm.value)
      login(data.user, data.token)
      alert(`${isRegistering.value ? '注册' : '登录'}成功`)
    } catch (error) {
      alert(error.message || '认证失败')
    }
  }

  //   执行登录/注册成功后的状态更新
  function login(userData, token) {
    localStorage.setItem('token', token)
    localStorage.setItem('userInfo', JSON.stringify(userData))
    localStorage.setItem('deviceId', userData.username) // 兼容旧逻辑
    currentUser.value = userData
    showAuthModal.value = false
  }

  //   执行登出
  function logout() {
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    currentUser.value = null
    window.location.reload()
  }

  return {
    currentUser,
    showAuthModal,
    isRegistering,
    authForm,
    checkLoginStatus,
    openLogin,
    closeLogin,
    handleAuthClick,
    submitAuth,
    login,
    logout
  }
})
