<template>
  <div class="model-display-container">
    <el-card shadow="never" v-loading="loading">
      <template #header>
        <div class="card-header">
          <span>3D模型展示管理</span>
          <el-tag v-if="!isAdmin" type="warning" size="small">只读模式 - 仅管理员可修改</el-tag>
        </div>
      </template>

      <div v-for="mod in modules" :key="mod.key" class="module-section">
        <div class="module-header">
          <div class="module-info">
            <el-icon size="20"><Box /></el-icon>
            <span class="module-name">{{ mod.name }}</span>
            <el-tag :type="mod.moduleData.is_enabled ? 'success' : 'danger'" size="small">
              {{ mod.moduleData.is_enabled ? '已启用' : '已禁用' }}
            </el-tag>
          </div>
          <div class="module-actions" v-if="isAdmin">
            <el-switch
              :model-value="mod.moduleData.is_enabled === 1"
              @change="(val) => toggleModule(mod, val)"
              active-text="启用"
              inactive-text="禁用"
              :disabled="!isAdmin"
            />
          </div>
        </div>

        <div v-if="mod.moduleData.is_enabled === 0 && mod.moduleData.disable_reason" class="disable-reason-box">
          <el-icon><WarningFilled /></el-icon>
          <span>禁用理由：{{ mod.moduleData.disable_reason }}</span>
        </div>

        <el-table :data="mod.models" border size="small" class="model-table" :row-class-name="tableRowClassName">
          <el-table-column prop="model_name" label="模型名称" width="160" />
          <el-table-column prop="model_key" label="模型标识" width="180" />
          <el-table-column label="展示状态" width="120" align="center">
            <template #default="{ row }">
              <el-tag :type="row.is_enabled ? 'success' : 'danger'" size="small">
                {{ row.is_enabled ? '启用' : '禁用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="禁用理由" min-width="160">
            <template #default="{ row }">
              <span v-if="row.disable_reason" class="reason-text">{{ row.disable_reason }}</span>
              <span v-else class="no-reason">-</span>
            </template>
          </el-table-column>
          <el-table-column label="模型参数" min-width="200">
            <template #default="{ row }">
              <div v-if="row.model_params" class="params-preview">
                <span v-for="(val, key) in formatParamsForPreview(row.model_params)" :key="key" class="param-tag">
                  {{ val }}
                </span>
              </div>
              <span v-else class="no-reason">未设置</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" align="center" v-if="isAdmin">
            <template #default="{ row }">
              <el-button
                type="primary"
                size="small"
                plain
                @click="openParamsDialog(row)"
              >
                参数
              </el-button>
              <el-button
                v-if="row.is_enabled"
                type="danger"
                size="small"
                @click="openDisableDialog(row)"
                :disabled="mod.moduleData.is_enabled === 0"
              >
                禁用
              </el-button>
              <el-button
                v-else
                type="success"
                size="small"
                @click="enableModel(row)"
              >
                启用
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-card>

    <el-dialog v-model="paramsDialogVisible" title="编辑模型参数" width="520px" :close-on-click-modal="false">
      <div class="params-dialog-content">
        <p class="params-tip">修改后将在前台3D模型的信息卡片中实时显示</p>
        <el-form :model="paramsForm" label-width="90px" size="default">
          <el-form-item label="售价">
            <div style="display:flex;gap:8px;width:100%;">
              <el-input v-model="paramsForm.capacity" placeholder="数值" style="flex:1" />
              <el-input v-model="paramsForm.capacity_unit" placeholder="单位" style="width:80px" />
            </div>
          </el-form-item>
          <el-form-item label="上架日期">
            <div style="display:flex;gap:8px;width:100%;">
              <el-input v-model="paramsForm.runtime" placeholder="数值" style="flex:1" />
              <el-input v-model="paramsForm.runtime_unit" placeholder="单位" style="width:80px" />
            </div>
          </el-form-item>
          <el-form-item label="好评率">
            <div style="display:flex;gap:8px;width:100%;">
              <el-input v-model="paramsForm.speed" placeholder="数值" style="flex:1" />
              <el-input v-model="paramsForm.speed_unit" placeholder="单位" style="width:80px" />
            </div>
          </el-form-item>
          <el-form-item label="型号">
            <el-input v-model="paramsForm.model_type" placeholder="请输入型号" />
          </el-form-item>
          <el-form-item label="已售出">
            <el-input v-model="paramsForm.batch" placeholder="请输入已售出数量" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="paramsDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmParams" :loading="submitLoading">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="disableDialogVisible" title="禁用模型" width="460px" :close-on-click-modal="false">
      <div class="disable-dialog-content">
        <p>确定要禁用 <strong>{{ currentDisableTarget?.model_name || currentDisableTarget?.module_name }}</strong> 吗？</p>
        <el-form :model="disableForm" :rules="disableRules" ref="disableFormRef" label-width="80px">
          <el-form-item label="禁用理由" prop="reason">
            <el-input
              v-model="disableForm.reason"
              type="textarea"
              :rows="3"
              placeholder="请输入禁用理由（必填）"
              maxlength="200"
              show-word-limit
            />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="disableDialogVisible = false">取消</el-button>
        <el-button type="danger" @click="confirmDisable" :loading="submitLoading">确认禁用</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import request from '../utils/request'
import { useUserStore } from '../store/user'
import { ElMessage, ElMessageBox } from 'element-plus'

const userStore = useUserStore()
const isAdmin = computed(() => userStore.userInfo.role === 'admin')

const loading = ref(false)
const submitLoading = ref(false)
const allData = ref([])

const disableDialogVisible = ref(false)
const paramsDialogVisible = ref(false)
const currentParamsTarget = ref(null)
const paramsForm = ref({
  capacity: '', capacity_unit: '',
  runtime: '', runtime_unit: '',
  speed: '', speed_unit: '',
  model_type: '', batch: ''
})
const paramLabelMap = {
  capacity: '售价', runtime: '上架日期', speed: '好评率',
  model_type: '型号', batch: '已售出'
}
const paramUnitMap = {
  capacity: 'capacity_unit', runtime: 'runtime_unit', speed: 'speed_unit'
}
const currentDisableTarget = ref(null)
const disableForm = ref({ reason: '' })
const disableFormRef = ref(null)
const disableRules = {
  reason: [{ required: true, message: '请输入禁用理由', trigger: 'blur' }]
}

const modules = computed(() => {
  const moduleMap = {}
  for (const row of allData.value) {
    if (row.model_key === null) {
      if (!moduleMap[row.module_key]) {
        moduleMap[row.module_key] = { key: row.module_key, name: row.module_name, moduleData: row, models: [] }
      } else {
        moduleMap[row.module_key].moduleData = row
      }
    } else {
      if (!moduleMap[row.module_key]) {
        moduleMap[row.module_key] = { key: row.module_key, name: row.module_name, moduleData: { is_enabled: 1 }, models: [] }
      }
      moduleMap[row.module_key].models.push(row)
    }
  }
  return Object.values(moduleMap)
})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await request.get('/model-display')
    if (res.data) {
      allData.value = res.data
    }
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const toggleModule = async (mod, enabled) => {
  if (enabled) {
    try {
      await ElMessageBox.confirm(
        `确定要启用模块"${mod.name}"吗？启用后该模块下所有之前因模块禁用而被禁用的模型将一并恢复。`,
        '启用确认',
        { confirmButtonText: '确认启用', cancelButtonText: '取消', type: 'success' }
      )
      submitLoading.value = true
      const res = await request.put(`/model-display/${mod.moduleData.id}`, {
        is_enabled: 1,
        disable_reason: null
      })
      if (res.data) {
        allData.value = res.data
        ElMessage.success('模块已启用')
      }
    } catch (e) {
      if (e !== 'cancel') console.error(e)
    } finally {
      submitLoading.value = false
    }
  } else {
    currentDisableTarget.value = mod.moduleData
    disableForm.value.reason = ''
    disableDialogVisible.value = true
  }
}

const openDisableDialog = (row) => {
  currentDisableTarget.value = row
  disableForm.value.reason = ''
  disableDialogVisible.value = true
}

const confirmDisable = async () => {
  if (!disableFormRef.value) return
  await disableFormRef.value.validate(async (valid) => {
    if (!valid) return
    submitLoading.value = true
    try {
      const res = await request.put(`/model-display/${currentDisableTarget.value.id}`, {
        is_enabled: 0,
        disable_reason: disableForm.value.reason
      })
      if (res.data) {
        allData.value = res.data
        ElMessage.success('已禁用')
        disableDialogVisible.value = false
      }
    } catch (error) {
      console.error(error)
    } finally {
      submitLoading.value = false
    }
  })
}

const enableModel = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要启用模型"${row.model_name}"吗？`,
      '启用确认',
      { confirmButtonText: '确认', cancelButtonText: '取消', type: 'success' }
    )
    submitLoading.value = true
    const res = await request.put(`/model-display/${row.id}`, {
      is_enabled: 1,
      disable_reason: null
    })
    if (res.data) {
      allData.value = res.data
      ElMessage.success('模型已启用')
    }
  } catch (e) {
    if (e !== 'cancel') console.error(e)
  } finally {
    submitLoading.value = false
  }
}

const parseParams = (params) => {
  if (!params) return {}
  try {
    const obj = typeof params === 'string' ? JSON.parse(params) : params
    return obj
  } catch {
    return {}
  }
}

const formatParamsForPreview = (params) => {
  const paramsObj = parseParams(params)
  const result = []
  
  const items = [
    { key: 'capacity', unitKey: 'capacity_unit', label: '售价' },
    { key: 'runtime', unitKey: 'runtime_unit', label: '上架日期' },
    { key: 'speed', unitKey: 'speed_unit', label: '好评率' },
    { key: 'model_type', label: '型号' },
    { key: 'batch', label: '已售出' }
  ]
  
  for (const item of items) {
    const val = paramsObj[item.key]
    if (val && val !== '-') {
      const unit = item.unitKey ? (paramsObj[item.unitKey] || '') : ''
      result.push(`${item.label}: ${val}${unit}`)
    }
  }
  
  return result
}

const openParamsDialog = (row) => {
  currentParamsTarget.value = row
  let params = { capacity: '', capacity_unit: '', runtime: '', runtime_unit: '', speed: '', speed_unit: '', model_type: '', batch: '' }
  if (row.model_params) {
    try {
      const obj = typeof row.model_params === 'string' ? JSON.parse(row.model_params) : row.model_params
      Object.assign(params, obj)
    } catch {}
  }
  paramsForm.value = params
  paramsDialogVisible.value = true
}

const confirmParams = async () => {
  submitLoading.value = true
  try {
    const res = await request.put(`/model-display/${currentParamsTarget.value.id}`, {
      model_params: paramsForm.value
    })
    if (res.data) {
      allData.value = res.data
      ElMessage.success('模型参数已更新')
      paramsDialogVisible.value = false
    }
  } catch (error) {
    console.error(error)
  } finally {
    submitLoading.value = false
  }
}

const tableRowClassName = ({ row }) => {
  return row.is_enabled ? '' : 'disabled-row'
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.model-display-container {
  width: 100%;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.module-section {
  margin-bottom: 30px;
}
.module-section:last-child {
  margin-bottom: 0;
}
.module-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding: 12px 16px;
  background: #f5f7fa;
  border-radius: 8px;
  border-left: 4px solid #409eff;
}
.module-info {
  display: flex;
  align-items: center;
  gap: 10px;
}
.module-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}
.module-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}
.disable-reason-box {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  margin-bottom: 12px;
  background: #fef0f0;
  border: 1px solid #fde2e2;
  border-radius: 6px;
  color: #f56c6c;
  font-size: 13px;
}
.model-table {
  width: 100%;
}
.reason-text {
  color: #f56c6c;
  font-size: 13px;
}
.no-reason {
  color: #c0c4cc;
}
.disable-dialog-content p {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: #606266;
}
.params-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}
.param-tag {
  display: inline-block;
  padding: 2px 8px;
  background: #ecf5ff;
  border: 1px solid #d9ecff;
  border-radius: 4px;
  font-size: 12px;
  color: #409eff;
  white-space: nowrap;
}
.params-dialog-content .params-tip {
  margin: 0 0 16px 0;
  font-size: 13px;
  color: #909399;
}
:deep(.disabled-row) {
  background-color: #fef0f0 !important;
}
:deep(.disabled-row:hover > td) {
  background-color: #fde2e2 !important;
}
</style>
