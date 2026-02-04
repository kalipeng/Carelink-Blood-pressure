# 📡 Carelink iOS App - API 文档

## 🎯 概述

Carelink iOS应用会自动上传血压测量数据到你的服务器。

**当前配置：**
- 📍 **基础URL**: `https://your-api-endpoint.com/api` 
  - ⚠️ **需要修改**：在 `CloudSyncService.swift` 第15行改为你的服务器地址
- 🔐 **认证方式**: Bearer Token (可选)
- 📦 **数据格式**: JSON
- 🌐 **编码**: UTF-8

---

## 🔧 配置服务器地址

### 修改位置

编辑 `carelink/Services/CloudSyncService.swift` 第15行：

```swift
// 修改这一行，改为你的服务器地址
private let baseURL = "https://your-api-endpoint.com/api"
```

### 示例配置

```swift
// 示例1: 使用域名
private let baseURL = "https://api.carelink.com/v1"

// 示例2: 使用IP地址
private let baseURL = "http://192.168.1.100:8080/api"

// 示例3: 本地测试
private let baseURL = "http://localhost:3000/api"
```

---

## 📤 API 1: 上传单条血压记录

### 基本信息

```
POST /blood-pressure
```

### 请求头

```http
Content-Type: application/json
Authorization: Bearer {API_KEY}  // 可选
```

### 请求体格式

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "systolic": 120,
  "diastolic": 80,
  "pulse": 75,
  "timestamp": "2026-01-28T10:30:00Z",
  "source": "bluetooth"
}
```

### 字段说明

| 字段名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `id` | String (UUID) | ✅ | 测量记录的唯一标识符 | "550e8400-e29b-..." |
| `systolic` | Integer | ✅ | 收缩压（高压）单位: mmHg | 120 |
| `diastolic` | Integer | ✅ | 舒张压（低压）单位: mmHg | 80 |
| `pulse` | Integer | ✅ | 心率，单位: bpm | 75 |
| `timestamp` | String (ISO8601) | ✅ | 测量时间 | "2026-01-28T10:30:00Z" |
| `source` | String | ✅ | 数据来源 | "bluetooth", "simulated", "manual" |

### 数值范围

| 字段 | 正常范围 | 有效范围 |
|------|---------|---------|
| systolic | 90-120 | 50-250 |
| diastolic | 60-80 | 30-150 |
| pulse | 60-100 | 40-200 |

### source 可能的值

| 值 | 说明 |
|----|------|
| `bluetooth` | 通过iHealth血压计蓝牙测量的真实数据 ✅ |
| `simulated` | 模拟数据（测试用） |
| `manual` | 用户手动输入 |

### 响应

#### 成功 (200-299)

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "success": true,
  "message": "Data uploaded successfully",
  "id": "550e8400-e29b-41d4-a716-446655440000"
}
```

#### 失败 (400-599)

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "success": false,
  "error": "Invalid data format",
  "message": "Systolic pressure out of range"
}
```

### cURL 示例

```bash
curl -X POST https://your-api-endpoint.com/api/blood-pressure \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-api-key" \
  -d '{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "systolic": 120,
    "diastolic": 80,
    "pulse": 75,
    "timestamp": "2026-01-28T10:30:00Z",
    "source": "bluetooth"
  }'
```

---

## 📤 API 2: 批量上传血压记录

### 基本信息

```
POST /blood-pressure/batch
```

### 请求头

```http
Content-Type: application/json
Authorization: Bearer {API_KEY}  // 可选
```

### 请求体格式

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "systolic": 120,
    "diastolic": 80,
    "pulse": 75,
    "timestamp": "2026-01-28T10:30:00Z",
    "source": "bluetooth"
  },
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "systolic": 118,
    "diastolic": 78,
    "pulse": 72,
    "timestamp": "2026-01-28T09:15:00Z",
    "source": "bluetooth"
  }
]
```

### 响应

#### 成功 (200-299)

```json
{
  "success": true,
  "message": "Batch upload successful",
  "count": 2,
  "ids": [
    "550e8400-e29b-41d4-a716-446655440000",
    "660e8400-e29b-41d4-a716-446655440001"
  ]
}
```

---

## 📥 API 3: 获取血压记录

### 基本信息

```
GET /blood-pressure
```

### 请求头

```http
Authorization: Bearer {API_KEY}  // 可选
```

### 查询参数（可选）

| 参数 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `limit` | Integer | 返回记录数量 | 10 |
| `offset` | Integer | 跳过记录数量 | 0 |
| `from` | String (ISO8601) | 开始时间 | "2026-01-01T00:00:00Z" |
| `to` | String (ISO8601) | 结束时间 | "2026-01-31T23:59:59Z" |
| `source` | String | 数据来源过滤 | "bluetooth" |

### 示例请求

```
GET /blood-pressure?limit=10&source=bluetooth
```

### 响应

```json
{
  "success": true,
  "count": 10,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "systolic": 120,
      "diastolic": 80,
      "pulse": 75,
      "timestamp": "2026-01-28T10:30:00Z",
      "source": "bluetooth"
    }
  ]
}
```

---

## 🏥 API 4: 健康检查

### 基本信息

```
GET /health
```

### 用途

用于检查服务器是否在线和网络连接状态。

### 响应

```json
{
  "status": "ok",
  "timestamp": "2026-01-28T10:30:00Z"
}
```

---

## 🔐 认证配置（可选）

如果你的服务器需要API Key认证：

### 方法1: 在代码中设置

```swift
// 在AppDelegate.swift或适当位置添加
CloudSyncService.shared.setAPIKey("your-api-key-here")
```

### 方法2: 在设置界面设置

在 `SettingsViewController.swift` 中添加API Key输入框。

### Authorization Header

```http
Authorization: Bearer your-api-key-here
```

---

## 📊 数据流程图

```
┌─────────────────────────────────────────────────┐
│              测量完成                            │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│  1. 保存到本地 UserDefaults                      │
│     BloodPressureReading.add(reading)           │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│  2. 自动上传到服务器                             │
│     iHealthService.uploadReadingToCloud()       │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│  3. 调用CloudSyncService                        │
│     POST /blood-pressure                        │
└─────────────────┬───────────────────────────────┘
                  ↓
        ┌─────────┴─────────┐
        ↓                   ↓
┌───────────────┐   ┌───────────────┐
│  上传成功      │   │  上传失败      │
│  发送通知      │   │  发送通知      │
│  震动反馈      │   │  数据已保存    │
└───────────────┘   └───────────────┘
```

---

## 🧪 测试API

### 方法1: 使用curl测试

```bash
# 测试健康检查
curl http://your-server.com/api/health

# 测试上传（模拟数据）
curl -X POST http://your-server.com/api/blood-pressure \
  -H "Content-Type: application/json" \
  -d '{
    "id": "test-123",
    "systolic": 120,
    "diastolic": 80,
    "pulse": 75,
    "timestamp": "2026-01-28T10:30:00Z",
    "source": "bluetooth"
  }'
```

### 方法2: 使用Postman

1. 创建新请求
2. 方法: POST
3. URL: `http://your-server.com/api/blood-pressure`
4. Headers:
   - `Content-Type: application/json`
5. Body (raw JSON):
```json
{
  "id": "test-123",
  "systolic": 120,
  "diastolic": 80,
  "pulse": 75,
  "timestamp": "2026-01-28T10:30:00Z",
  "source": "bluetooth"
}
```

---

## 🐛 错误处理

### App端错误处理

```swift
CloudSyncService.shared.uploadReading(reading) { success, error in
    if success {
        print("✅ 上传成功")
    } else {
        print("❌ 上传失败: \(error ?? "Unknown error")")
        // 数据已保存在本地，可以稍后重试
    }
}
```

### 常见错误码

| HTTP Code | 说明 | 处理方式 |
|-----------|------|---------|
| 200-299 | 成功 | 正常 |
| 400 | 请求格式错误 | 检查数据格式 |
| 401 | 未授权 | 检查API Key |
| 403 | 禁止访问 | 检查权限 |
| 404 | 接口不存在 | 检查URL |
| 500-599 | 服务器错误 | 稍后重试 |

---

## 📝 服务器端实现示例

### Node.js (Express)

```javascript
const express = require('express');
const app = express();

app.use(express.json());

// 上传血压数据
app.post('/api/blood-pressure', (req, res) => {
  const { id, systolic, diastolic, pulse, timestamp, source } = req.body;
  
  // 验证数据
  if (!id || !systolic || !diastolic || !pulse) {
    return res.status(400).json({
      success: false,
      error: 'Missing required fields'
    });
  }
  
  // 验证范围
  if (systolic < 50 || systolic > 250) {
    return res.status(400).json({
      success: false,
      error: 'Systolic out of range (50-250)'
    });
  }
  
  // 保存到数据库
  // ... your database code ...
  
  res.json({
    success: true,
    message: 'Data uploaded successfully',
    id: id
  });
});

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString()
  });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### Python (Flask)

```python
from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route('/api/blood-pressure', methods=['POST'])
def upload_blood_pressure():
    data = request.json
    
    # 验证必填字段
    required = ['id', 'systolic', 'diastolic', 'pulse', 'timestamp', 'source']
    if not all(field in data for field in required):
        return jsonify({
            'success': False,
            'error': 'Missing required fields'
        }), 400
    
    # 验证数值范围
    if not (50 <= data['systolic'] <= 250):
        return jsonify({
            'success': False,
            'error': 'Systolic out of range (50-250)'
        }), 400
    
    # 保存到数据库
    # ... your database code ...
    
    return jsonify({
        'success': True,
        'message': 'Data uploaded successfully',
        'id': data['id']
    })

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'ok',
        'timestamp': datetime.utcnow().isoformat() + 'Z'
    })

if __name__ == '__main__':
    app.run(port=3000)
```

---

## 🔄 自动重试机制

### 当前行为

1. ✅ 测量完成后**立即自动上传**
2. ✅ 无论上传成功与否，数据**都会保存在本地**
3. ✅ 上传失败后，可以在结果页面**手动重传**

### 如需添加自动重试

在 `CloudSyncService.swift` 中可以添加重试逻辑：

```swift
func uploadWithRetry(_ reading: BloodPressureReading, attempts: Int = 3) {
    uploadReading(reading) { success, error in
        if !success && attempts > 0 {
            print("⏳ 重试上传... (剩余 \(attempts) 次)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.uploadWithRetry(reading, attempts: attempts - 1)
            }
        }
    }
}
```

---

## 📋 数据库设计建议

### 表结构 (SQL)

```sql
CREATE TABLE blood_pressure_readings (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36),
    systolic INT NOT NULL,
    diastolic INT NOT NULL,
    pulse INT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    source VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- 索引
    INDEX idx_user_timestamp (user_id, timestamp),
    INDEX idx_timestamp (timestamp),
    INDEX idx_source (source)
);
```

### MongoDB Schema

```javascript
{
  _id: ObjectId,
  id: String,  // UUID from app
  userId: ObjectId,
  systolic: Number,
  diastolic: Number,
  pulse: Number,
  timestamp: Date,
  source: String,
  createdAt: Date
}
```

---

## 🚀 快速开始

### 1. 配置服务器地址

```swift
// CloudSyncService.swift Line 15
private let baseURL = "https://your-server.com/api"
```

### 2. 测试连接

```bash
curl http://your-server.com/api/health
```

### 3. 测试上传

在app中完成一次测量，查看Console日志：

```
📤 [iHealthService] Uploading measurement to cloud...
✅ [iHealthService] Upload successful!
```

### 4. 验证服务器收到数据

查看你的服务器日志或数据库。

---

## 📞 技术支持

遇到问题？检查：

1. ✅ 服务器地址配置是否正确
2. ✅ 服务器是否在线 (`/health` 接口)
3. ✅ 防火墙是否允许连接
4. ✅ API格式是否符合文档
5. ✅ Console日志中的错误信息

---

## 📚 相关文档

- `BLUETOOTH_DEVICE_SYNC_GUIDE.md` - 蓝牙同步指南
- `CHANGES_SUMMARY.md` - 代码改动说明
- `CloudSyncService.swift` - 上传服务实现
- `BloodPressureReading.swift` - 数据模型定义

---

**最后更新**: 2026-01-28  
**版本**: 1.0.0
