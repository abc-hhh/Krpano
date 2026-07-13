import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../store/user'
import Layout from '../views/Layout.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue')
  },
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/Dashboard.vue'),
        meta: { title: '数据分析', icon: 'PieChart' }
      },
      {
        path: 'messages',
        name: 'Messages',
        component: () => import('../views/Messages.vue'),
        meta: { title: '留言墙管理', icon: 'ChatDotRound' }
      },
      {
        path: 'chat',
        name: 'Chat',
        component: () => import('../views/Chat.vue'),
        meta: { title: '客服聊天', icon: 'ChatLineRound' }
      },
      {
        path: 'model-display',
        name: 'ModelDisplay',
        component: () => import('../views/ModelDisplay.vue'),
        meta: { title: '3D模型管理', icon: 'Box' }
      },
      {
        path: 'settings',
        name: 'Settings',
        component: () => import('../views/Settings.vue'),
        meta: { title: '系统配置', icon: 'Setting', roles: ['admin'] } // 仅 admin 可见
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('../views/Users.vue'),
        meta: { title: '用户管理', icon: 'User', roles: ['admin'] } // 仅 admin 可见
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  if (to.path !== '/login' && !userStore.token) {
    next('/login')
  } else if (to.meta && to.meta.roles && !to.meta.roles.includes(userStore.userInfo.role)) {
    // 如果没有权限访问，则重定向回首页
    next('/')
  } else {
    next()
  }
})

export default router
