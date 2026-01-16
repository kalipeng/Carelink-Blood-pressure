# 📊 血压数据传输验证指南

## 🎯 目标
确认 iHealth KN-550BT 血压计的数据是否成功：
1. 从蓝牙传输到 app
2. 保存到本地 UserDefaults
3. 显示在历史记录界面

---

## 🔍 验证方法

### 方法 1：查看 Xcode 控制台日志（最直接）

#### 步骤：
1. 在 Xcode 中运行 app（⌘+R）
2. 打开底部的**控制台** (Console)
   - 如果看不到，按 `⌘ + Shift + Y` 显示
3. 查看日志输出

#### 日志示例（数据成功传输）：

```
🏠 [HomeVC] ========== App 启动 ==========
📊 [DebugHelper] ========== 已保存的数据 ==========
📝 [DebugHelper] 总共 0 条记录
❌ [DebugHelper] 没有保存的数据

【点击"开始测量"按钮后】

🩺 [MeasureVC] 开始测量，调用 iHealthService...
📱 [iHealthService] 开始测量...
📥 [iHealthService] 收到数据: 15 字节
📦 [iHealthService] 原始数据: 0x01 7D 00 50 00 48 ...
✅ [iHealthService] 数据解析成功: 125/80 mmHg, 心率 72 bpm
📥 [MeasureVC] 收到测量结果: 125/80 mmHg
✅ [MeasureVC] 测量完成: 125/80 mmHg, 心率: 72
💾 [MeasureVC] 开始保存数据到 UserDefaults...

💾 [BloodPressureReading] 开始保存数据...
   • 收缩压: 125 mmHg
   • 舒张压: 80 mmHg
   • 心率: 72 bpm
   • 时间: 2026-01-16 05:30:15
💾 [BloodPressureReading] 当前已有 0 条记录
✅ [BloodPressureReading] 保存完成！总共 1 条记录

✅ [MeasureVC] 保存成功！当前共有 1 条记录
📝 [MeasureVC] 最新记录: 125/80

【切换到历史记录页面】

📖 [HistoryVC] 开始加载历史数据...
📊 [HistoryVC] 加载了 1 条记录
   1. 125/80 mmHg - 正常偏高
```

#### 🔍 日志检查点：

| 日志内容 | 含义 | 状态 |
|---------|------|------|
| `📱 [iHealthService] 开始测量...` | iHealthService 被正确调用 | ✅ |
| `📥 [iHealthService] 收到数据` | 从蓝牙设备收到数据 | ✅ |
| `✅ [iHealthService] 数据解析成功` | 数据解析正确 | ✅ |
| `💾 [BloodPressureReading] 保存完成` | 数据保存成功 | ✅ |
| `📊 [HistoryVC] 加载了 X 条记录` | 历史记录读取成功 | ✅ |

---

### 方法 2：使用 Canvas 预览测试（不需要真实设备）

#### 步骤：
1. 在 Xcode 中打开 `HomeViewController.swift`
2. 按 `⌥ + ⌘ + Enter` 显示 Canvas
3. 等待预览加载完成
4. 在预览中**三指双击**标题"健康监测"
   - 这会添加 3 条测试数据
   - 你会感受到震动反馈（模拟器）
5. 点击"历史记录"按钮，查看是否显示数据

#### 预期结果：
- 控制台输出 `🧪 [HomeVC] 调试手势触发：添加测试数据`
- 历史记录页面显示 3 条数据：
  - 120/80 mmHg
  - 135/85 mmHg
  - 118/75 mmHg

---

### 方法 3：真机测试（完整流程）

#### 前提条件：
- iPhone/iPad 连接到 Mac
- 蓝牙已开启
- iHealth KN-550BT 血压计已配对

#### 步骤：
1. 在 Xcode 选择你的 iPhone 设备
2. 运行 app（⌘+R）
3. 打开血压计，进入配对模式
4. 在 app 中点击"开始测量"
5. 观察控制台日志

#### 蓝牙连接成功的日志：

```
✅ [iHealthService] 蓝牙已开启
🔍 [iHealthService] 发现设备: KN-550BT
   • MAC: 12345678-1234-1234-1234-123456789ABC
   • RSSI: -45 dBm
   ✨ 找到 iHealth KN-550BT，准备连接...
⏸️ [iHealthService] 停止扫描
🔌 [iHealthService] 开始连接: KN-550BT
✅ [iHealthService] 已连接到设备
🔍 [iHealthService] 发现服务: 636F6D2E-6A69-7561-6E2E-646576000000
✅ [iHealthService] 订阅数据通知特性 (NOTIFY)
✅ [iHealthService] 找到命令写入特性 (WRITE)
🎉 [iHealthService] iHealth KN-550BT 设备已就绪
```

---

### 方法 4：检查 UserDefaults 数据（终极验证）

#### 在代码中添加检查：

在 `HomeViewController.swift` 的 `viewDidLoad` 最后添加：

```swift
// 临时调试代码
DebugHelper.testSaveAndLoad()
```

#### 预期输出：

```
🧪 [DebugHelper] ========== 测试保存功能 ==========
🗑️ [DebugHelper] 清空现有数据...
✅ [DebugHelper] 清空后: 0 条记录 (应为 0)

💾 [DebugHelper] 添加测试数据...
✅ [DebugHelper] 保存后: 1 条记录 (应为 1)
📝 [DebugHelper] 数据内容:
   • 收缩压: 125 mmHg (预期: 125)
   • 舒张压: 82 mmHg (预期: 82)
   • 心率: 75 bpm (预期: 75)

🎉 [DebugHelper] ✅ 保存功能测试通过！
```

---

## 🐛 常见问题排查

### 问题 1：没有看到任何日志

**原因：** 控制台被过滤或隐藏

**解决方法：**
1. 检查控制台右下角的过滤器
2. 确保选择 "All Output"
3. 清除搜索框中的过滤文本

---

### 问题 2：看到 "⚠️ 蓝牙超时，使用模拟数据"

**原因：** 30 秒内没有收到蓝牙数据

**可能情况：**
- 血压计没有开启或没有配对
- 蓝牙权限未授权
- 设备距离太远

**解决方法：**
1. 检查血压计是否开机并进入配对模式
2. 在 iPhone 设置中检查蓝牙权限
3. 靠近设备再试

---

### 问题 3：数据保存了但历史记录不显示

**原因：** 页面没有刷新

**解决方法：**
```swift
// 在 HistoryViewController 的 viewWillAppear 中确保调用：
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadData()  // 确保有这一行
}
```

---

### 问题 4：Canvas 预览时三指双击没反应

**原因：** 模拟器不支持多点触控手势

**解决方法：**
- 使用真机测试
- 或者直接在代码中调用：
  ```swift
  // 在 viewDidLoad 末尾添加（仅用于测试）
  DebugHelper.addTestData()
  ```

---

## 📊 完整数据流示意图

```
┌─────────────────────────────────────────────────────────────┐
│                    iHealth KN-550BT                         │
│                   (蓝牙血压计设备)                           │
└─────────────────────┬───────────────────────────────────────┘
                      │ 蓝牙 BLE
                      │ Service: com.jiuan.dev
                      ↓
┌─────────────────────────────────────────────────────────────┐
│  iHealthService.swift                                       │
│  • 扫描设备 (scanForDevices)                                │
│  • 连接设备 (connect)                                        │
│  • 接收数据 (peripheral:didUpdateValueFor:)                 │
│  • 解析数据 (parseBloodPressureData)                        │
│    ├─ 收缩压: data[1-2] (little-endian)                    │
│    ├─ 舒张压: data[3-4] (little-endian)                    │
│    └─ 心率: data[5]                                         │
└─────────────────────┬───────────────────────────────────────┘
                      │ 回调
                      ↓
┌─────────────────────────────────────────────────────────────┐
│  MeasureViewController.swift                                │
│  • handleMeasurementComplete(reading)                       │
│  • 调用保存: BloodPressureReading.add(reading)             │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ↓
┌─────────────────────────────────────────────────────────────┐
│  BloodPressureReading.swift                                 │
│  • add() - 添加到数组                                       │
│  • save() - JSONEncoder 编码                                │
│  • UserDefaults.standard.set()                              │
│    └─ Key: "bloodPressureReadings"                          │
└─────────────────────┬───────────────────────────────────────┘
                      │ 持久化存储
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                   UserDefaults                              │
│              (iOS 系统本地存储)                              │
└─────────────────────┬───────────────────────────────────────┘
                      │ 读取
                      ↓
┌─────────────────────────────────────────────────────────────┐
│  HistoryViewController.swift                                │
│  • loadData()                                               │
│  • BloodPressureReading.load()                              │
│  • JSONDecoder 解码                                         │
│  • 显示在 UITableView                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ 验证清单

使用这个清单确认每个步骤都正常：

- [ ] Xcode 控制台可以看到日志输出
- [ ] 启动 app 时看到 `🏠 [HomeVC] App 启动` 日志
- [ ] 点击测量按钮后看到 `🩺 [MeasureVC] 开始测量` 日志
- [ ] 看到 `💾 [BloodPressureReading] 保存完成` 日志
- [ ] 看到 `✅ [MeasureVC] 保存成功！当前共有 X 条记录` 日志
- [ ] 历史记录页面可以显示数据
- [ ] `DebugHelper.testSaveAndLoad()` 测试通过

---

## 🚀 快速测试命令

### 测试 1：添加测试数据
在 `HomeViewController.viewDidLoad` 末尾添加：
```swift
DebugHelper.addTestData()
```

### 测试 2：打印当前数据
在任何地方调用：
```swift
DebugHelper.printSavedData()
```

### 测试 3：完整保存测试
在 `AppDelegate.didFinishLaunchingWithOptions` 中：
```swift
DebugHelper.testSaveAndLoad()
```

### 测试 4：清空所有数据
```swift
DebugHelper.clearAllData()
```

---

## 📞 需要帮助？

如果还有问题，请提供：
1. Xcode 控制台的完整日志（从启动到测量完成）
2. 是使用模拟器还是真机
3. 是否连接了真实的血压计设备

---

**最后更新：** 2026-01-16
**版本：** 1.0
