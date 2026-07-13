<template>
  <el-container class="layout-container">
    <!-- Desktop Sidebar -->
    <el-aside width="200px" class="aside desktop-aside">
      <div class="logo">Krpano Admin</div>
      <el-menu
        :default-active="activeMenu"
        class="el-menu-vertical"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
        router
      >
        <el-menu-item v-for="route in menuRoutes" :key="route.path" :index="'/' + route.path">
          <el-icon><component :is="route.meta.icon" /></el-icon>
          <span>{{ route.meta.title }}</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- Mobile Sidebar Drawer -->
    <el-drawer
      v-model="drawerVisible"
      direction="ltr"
      :with-header="false"
      size="200px"
      class="mobile-drawer"
    >
      <div class="aside" style="height: 100%;">
        <div class="logo">Krpano Admin</div>
        <el-menu
          :default-active="activeMenu"
          class="el-menu-vertical"
          background-color="#304156"
          text-color="#bfcbd9"
          active-text-color="#409EFF"
          router
          @select="drawerVisible = false"
        >
          <el-menu-item v-for="route in menuRoutes" :key="route.path" :index="'/' + route.path">
            <el-icon><component :is="route.meta.icon" /></el-icon>
            <span>{{ route.meta.title }}</span>
          </el-menu-item>
        </el-menu>
      </div>
    </el-drawer>

    <el-container>
      <el-header class="header">
        <div class="header-left">
          <el-icon class="menu-toggle" @click="drawerVisible = true">
            <Expand />
          </el-icon>
          <span class="role-tag" :class="userStore.userInfo.role">
            {{ userStore.userInfo.role === 'admin' ? '管理员' : '客服' }}
          </span>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="user-dropdown">
              {{ userStore.userInfo.username }}
              <el-icon class="el-icon--right"><arrow-down /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '../store/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const drawerVisible = ref(false)

const menuRoutes = computed(() => {
  const layoutRoute = router.options.routes.find(r => r.path === '/')
  if (!layoutRoute) return []
  return layoutRoute.children.filter(route => {
    if (route.meta && route.meta.roles) {
      return route.meta.roles.includes(userStore.userInfo.role)
    }
    return true
  })
})

const activeMenu = computed(() => route.path)

const handleCommand = (command) => {
  if (command === 'logout') {
    userStore.logout()
    ElMessage.success('已退出登录')
    router.push('/login')
  }
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}
.aside {
  background-color: #304156;
}
.logo {
  height: 60px;
  line-height: 60px;
  text-align: center;
  color: #fff;
  font-size: 20px;
  font-weight: bold;
  background-color: #2b3643;
}
.el-menu-vertical {
  border-right: none;
}
.header {
  background-color: #fff;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}
.role-tag {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  color: #fff;
}
.role-tag.admin {
  background-color: #f56c6c;
}
.role-tag.cs {
  background-color: #409eff;
}
.user-dropdown {
  cursor: pointer;
  color: #333;
  display: flex;
  align-items: center;
}
.main-content {
  background-color: #f0f2f5;
  padding: 20px;
  overflow-x: hidden;
}

.menu-toggle {
  display: none;
}

@media (max-width: 768px) {
  .desktop-aside {
    display: none !important;
  }
  .menu-toggle {
    display: block;
    margin-right: 15px;
    font-size: 24px;
    cursor: pointer;
    color: #333;
  }
  .header-left {
    display: flex;
    align-items: center;
  }
  .main-content {
    padding: 10px;
  }
}
:deep(.el-drawer__body) {
  padding: 0;
}
</style>
