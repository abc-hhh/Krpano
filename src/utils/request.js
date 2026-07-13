const BASE_URL = `http://${window.location.hostname}:3000/api`

//   核心 HTTP 请求封装，自动携带 Authorization Token
async function request(url, options = {}) {
  const token = localStorage.getItem('token')
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers
  }
  if (token) {
    headers['Authorization'] = `Bearer ${token}`
  }

  const response = await fetch(`${BASE_URL}${url}`, {
    ...options,
    headers
  })

  const data = await response.json()

  //   统一处理 HTTP 错误响应
  if (!response.ok) {
    const error = new Error(data.message || '请求失败')
    error.status = response.status
    throw error
  }

  return data
}

request.get = (url, params) => {
  if (params) {
    const searchParams = new URLSearchParams()
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        searchParams.append(key, value)
      }
    })
    const queryString = searchParams.toString()
    if (queryString) url += `?${queryString}`
  }
  return request(url)
}

request.post = (url, body) => {
  return request(url, {
    method: 'POST',
    body: JSON.stringify(body)
  })
}

request.put = (url, body) => {
  return request(url, {
    method: 'PUT',
    body: JSON.stringify(body)
  })
}

request.del = (url) => {
  return request(url, {
    method: 'DELETE'
  })
}

export default request
