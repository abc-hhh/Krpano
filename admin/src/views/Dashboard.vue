<template>
  <div class="dashboard">
    <el-row :gutter="20" class="panel-group">
      <el-col :xs="24" :sm="8" class="mb-20">
        <el-card shadow="hover" class="panel">
          <div class="panel-icon pv-icon">
            <el-icon><View /></el-icon>
          </div>
          <div class="panel-info">
            <div class="panel-title">总访问量 (PV)</div>
            <div class="panel-num">{{ summary.total_pv || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="8" class="mb-20">
        <el-card shadow="hover" class="panel">
          <div class="panel-icon uv-icon">
            <el-icon><User /></el-icon>
          </div>
          <div class="panel-info">
            <div class="panel-title">独立访客 (UV)</div>
            <div class="panel-num">{{ summary.total_uv || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="8" class="mb-20">
        <el-card shadow="hover" class="panel">
          <div class="panel-icon time-icon">
            <el-icon><Timer /></el-icon>
          </div>
          <div class="panel-info">
            <div class="panel-title">平均停留时长 (秒)</div>
            <div class="panel-num">{{ summary.avg_stay || 0 }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row style="margin-top: 20px;">
      <el-col :span="24">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>访问趋势</span>
              <el-radio-group v-model="timeRange" size="small" @change="onRangeChange">
                <el-radio-button value="7d">近7日</el-radio-button>
                <el-radio-button value="30d">近30日</el-radio-button>
                <el-radio-button value="all">全部</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="chartRef" style="height: 400px; width: 100%;"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row style="margin-top: 20px;">
      <el-col :span="24">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>停留时长分布</span>
              <el-radio-group v-model="durationTimeRange" size="small" @change="onDurationRangeChange">
                <el-radio-button value="7d">近7日</el-radio-button>
                <el-radio-button value="30d">近30日</el-radio-button>
                <el-radio-button value="all">全部</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="pieChartRef" style="height: 400px; width: 100%;"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import request from '../utils/request'
import * as echarts from 'echarts'

const summary = ref({})
const chartRef = ref(null)
const pieChartRef = ref(null)
const networkIp = ref('127.0.0.1')
const timeRange = ref('all')
const durationTimeRange = ref('all')
let chartInstance = null
let pieChartInstance = null

const fetchNetworkInfo = async () => {
  try {
    const res = await request.get('/analytics/network-info')
    if (res.data && res.data.ip) {
      networkIp.value = res.data.ip
      console.log('--- 手机/外部设备 答辩演示地址 ---')
      console.log(`前台全景访问地址: http://${networkIp.value}:5173`)
      console.log(`后台管理访问地址: http://${networkIp.value}:5175`)
      console.log('---------------------------------')
    }
  } catch (error) {
    console.error('获取网络地址失败', error)
  }
}

const fetchSummary = async () => {
  try {
    const res = await request.get('/analytics/summary', { params: { range: timeRange.value } })
    summary.value = res.data || {}
  } catch (error) {
    console.error(error)
  }
}

const fetchWeekly = async () => {
  try {
    const res = await request.get('/analytics/weekly', { params: { range: timeRange.value } })
    const data = res.data || []

    const dates = data.map(item => item.date)
    const pvs = data.map(item => item.page_views)
    const uvs = data.map(item => item.unique_visitors)

    initChart(dates, pvs, uvs)
  } catch (error) {
    console.error(error)
  }
}

const fetchDurationDistribution = async () => {
  try {
    const res = await request.get('/analytics/duration-distribution', { params: { range: durationTimeRange.value } })
    const data = res.data || {}
    initPieChart(data)
  } catch (error) {
    console.error(error)
  }
}

const onRangeChange = () => {
  fetchSummary()
  fetchWeekly()
}

const onDurationRangeChange = () => {
  fetchDurationDistribution()
}

const initChart = (dates, pvs, uvs) => {
  if (chartInstance) {
    chartInstance.dispose()
  }
  chartInstance = echarts.init(chartRef.value)
  const option = {
    tooltip: { trigger: 'axis' },
    legend: {
      data: ['访问量(PV)', '独立访客(UV)'],
      left: 'center', // 水平居中
      top: '10px'     // 距离顶部 10px
    },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'category', boundaryGap: false, data: dates },
    yAxis: { type: 'value' },
    series: [
      { name: '访问量(PV)', type: 'line', data: pvs, smooth: true, areaStyle: {} },
      { name: '独立访客(UV)', type: 'line', data: uvs, smooth: true, areaStyle: {} }
    ]
  }
  chartInstance.setOption(option)
}

const initPieChart = (data) => {
  if (pieChartInstance) {
    pieChartInstance.dispose()
  }
  pieChartInstance = echarts.init(pieChartRef.value)

  const lt10s = Number(data.lt10s) || 0
  const s10to60 = Number(data.s10to60) || 0
  const s60to300 = Number(data.s60to300) || 0
  const s300to600 = Number(data.s300to600) || 0
  const gt600 = Number(data.gt600) || 0
  const total = lt10s + s10to60 + s60to300 + s300to600 + gt600

  const pieData = [
    { value: lt10s, name: '小于10秒' },
    { value: s10to60, name: '10秒~1分钟' },
    { value: s60to300, name: '1分钟~5分钟' },
    { value: s300to600, name: '5分钟~10分钟' },
    { value: gt600, name: '10分钟以上' }
  ]

  const option = {
    tooltip: {
      trigger: 'item',
      formatter: (params) => {
        const pct = total > 0 ? ((params.value / total) * 100).toFixed(1) : 0
        return `${params.name}<br/>访问次数: <b>${params.value}</b><br/>占比: <b>${pct}%</b>`
      }
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      top: 'center',
      textStyle: { fontSize: 14 }
    },
    series: [
      {
        name: '停留时长分布',
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['60%', '50%'],
        avoidLabelOverlap: true,
        itemStyle: {
          borderRadius: 8,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: (params) => {
            const pct = total > 0 ? ((params.value / total) * 100).toFixed(1) : 0
            return `${params.name}\n${pct}%`
          }
        },
        emphasis: {
          label: { show: true, fontSize: 16, fontWeight: 'bold' }
        },
        data: pieData,
        color: ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de']
      }
    ]
  }

  if (total === 0) {
    option.title = {
      text: '暂无停留时长数据',
      left: 'center',
      top: 'center',
      textStyle: { color: '#999', fontSize: 16 }
    }
    option.series[0].data = []
  }

  pieChartInstance.setOption(option)
}

onMounted(() => {
  fetchNetworkInfo()
  fetchSummary()
  fetchWeekly()
  fetchDurationDistribution()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  chartInstance?.dispose()
  pieChartInstance?.dispose()
})

const handleResize = () => {
  chartInstance?.resize()
  pieChartInstance?.resize()
}
</script>

<style scoped>
.panel-group {
  margin-bottom: 20px;
}
.panel {
  cursor: pointer;
  height: 108px;
}
.panel :deep(.el-card__body) {
  display: flex;
  align-items: center;
  padding: 0;
  height: 100%;
}
.panel-icon {
  width: 108px;
  height: 108px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 48px;
  color: #fff;
  transition: all 0.3s ease-out;
}
.pv-icon { background-color: #40c9c6; }
.uv-icon { background-color: #36a3f7; }
.time-icon { background-color: #f4516c; }
.panel:hover .panel-icon {
  border-radius: 6px;
  transform: scale(0.9);
}
.panel-info {
  flex: 1;
  text-align: right;
  padding: 20px;
}
.panel-title {
  color: #8c8c8c;
  font-size: 14px;
  margin-bottom: 12px;
}
.panel-num {
  font-size: 20px;
  font-weight: bold;
  color: #666;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
@media (max-width: 768px) {
  .mb-20 {
    margin-bottom: 20px;
  }
}
</style>
