# 🩺 iHealth KN-550BT 测量指南

## 🎯 两种测量模式

你的 app 现在支持**两种测量模式**，可以根据血压计的实际行为选择：

---

## 📱 模式 1：App 控制测量（主动模式）

### 使用流程：
```
1. 戴好血压计袖带
2. 打开 app，确保蓝牙已连接
3. 点击 "Start Measurement" 按钮
4. App 发送命令 → 血压计自动开始测量
5. 等待 30-60 秒
6. 查看结果
```

### 适用场景：
- ✅ 血压计支持远程控制
- ✅ 想要完全通过 app 操作
- ✅ 血压计有自动充气功能

### 日志示例：
```
🩺 [iHealthService] ========== 开始测量 ==========
📱 [iHealthService] 设备已连接: KN-550BT
📤 [iHealthService] 准备发送测量命令...
✅ [iHealthService] 已发送测量命令
⏳ [iHealthService] 等待血压计开始测量...
💡 [iHealthService] 请确保已正确佩戴袖带

（等待 30-60 秒...）

📥 [iHealthService] 收到数据 (15 字节)
✅ [iHealthService] 数据解析成功: 125/80 mmHg, 心率 72 bpm
```

---

## 🔘 模式 2：手动测量（被动模式）

### 使用流程：
```
1. 戴好血压计袖带
2. 打开 app，确保蓝牙已连接
3. 直接按血压计上的 START 按钮
4. 血压计开始测量
5. 测量完成后，数据自动传到 app
6. 查看结果
```

### 适用场景：
- ✅ 血压计不支持远程控制
- ✅ 习惯手动按设备按钮
- ✅ App 只用于记录数据

### 实现方式：
你的 app 已经**自动支持这个模式**！

只要：
1. App 在运行
2. 蓝牙已连接
3. 无论何时血压计发送数据，app 都会自动接收

不需要点击 "Start Measurement" 按钮！

---

## 🤔 如何判断你的血压计支持哪种模式？

### 测试方法：

#### **测试 1：检查是否支持 App 控制**

1. 打开 app，连接血压计
2. **不要按血压计上的按钮**
3. 只点击 app 的 "Start Measurement"
4. 观察血压计是否开始充气

**结果判断：**
- ✅ 血压计自动充气 = **支持 App 控制（模式 1）**
- ❌ 血压计没反应 = **只支持手动测量（模式 2）**

#### **测试 2：检查手动测量是否能传数据**

1. 打开 app，连接血压计
2. **不要点击 app 的按钮**
3. 直接按血压计上的 START 按钮
4. 等待测量完成
5. 观察 app 是否收到数据

**结果判断：**
- ✅ App 收到数据 = **支持手动测量（模式 2）**
- ❌ App 没收到数据 = **需要先点击 app 按钮**

---

## 🔧 根据测试结果配置

### 情况 A：两种模式都支持 ✅

**恭喜！你的血压计最灵活。**

你可以：
- 方式 1：点击 app 按钮，让血压计自动测量
- 方式 2：直接按血压计按钮，app 自动接收数据

**无需修改代码，当前实现已经支持！**

---

### 情况 B：只支持 App 控制（模式 1）

**使用流程：**
```
1. 戴好袖带
2. 打开 app
3. 点击 "Start Measurement"
4. 等待测量完成
```

**当前代码已支持，无需修改。**

---

### 情况 C：只支持手动测量（模式 2）

**需要修改 UI 提示：**

将 "Start Measurement" 按钮改为：
- 按钮文字: "Ready to Measure"
- 点击后不发送命令，只显示"Please press START on device"

修改代码：

```swift
// 在 MeasureViewController.swift 中修改：

private func startMeasurement() {
    guard !isMeasuring else { return }
    
    isMeasuring = true
    
    // UI updates
    startButton.setTitle("", for: .normal)
    activityIndicator.startAnimating()
    startButton.isEnabled = false
    
    // 🔄 改为被动监听模式
    print("👂 [MeasureVC] 等待用户手动测量...")
    iHealthService.shared.listenForMeasurement { [weak self] reading in
        print("📥 [MeasureVC] 收到手动测量结果: \(reading.systolic)/\(reading.diastolic)")
        DispatchQueue.main.async {
            self?.handleMeasurementComplete(reading)
        }
    }
    
    // 显示提示
    print("💡 请按血压计上的 START 按钮开始测量")
    
    // 超时保护
    DispatchQueue.main.asyncAfter(deadline: .now() + 120.0) { [weak self] in
        guard let self = self, self.isMeasuring else { return }
        print("⏱️ [MeasureVC] 等待超时")
        // 显示超时提示
    }
}
```

---

## 📊 查看测量日志

运行 app 后，在 Xcode 控制台查看日志：

### 模式 1（App 控制）的日志：
```
🩺 [iHealthService] ========== 开始测量 ==========
📤 [iHealthService] 准备发送测量命令...
✅ [iHealthService] 已发送测量命令
⏳ [iHealthService] 等待血压计开始测量...

（血压计自动充气、测量、放气）

📥 [iHealthService] 收到数据 (15 字节)
✅ [iHealthService] 数据解析成功: 125/80 mmHg
```

### 模式 2（手动测量）的日志：
```
👂 [iHealthService] 开始监听血压计数据...
💡 [iHealthService] 你可以直接按血压计上的按钮开始测量

（用户按血压计按钮）

📥 [iHealthService] 收到数据 (15 字节)
✅ [iHealthService] 数据解析成功: 125/80 mmHg
```

---

## ⚠️ 常见问题

### Q1: 点击 "Start Measurement" 后血压计没反应？

**可能原因：**
1. 蓝牙未连接
2. 血压计不支持远程控制
3. 命令格式不对

**解决方法：**
1. 检查设备状态显示是否为 "Connected"
2. 尝试直接按血压计按钮（使用模式 2）
3. 查看控制台日志，看是否有错误信息

---

### Q2: 按了血压计按钮，app 没收到数据？

**可能原因：**
1. 蓝牙连接中断
2. App 没有在监听
3. 测量还没完成

**解决方法：**
1. 确保 app 在前台运行
2. 等待测量完全结束（听到"滴"声）
3. 重新连接蓝牙

---

### Q3: 需要在测量前点击按钮还是测量后点击？

**答案：**

| 模式 | 点击时机 | 操作顺序 |
|------|---------|---------|
| 模式 1（App 控制）| **测量前** | 1. 戴袖带 → 2. 点击 app → 3. 自动测量 |
| 模式 2（手动）| **可选** | 1. 戴袖带 → 2. 按设备按钮 → 3. app 自动收数据 |

**推荐做法：**
- 先做测试，确定你的血压计支持哪种模式
- 如果支持模式 1，优先使用（体验更好）
- 如果只支持模式 2，按完设备按钮后 app 会自动收数据

---

## 🧪 快速测试脚本

将以下代码添加到 `HomeViewController.viewDidLoad` 末尾，可以自动测试：

```swift
#if DEBUG
// 测试连接状态
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    let isConnected = iHealthService.shared.isConnected
    print("🔌 连接状态: \(isConnected ? "✅ 已连接" : "❌ 未连接")")
    
    if !isConnected {
        print("💡 建议：先连接血压计再测试")
        print("   1. 确保血压计已开机")
        print("   2. 检查蓝牙权限")
        print("   3. 尝试重启 app")
    }
}
#endif
```

---

## 📞 需要帮助？

测试完成后，请告诉我：
1. ✅ 点击 app 按钮后，血压计是否自动开始测量？
2. ✅ 直接按血压计按钮，app 是否能收到数据？
3. ✅ 控制台日志显示什么？

我会根据你的反馈优化代码！

---

**最后更新：** 2026-01-16
**版本：** 1.0
