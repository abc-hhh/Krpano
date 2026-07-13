<template>
  <div class="messages">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>留言墙管理</span>
        </div>
      </template>

      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="nickname" label="昵称" width="120" />
        <el-table-column prop="content" label="留言内容" show-overflow-tooltip />
        <el-table-column prop="created_at" label="留言时间" width="160">
          <template #default="{ row }">
            {{ new Date(row.created_at).toLocaleString() }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="置顶" width="80">
          <template #default="{ row }">
            <el-switch v-model="row.is_top" :active-value="1" :inactive-value="0" @change="(val) => handleTop(row.id, val)" />
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="220" align="center">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button v-if="row.status === 0 || row.status === 2" type="success" size="small" @click="handleStatus(row.id, 1)">通过</el-button>
              <el-button v-if="row.status === 0 || row.status === 1" type="warning" size="small" @click="handleStatus(row.id, 2)">拒绝</el-button>
              <el-button type="primary" size="small" @click="openReplyDialog(row)">回复</el-button>
              <el-button v-if="userStore.userInfo.role === 'admin'" type="danger" size="small" @click="handleDelete(row.id)">删除</el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="replyDialogVisible" title="回复留言" width="90%" style="max-width: 500px;">
      <el-form :model="replyForm">
        <el-form-item label="原留言">
          <el-input v-model="currentMessage.content" disabled type="textarea" :rows="2"></el-input>
        </el-form-item>
        <el-form-item label="回复内容">
          <el-input v-model="replyForm.content" type="textarea" :rows="4" placeholder="请输入回复内容..."></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="replyDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitReply">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import request from '../utils/request'
import { useUserStore } from '../store/user'
import { ElMessage, ElMessageBox } from 'element-plus'

const tableData = ref([])
const loading = ref(false)
const userStore = useUserStore()

const fetchMessages = async () => {
  loading.value = true
  try {
    const res = await request.get('/messages')
    tableData.value = res.data
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const getStatusType = (status) => {
  const types = { 0: 'info', 1: 'success', 2: 'danger' }
  return types[status]
}

const getStatusText = (status) => {
  const texts = { 0: '待审核', 1: '已通过', 2: '已拒绝' }
  return texts[status]
}

const handleStatus = async (id, status) => {
  try {
    await request.put(`/messages/${id}/status`, { status })
    ElMessage.success('状态更新成功')
    fetchMessages()
  } catch (error) {
    console.error(error)
  }
}

const handleTop = async (id, is_top) => {
  try {
    await request.put(`/messages/${id}/top`, { is_top })
    ElMessage.success('置顶状态更新成功')
    fetchMessages()
  } catch (error) {
    console.error(error)
  }
}

const handleDelete = async (id) => {
  ElMessageBox.confirm('确定要删除这条留言吗？', '提示', { type: 'warning' }).then(async () => {
    try {
      await request.delete(`/messages/${id}`)
      ElMessage.success('删除成功')
      fetchMessages()
    } catch (error) {
      console.error(error)
    }
  }).catch(() => {})
}

const replyDialogVisible = ref(false)
const currentMessage = ref({})
const replyForm = ref({ content: '' })

const openReplyDialog = (row) => {
  currentMessage.value = row
  replyForm.value.content = row.reply_content || ''
  replyDialogVisible.value = true
}

const submitReply = async () => {
  if (!replyForm.value.content.trim()) {
    return ElMessage.warning('回复内容不能为空')
  }
  try {
    await request.put(`/messages/${currentMessage.value.id}/reply`, { reply_content: replyForm.value.content })
    ElMessage.success('回复成功')
    replyDialogVisible.value = false
    fetchMessages()
  } catch (error) {
    console.error(error)
  }
}

onMounted(() => {
  fetchMessages()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.action-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}
.action-buttons .el-button {
  margin-left: 0 !important;
}
</style>
