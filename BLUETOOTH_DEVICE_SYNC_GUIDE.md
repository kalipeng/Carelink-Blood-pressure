# 🔗 蓝牙设备同步与数据上传指南

## ✅ 已实现的功能

### 1. 📱 **App端 Start/Stop 功能**

#### 功能说明：
- ✅ 点击 "Start Measurement" 开始测量
- ✅ 测量中按钮变为 "Stop Measurement"（红色）
- ✅ 可随时点击停止测量
- ✅ 停止后按钮恢复为绿色 "Start Measurement"

#### 实现位置：
- `MeasureViewController.swift`
  - `startMeasurement()` - 开始测量
  - `stopMeasurement()` - 停止测量
  - 按钮会动态改变颜色和文字

---

### 2. 🔘 **设备按钮事件监听**

#### 功能说明：
当用户在iHealth血压计硬件上按下按钮时，app会自动响应：

| 设备动作 | App响应 |
|---------|--------|
| 按下Start按钮 | App接收信号，UI更新为"测量中"状态 |
| 按下Stop按钮 | App接收信号，停止测量，UI恢复 |
| 测量完成 | App自动接收数据并显示结果 |

#### 数据包格式：
```
0xFE = 设备事件数据包
  - 0x01: 设备开始测量
  - 0x02: 设备停止测量
  - 0x03: 测量进行中

0xFD = 测量结果数据包
  - Byte 1-2: 收缩压 (Systolic)
  - Byte 3-4: 舒张压 (Diastolic)
  - Byte 5: 心率 (Pulse)
```

#### 实现位置：
- `iHealthService.swift`
  - `handleDeviceEvent()` - 处理设备按钮事件
  - `parseBloodPressureData()` - 区分事件包和数据包
  - 自动发送通知到UI层

- `MeasureViewController.swift`
  - `handleDeviceMeasurementStarted()` - 响应设备开始
  - `handleDeviceMeasurementStopped()` - 响应设备停止

---

### 3. 📤 **自动上传到服务器**

#### 功能说明：
- ✅ **自动上传**：每次测量完成后，数据会自动上传到你们的服务器
- ✅ **本地保存**：无论上传成功与否，数据都会保存在本地
- ✅ **手动重传**：如果上传失败，可以在结果页面点击"Upload to Cloud"按钮手动重传

#### 上传流程：
```
1. 测量完成
   ↓
2. 保存到本地 UserDefaults
   ↓
3. 自动调用 CloudSyncService.uploadReading()
   ↓
4. 发送 POST 请求到服务器
   ↓
5. 返回成功/失败状态
```

#### 实现位置：
- `iHealthService.swift`
  - `handleBloodPressureData()` - 测量完成后调用上传
  - `uploadReadingToCloud()` - 执行上传操作

- `CloudSyncService.swift`
  - `uploadReading()` - 上传单条记录
  - `uploadReadings()` - 批量上传
  - `syncAllLocalData()` - 同步所有本地数据

- `ResultViewController.swift`
  - 右上角 "📤 Upload to Cloud" 按钮
  - `uploadTapped()` - 手动上传功能

---

## 🔧 如何配置服务器地址

### 修改API端点：

编辑 `CloudSyncService.swift`：

```swift
// 修改这一行，改为你们的服务器地址
private let baseURL = "https://your-api-endpoint.com/api"
```

### API格式要求：

#### 上传单条记录：
```http
POST /api/blood-pressure
Content-Type: application/json
Authorization: Bearer {API_KEY}

{
  "id": "UUID",
  "systolic": 120,
  "diastolic": 80,
  "pulse": 75,
  "timestamp": "2026-01-28T10:30:00Z",
  "source": "bluetooth",
  "category": "Normal"
}
```

#### 批量上传：
```http
POST /api/blood-pressure/batch
Content-Type: application/json
Authorization: Bearer {API_KEY}

[
  { ... reading 1 ... },
  { ... reading 2 ... },
  ...
]
```

---

## 📊 工作流程图

### App端主动开始测量：
```
用户点击 "Start" 
   ↓
App发送命令 0xFD 0xFD 0xFA 0x05 0x11 0x00
   ↓
设备开始测量
   ↓
设备发送测量数据 0xFD + 数据
   ↓
App接收并解析
   ↓
保存 + 上传 + 显示结果
```

### 设备端主动开始测量：
```
用户按设备上的按钮
   ↓
设备发送事件 0xFE 0x01 (Start)
   ↓
App更新UI显示"测量中"
   ↓
设备发送测量数据 0xFD + 数据
   ↓
App接收并解析
   ↓
保存 + 上传 + 显示结果
```

---

## 🧪 测试步骤

### 1. 测试App端Start/Stop：
1. 打开App，进入测量页面
2. 点击绿色 "Start Measurement" 按钮
3. 确认按钮变为红色 "Stop Measurement"
4. 点击红色按钮停止测量
5. 确认按钮恢复为绿色

### 2. 测试设备按钮响应：
1. 确保设备已连接
2. 在设备上按下Start按钮
3. 观察App UI是否更新为"测量中"
4. 在设备上按下Stop按钮
5. 观察App UI是否恢复

### 3. 测试数据上传：
1. 完成一次测量
2. 查看Console日志，确认看到：
   ```
   💾 Saved to local storage
   📤 [iHealthService] Uploading measurement to cloud...
   ✅ [iHealthService] Upload successful!
   ```
3. 如果上传失败，进入结果页面
4. 点击右上角 "📤 Upload to Cloud" 按钮
5. 观察上传状态

---

## 📝 通知事件列表

| 通知名称 | 触发时机 | 数据 |
|---------|---------|------|
| `.deviceConnected` | 设备连接成功 | peripheral对象 |
| `.deviceDisconnected` | 设备断开连接 | nil |
| `.measurementStarted` | 测量开始 | nil |
| `.measurementCompleted` | 测量完成 | BloodPressureReading |
| `.measurementError` | 测量错误/停止 | error信息 |
| `"uploadSuccess"` | 上传成功 | reading对象 |
| `"uploadFailed"` | 上传失败 | error信息 |

---

## 🐛 常见问题

### Q: 点击Stop后设备还在测量？
A: Stop命令只是发送信号，设备可能需要几秒钟才能响应。如果设备不支持远程Stop，需要在设备上手动停止。

### Q: 上传一直失败？
A: 
1. 检查网络连接
2. 确认服务器地址是否正确
3. 检查API Key是否有效
4. 查看Console日志获取详细错误信息

### Q: 设备按钮没反应？
A: 
1. 确认设备已正确连接
2. 确认设备固件支持发送按钮事件
3. 查看Console是否收到 0xFE 开头的数据包

---

## 📞 技术支持

如有问题，请查看：
- Console日志（带有 [iHealthService]、[MeasureVC]、[ResultVC] 标记）
- 网络请求响应
- 蓝牙连接状态

所有操作都有详细的日志输出，方便调试。
