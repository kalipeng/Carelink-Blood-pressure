# 树莓派蓝牙配置指南

当你的显示器到达后，按照以下步骤设置树莓派和 iHealth BP monitor 的蓝牙连接。

## 🎯 快速步骤

### 步骤 1：连接树莓派
- 将 HDMI 线连接到树莓派和显示器
- 连接键盘和鼠标（USB）
- 确保树莓派已连接到 WiFi（MyESP32Hotspot）

### 步骤 2：打开终端
在树莓派桌面上打开终端

### 步骤 3：验证文件
```bash
ls ~/healthpad/raspberry_pi/
```

你应该看到这些文件：
- `setup_bluetooth.sh` - 蓝牙设置脚本
- `ihealth_receiver.py` - 数据接收脚本
- `bluetooth_test.py` - 蓝牙测试脚本

### 步骤 4：运行蓝牙设置脚本
```bash
sudo bash ~/healthpad/raspberry_pi/setup_bluetooth.sh
```

这会：
- ✓ 启用 Bluetooth 服务
- ✓ 安装必要的 Python 库 (bleak)
- ✓ 测试与 iHealth 设备的连接

### 步骤 5：测试接收数据
首先，确保 iHealth KN-550BT **已打开**，然后：

```bash
cd ~/healthpad/raspberry_pi
python3 ihealth_receiver.py
```

脚本会：
1. 🔍 扫描蓝牙设备 (10 秒)
2. 🔗 连接到 iHealth KN-550BT
3. 📱 等待测量数据

在 iHealth 设备上按 **[M]** 键开始测量，数据会显示在树莓派屏幕上！

按 **Ctrl+C** 停止脚本。

---

## 📝 文件说明

### `setup_bluetooth.sh` (需要 root 权限)
```bash
# 完整的蓝牙系统设置
sudo bash setup_bluetooth.sh

# 功能：
# • 启动/启用 Bluetooth daemon
# • 安装 Python 库
# • 自动测试连接
```

### `ihealth_receiver.py` (需要配对的设备)
```bash
# 接收并显示血压测量数据
python3 ihealth_receiver.py

# 功能：
# • 扫描 iHealth 设备
# • 连接到设备
# • 实时显示测量值
# • 保存数据为 JSON
```

### `bluetooth_test.py` (诊断工具)
```bash
# 详细的蓝牙设备检测和诊断
python3 bluetooth_test.py

# 功能：
# • 扫描并列出所有设备
# • 显示设备信息
# • 检查蓝牙服务
```

---

## 🔧 故障排除

### 问题 1：找不到 iHealth 设备
```bash
# 检查 Bluetooth 状态
systemctl status bluetooth

# 打开 Bluetooth 中文日志
sudo journalctl -u bluetooth -f

# 重启 Bluetooth
sudo systemctl restart bluetooth
```

### 问题 2：连接被拒绝
- 确保 iHealth 已配对（之前连接过）
- 或重新启动 iHealth 设备
- 或运行 `bluetoothctl` 手动配对：

```bash
sudo bluetoothctl
# > scan on
# > pair <device-address>
# > trust <device-address>
# > connect <device-address>
# > quit
```

### 问题 3：无法接收数据
- iHealth 可能需要在配对后进行特殊初始化
- 尝试在官方 iHealth 应用中同步一次
- 检查数据是否收到但无法解析（查看原始字节）

---

## 📊 数据格式

iHealth KN-550BT 使用私有蓝牙协议。目前已知：

**服务 UUID:**
```
636f6d2e-6a69-7561-6e2e-646576000000  (com.jiuan.dev)
```

**特性 UUID:**
```
7365642e-6a69-7561-6e2e-646576000000  (sed. - 接收数据)
7265632e-6a69-7561-6e2e-646576000000  (rec. - 发送命令)
```

**数据格式** (需要验证和调整):
```
可能的格式：[标识字节] [收缩压 2字节] [舒张压 2字节] [心率 1字节] [其他...]
```

实际收到的数据会以十六进制显示，可用于逆向工程具体的数据结构。

---

## ✅ 完整工作流程

1. 启动树莓派，连接显示器
2. 打开终端，运行：
   ```bash
   sudo bash ~/healthpad/raspberry_pi/setup_bluetooth.sh
   ```
3. 等待安装和测试完成
4. 打开 iHealth KN-550BT，确保已配对
5. 运行：
   ```bash
   cd ~/healthpad/raspberry_pi
   python3 ihealth_receiver.py
   ```
6. 在 iHealth 上按 **[M]** 键开始测量
7. 在树莓派上看到血压数据！

---

## 🎓 下一步

设置完蓝牙后，你可以：
- 修改 `ihealth_receiver.py` 以保存到数据库
- 集成到 `preview.html` 前端
- 添加自动启动脚本
- 设置定时同步任务

有问题？查看项目文档：
- `BLUETOOTH_PROTOCOL.md` - 蓝牙协议详解
- `COMPATIBLE_DEVICES.md` - 设备兼容性
- `README.md` - 项目概览
