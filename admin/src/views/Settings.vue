<template>
  <div class="settings-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>系统配置</span>
        </div>
      </template>

      <el-form :model="form" :rules="rules" ref="formRef" label-width="120px" v-loading="loading">
        <el-form-item label="网站标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入网站标题" />
        </el-form-item>
        <el-form-item label="Logo URL" prop="logo_url">
          <el-input v-model="form.logo_url" placeholder="请输入Logo的图片地址 (如不需要可留空)" />
        </el-form-item>
        <el-form-item label="Logo 跳转链接" prop="target_url">
          <el-input v-model="form.target_url" placeholder="请输入点击Logo或标题时跳转的网址" />
        </el-form-item>
        <el-form-item label="演示模式" prop="demo_mode">
          <el-switch v-model="form.demo_mode" :active-value="1" :inactive-value="0" />
          <div class="tip-text">开启后，每次刷新前台页面都会被视作新用户，可以重复给留言点赞。</div>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="submitForm" :loading="submitLoading">保存配置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import request from '../utils/request'
import { ElMessage } from 'element-plus'

const formRef = ref(null)
const loading = ref(false)
const submitLoading = ref(false)

const form = ref({
  title: '企业360全景线上展厅',
  logo_url: '../images/logo.png',
  target_url: 'https://www.krpano.com',
  demo_mode: 0
})

const rules = {
  title: [{ required: true, message: '请输入网站标题', trigger: 'blur' }]
}

const fetchSettings = async () => {
  loading.value = true
  try {
    const res = await request.get('/settings')
    if (res.data) {
      form.value.title = res.data.title || ''
      form.value.logo_url = res.data.logo_url || ''
      form.value.target_url = res.data.target_url || ''
      form.value.demo_mode = res.data.demo_mode || 0
    }
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const submitForm = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        await request.put('/settings', form.value)
        ElMessage.success('配置保存成功')
      } catch (error) {
        console.error(error)
      } finally {
        submitLoading.value = false
      }
    }
  })
}

onMounted(() => {
  fetchSettings()
})
</script>

<style scoped>
.settings-container {
  max-width: 800px;
}
.tip-text {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
  line-height: 1.4;
  display: block;
  width: 100%;
}
@media (max-width: 768px) {
  :deep(.el-form-item) {
    flex-direction: column;
    align-items: flex-start;
  }
  :deep(.el-form-item__label) {
    width: 100% !important;
    justify-content: flex-start;
    padding-bottom: 0;
  }
  :deep(.el-form-item__content) {
    width: 100%;
    margin-left: 0 !important;
  }
  .tip-text {
    margin-left: 0;
    margin-top: 5px;
    line-height: 1.2;
  }
}
</style>