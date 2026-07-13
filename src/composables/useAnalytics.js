import { onMounted, onBeforeUnmount } from 'vue'
import request from '../utils/request'

export function useAnalytics() {
  let sessionStartTime = null
  let stayDurationReported = false

  const recordVisit = async () => {
    let deviceId = localStorage.getItem('deviceId')
    const lastVisitDate = localStorage.getItem('lastVisitDate')
    const today = new Date().toISOString().split('T')[0]

    let isNewUV = false
    if (!deviceId || lastVisitDate !== today) {
      if (!deviceId) {
        deviceId = 'device_' + Math.random().toString(36).substring(2, 15)
        localStorage.setItem('deviceId', deviceId)
      }
      localStorage.setItem('lastVisitDate', today)
      isNewUV = true
    }

    try {
      await request.post('/analytics/record', {
        deviceId: isNewUV ? deviceId : null
      })
      console.log('PV/UV 已记录')
    } catch (error) {
      console.error('记录访问量失败', error)
    }
  }

  const startStayDurationTracker = () => {
    sessionStartTime = Date.now()
    stayDurationReported = false

    document.addEventListener('visibilitychange', onVisibilityChange)
    window.addEventListener('beforeunload', onBeforeUnload)
  }

  const onVisibilityChange = () => {
    if (document.visibilityState === 'hidden') {
      reportStayDuration()
    } else if (document.visibilityState === 'visible' && stayDurationReported) {
      sessionStartTime = Date.now()
      stayDurationReported = false
    }
  }

  const onBeforeUnload = () => {
    reportStayDuration()
  }

  const reportStayDuration = () => {
    if (stayDurationReported || !sessionStartTime) return
    const stayDuration = Math.round((Date.now() - sessionStartTime) / 1000)
    if (stayDuration < 1) return

    stayDurationReported = true
    const sessionId = localStorage.getItem('deviceId') || 'session_' + Date.now()

    const payload = JSON.stringify({ sessionId, stayDuration })
    const url = `http://${window.location.hostname}:3000/api/analytics/stay-duration`

    if (navigator.sendBeacon) {
      navigator.sendBeacon(url, payload)
    } else {
      fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: payload,
        keepalive: true
      }).catch(() => {})
    }
  }

  const cleanup = () => {
    reportStayDuration()
    document.removeEventListener('visibilitychange', onVisibilityChange)
    window.removeEventListener('beforeunload', onBeforeUnload)
  }

  onMounted(() => {
    recordVisit()
    startStayDurationTracker()
  })

  onBeforeUnmount(() => {
    cleanup()
  })

  return {
    recordVisit,
    cleanup
  }
}
