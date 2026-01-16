# 🍓 Health Pad - Quick Reference Card

## 树莓派配置
```
主机名:   carelink-bp
用户名:   carelink
密码:     carelink2026
WiFi:     MyESP32Hotspot
SSH:      ssh carelink@carelink-bp.local
```

## 📋 新文件说明

| 文件 | 位置 | 说明 |
|------|------|------|
| **install.sh** | `raspberry_pi/` | ✨ 改进版本 - 自动启用 SSH 和 mDNS |
| **first_boot.sh** | `raspberry_pi/` | 🆕 首次启动配置脚本 (在 Pi 上运行) |
| **diagnose.sh** | `raspberry_pi/` | 🆕 系统诊断脚本 (检查服务状态) |
| **remote_connect.sh** | 项目根目录 | 🆕 Mac 远程连接助手脚本 |
| **RASPBERRY_PI_SETUP.md** | 项目根目录 | 📖 详细的完整设置指南 |

## 🚀 现在应该做什么

### 第 1 步：等待树莓派启动 (2-5 分钟)
```bash
# 每 30 秒尝试一次 ping
while true; do
  ping -c 1 carelink-bp.local >/dev/null 2>&1 && break
  echo "等待树莓派启动..."
  sleep 30
done
echo "✓ 树莓派已在线！"
```

### 第 2 步：验证网络
```bash
# 扫描网络查找树莓派
nmap -sn 172.20.10.0/28
```

### 第 3 步：使用连接助手脚本
```bash
# 自动检测并连接
chmod +x remote_connect.sh
./remote_connect.sh
```

或直接 SSH：
```bash
ssh carelink@carelink-bp.local
# 密码: carelink2026
```

### 第 4 步：在树莓派上运行首次启动脚本
```bash
# 确保 SSH 和 mDNS 已启用
bash ~/healthpad/raspberry_pi/first_boot.sh
```

### 第 5 步：运行完整安装
```bash
cd ~/healthpad
bash raspberry_pi/install.sh
```

## 🔧 改进的功能

✨ **改进了什么：**

1. ✅ **自动启用 SSH** - install.sh 现在会自动启用 SSH 服务
2. ✅ **自动配置 mDNS** - 安装并启动 avahi-daemon
3. ✅ **自动设置主机名** - 确保树莓派能通过 carelink-bp.local 访问
4. ✅ **支持任意用户名** - 不再硬编码 /home/pi 路径
5. ✅ **诊断工具** - 新增 diagnose.sh 脚本来检查系统状态
6. ✅ **远程连接助手** - Mac 上可运行 remote_connect.sh 自动找到树莓派

## 📖 详细文档

查看 **[RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md)** 了解：
- 详细步骤说明
- 常见问题排查
- 有用的命令参考

## 🎯 故障排除

**问题：无法解析 carelink-bp.local**
```bash
# 解决方案 1: 等待 Avahi 启动 (1-2 分钟)
sleep 30
ping carelink-bp.local

# 解决方案 2: 检查 mDNS 状态
ssh carelink@carelink-bp.local "systemctl status avahi-daemon"

# 解决方案 3: 重启 Avahi
ssh carelink@carelink-bp.local "sudo systemctl restart avahi-daemon"
```

**问题：SSH 连接被拒绝**
```bash
# 检查 SSH 是否运行
nmap -p 22 carelink-bp.local

# 或用诊断脚本
ssh carelink@carelink-bp.local "bash ~/healthpad/diagnose.sh"
```

**问题：不知道树莓派的 IP**
```bash
# 方法 1: 使用 nmap
nmap -sn 172.20.10.0/28

# 方法 2: 查看 ARP 表
arp -a | grep 172.20.10

# 方法 3: 运行连接助手
./remote_connect.sh
```

## ✅ 验证清单

在设置完成后检查：

- [ ] SSH 可以连接: `ssh carelink@carelink-bp.local`
- [ ] 诊断脚本运行成功: `bash ~/healthpad/diagnose.sh`
- [ ] Bluetooth 显示 ✓ Running
- [ ] Avahi (mDNS) 显示 ✓ Running
- [ ] 网络连接正常

## 📞 获取帮助

运行诊断脚本获取详细信息：
```bash
ssh carelink@carelink-bp.local
bash ~/healthpad/diagnose.sh
```

这会显示所有服务状态和系统信息。
