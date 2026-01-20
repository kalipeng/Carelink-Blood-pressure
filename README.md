# 🏥 CareLink - iHealth 血压监测 App

智能血压监测应用，支持 iHealth KN-550BT 蓝牙血压计。

---

## 🚀 快速开始

### 🚨 iPhone 看不到蓝牙设备？

**→ 马上看这个：** [`ONE_PAGE_GUIDE.md`](ONE_PAGE_GUIDE.md)

**一句话解决：** 长按血压计的 "MEMORY" 按钮 5 秒

---

### 📚 完整文档

| 问题 | 解决方案 | 时间 |
|------|----------|------|
| 🆘 **不知道从哪开始** | [`START_HERE.md`](START_HERE.md) | 2 分钟 |
| 📱 **iPhone 看不到设备** | [`ONE_PAGE_GUIDE.md`](ONE_PAGE_GUIDE.md) | 5 分钟 |
| ⚡ **需要快速诊断** | [`QUICK_DIAGNOSIS.md`](QUICK_DIAGNOSIS.md) | 3 分钟 |
| 🔧 **App 连接不上** | [`FORCE_CONNECT_GUIDE.md`](FORCE_CONNECT_GUIDE.md) | 10 分钟 |
| 📶 **详细配对方法** | [`DEVICE_ACTIVATION_GUIDE.md`](DEVICE_ACTIVATION_GUIDE.md) | 15 分钟 |
| 📊 **如何测量** | [`MEASUREMENT_GUIDE.md`](MEASUREMENT_GUIDE.md) | 10 分钟 |
| ✅ **验证真实数据** | [`HOW_TO_VERIFY_DATA.md`](HOW_TO_VERIFY_DATA.md) | 8 分钟 |

---

## ⚡ 3 步快速连接（5 分钟）

### Step 1：激活血压计（2 分钟）

```
1. 装入 4 节 AA 新电池
2. 按 "电源" 按钮开机
3. 长按 "MEMORY" 按钮 5-10 秒
4. 确认蓝牙图标开始闪烁
```

---

### Step 2：确认 iPhone 能看到（1 分钟）

```
1. iPhone 设置 > 蓝牙 > 开启
2. 在 "其他设备" 中查找 "KN-550BT"
3. ✅ 看到了？太好了！
4. ❌ 不要点击设备！
```

---

### Step 3：运行 App（2 分钟）

```
1. 在 Xcode 按 ⌘ + R
2. 等待 2 秒（自动连接）
3. 查看控制台输出
4. 等待 "🎉 设备已就绪"
5. App 界面显示 "Connected" 🟢
```

---

## 🎯 功能特性

### ✅ 已实现

- 🔵 **蓝牙连接** - 自动扫描和连接 iHealth KN-550BT
- 📊 **实时测量** - 获取真实血压数据
- 📱 **数据管理** - 保存和查看历史记录
- 🎙️ **语音播报** - 测量结果语音提示
- 📈 **数据分析** - 血压分类和健康建议
- 🔍 **数据验证** - 清晰区分真实数据和模拟数据

### 🎨 界面

- **主页** - 设备状态、快速测量
- **测量** - 实时测量进度、结果显示
- **历史** - 测量记录列表、数据筛选
- **结果** - 详细数据、健康建议

---

## 🛠️ 技术栈

### iOS 框架
- UIKit - 界面框架
- CoreBluetooth - 蓝牙通信
- AVFoundation - 语音合成
- UserDefaults - 数据持久化

### 自定义组件
- `iHealthService` - 蓝牙服务管理
- `BloodPressureReading` - 数据模型
- `BluetoothConnectionHelper` - 连接辅助工具
- `DebugHelper` - 调试工具

---

## 📋 系统要求

- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+
- 支持蓝牙 4.0+ 的 iPhone

---

## 🔧 开发设置

### 1. 克隆项目

```bash
git clone <repository-url>
cd carelink
```

### 2. 在 Xcode 中打开

```bash
open carelink.xcodeproj
```

### 3. 配置权限

确保 `Info.plist` 包含：
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要蓝牙权限连接血压计</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要蓝牙权限连接血压计</string>

<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>
```

### 4. 运行项目

```bash
⌘ + R
```

---

## 🧪 调试工具

### 查看蓝牙状态

在 `HomeViewController.swift` 中：

```swift
// 双击右上角状态区域
// 会显示详细的蓝牙状态信息
```

### 强制连接

在 `HomeViewController.swift` 中：

```swift
// 三击右上角状态区域
// 会强制启动完整连接流程
```

### 添加测试数据

在 `DebugHelper.swift` 中：

```swift
DebugHelper.addTestData()    // 添加测试数据
DebugHelper.printAllData()   // 打印所有数据
DebugHelper.clearAllData()   // 清空所有数据
```

---

## 📊 数据模型

### BloodPressureReading

```swift
struct BloodPressureReading {
    let systolic: Int           // 收缩压
    let diastolic: Int          // 舒张压
    let pulse: Int              // 脉搏
    let date: Date              // 测量时间
    let source: DataSource      // 数据来源
    
    enum DataSource {
        case bluetooth   // 真实蓝牙数据
        case simulated   // 模拟数据
        case manual      // 手动输入
    }
}
```

---

## 🔌 蓝牙协议

### iHealth KN-550BT 规格

```
服务 UUID:   636F6D2E-6A69-7561-6E2E-646576000000
NOTIFY UUID: 7365642E-6A69-7561-6E2E-646576000000
WRITE UUID:  7265632E-6A69-7561-6E2E-646576000000
```

### 数据格式

```
字节 0-1:  收缩压 (mmHg, little-endian)
字节 2-3:  舒张压 (mmHg, little-endian)
字节 4-5:  脉搏 (bpm, little-endian)
字节 6-11: 时间戳 (年月日时分秒)
```

---

## 🐛 故障排查

### iPhone 看不到设备

**最常见原因：** 设备没有进入配对模式

**解决方法：**
1. 长按 "MEMORY" 按钮 5 秒
2. 或取出电池 30 秒后重新装入
3. 详见 [`ONE_PAGE_GUIDE.md`](ONE_PAGE_GUIDE.md)

---

### App 连接不上

**最常见原因：** 在系统蓝牙中手动配对了

**解决方法：**
1. iPhone 设置 > 蓝牙
2. 找到 "KN-550BT"
3. 点击 (i) > 忽略此设备
4. 重新运行 app
5. 详见 [`FORCE_CONNECT_GUIDE.md`](FORCE_CONNECT_GUIDE.md)

---

### 显示模拟数据

**最常见原因：** 测量时间不够长

**解决方法：**
1. 等待至少 40-60 秒
2. 不要在 30 秒时点击完成
3. 详见 [`MEASUREMENT_GUIDE.md`](MEASUREMENT_GUIDE.md)

---

## 📖 完整文档列表

### 基础指南
- [`START_HERE.md`](START_HERE.md) - 总览和导航
- [`ONE_PAGE_GUIDE.md`](ONE_PAGE_GUIDE.md) - 一页快速指南
- [`QUICK_DIAGNOSIS.md`](QUICK_DIAGNOSIS.md) - 快速诊断

### 详细指南
- [`DEVICE_ACTIVATION_GUIDE.md`](DEVICE_ACTIVATION_GUIDE.md) - 设备激活详细指南
- [`FORCE_CONNECT_GUIDE.md`](FORCE_CONNECT_GUIDE.md) - 强制连接完整流程
- [`MEASUREMENT_GUIDE.md`](MEASUREMENT_GUIDE.md) - 测量使用指南

### 验证指南
- [`HOW_TO_VERIFY_DATA.md`](HOW_TO_VERIFY_DATA.md) - 数据验证方法
- [`DATA_VERIFICATION_GUIDE.md`](DATA_VERIFICATION_GUIDE.md) - 详细验证流程

---

## 💡 关键提示

### 🎯 5 个最重要的点

1. **进入配对模式** - 长按 MEMORY 按钮 5 秒
2. **不要手动配对** - 不要在系统蓝牙中点击设备
3. **让 App 自动连接** - 运行 app 等待 2 秒
4. **测量时间充足** - 等待 40-60 秒，不是 30 秒
5. **使用新电池** - 低电量会导致蓝牙不稳定

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可

MIT License

---

## 📞 支持

- 查看文档：[`START_HERE.md`](START_HERE.md)
- 快速诊断：[`QUICK_DIAGNOSIS.md`](QUICK_DIAGNOSIS.md)
- 设备问题：[`ONE_PAGE_GUIDE.md`](ONE_PAGE_GUIDE.md)
- 连接问题：[`FORCE_CONNECT_GUIDE.md`](FORCE_CONNECT_GUIDE.md)

---

**记住：90% 的问题都是因为设备没有进入配对模式。长按 MEMORY 按钮 5 秒能解决大部分问题！** 🎉

---

**最后更新：** 2026-01-16
