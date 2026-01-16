# 🔍 iHealth KN-550BT Bluetooth UUID Reference

## 为什么 UUID 很重要？

UUID (Universally Unique Identifier) 是 BLE 设备上每个服务和特性的唯一标识符。正确的 UUID 是与设备通信的关键。

---

## iHealth KN-550BT UUID 信息

### 主服务 UUID
```
com.jiuan.dev
十六进制: 6d6f2e6a-6975-616e-2e64-657600000000
```

### 特性 UUID

#### 发送特性 (发送给手机)
```
sed.* (send - 发送数据)
十六进制: 7365642e-6a69-7561-6e2e-646576000000
```

#### 接收特性 (从手机接收)
```
rec.* (receive - 接收数据)
十六进制: 7265632e-6a69-7561-6e2e-646576000000
```

---

## 如何验证 UUID

### 1️⃣ 使用蓝牙诊断脚本（推荐）

```bash
# 在树莓派上运行
cd ~/healthpad/raspberry_pi
python3 bluetooth_test.py
```

这个脚本会：
- ✓ 扫描所有 BLE 设备
- ✓ 找到 iHealth KN-550BT
- ✓ 显示所有服务和特性 UUID
- ✓ 测试数据接收

### 2️⃣ 使用命令行工具

```bash
# 列出所有 Bluetooth 设备
hcitool scan

# 获取设备 MAC 地址，然后使用 gatttool
gatttool -b <MAC_ADDRESS> -I
> connect
> primary
> characteristics
```

### 3️⃣ 使用 Python (bleak)

```python
from bleak import BleakScanner, BleakClient

async def scan():
    devices = await BleakScanner.discover()
    for d in devices:
        if "KN-550BT" in d.name:
            async with BleakClient(d.address) as client:
                services = await client.get_services()
                for service in services:
                    print(f"Service: {service.uuid}")
                    for char in service.characteristics:
                        print(f"  └─ {char.uuid}")
```

---

## 预期的 UUID 结构

### ✅ 标准 BLE 血压服务（如果支持）
```
Service:  00001810-0000-1000-8000-00805f9b34fb (Blood Pressure)
Char:     00002a35-0000-1000-8000-00805f9b34fb (BP Measurement)
Char:     00002a49-0000-1000-8000-00805f9b34fb (BP Feature)
```

### ✅ iHealth 自定义 UUID（更可能）
```
Service:  6d6f2e6a-6975-616e-2e64-657600000000 (com.jiuan.dev)
Char:     7365642e-6a69-7561-6e2e-646576000000 (send)
Char:     7265632e-6a69-7561-6e2e-646576000000 (receive)
```

---

## 故障排除

### 问题：没有找到 iHealth 设备

**原因检查：**
1. ❌ iHealth 设备未开启
   - **解决:** 打开 iHealth KN-550BT 设备

2. ❌ 设备不在范围内
   - **解决:** 将设备靠近树莓派（<10米）

3. ❌ 蓝牙未启用
   - **解决:** `sudo systemctl start bluetooth`

4. ❌ 设备与其他设备配对
   - **解决:** 清除设备上的其他配对

### 问题：找到设备但无法连接

**原因检查：**
1. ❌ UUID 不匹配
   - **解决:** 运行 `bluetooth_test.py` 验证 UUID

2. ❌ 权限问题
   - **解决:** `sudo` 运行脚本 或 添加用户到 `bluetooth` 组
   ```bash
   sudo usermod -a -G bluetooth carelink
   ```

3. ❌ 设备固件问题
   - **解决:** 更新 iHealth 应用和设备固件

### 问题：找到 UUID 但无法接收数据

**原因检查：**
1. ❌ 未订阅通知
   - **解决:** 确保代码调用 `start_notify()`

2. ❌ 使用了错误的特性
   - **解决:** 确认使用 `rec.*` (receive) 特性，不是 `send`

3. ❌ 设备未在测量
   - **解决:** 在 iHealth 应用上按"开始测量"，不是树莓派

---

## 代码示例

### ✅ 正确的连接方式

```python
from bleak import BleakClient

# iHealth UUIDs
SERVICE = "6d6f2e6a-6975-616e-2e64-657600000000"
RECEIVE = "7265632e-6a69-7561-6e2e-646576000000"  # 接收特性

async def connect():
    async with BleakClient("MAC:ADDRESS") as client:
        # 定义数据回调
        def on_data(sender, data):
            print(f"Received: {data.hex()}")
        
        # 订阅接收特性
        await client.start_notify(RECEIVE, on_data)
        
        # 等待数据...
        await asyncio.sleep(60)
```

### ❌ 常见错误

```python
# ❌ 错误 1: 使用发送特性而不是接收
await client.start_notify(SEND, callback)  # ✗ 错误

# ❌ 错误 2: 使用了错误的 UUID
await client.start_notify("wrong-uuid", callback)

# ❌ 错误 3: 没有订阅
# 只是连接是不够的，必须调用 start_notify()
```

---

## 有用的 UUID 转换

### 十六进制 → ASCII

```python
# 服务 UUID
hex_str = "636f6d2e6a697561616e2e646576"
ascii = bytes.fromhex(hex_str).decode('utf-8')
print(ascii)  # 输出: com.jiuan.dev

# 发送特性
hex_str = "7365642e6a69"
ascii = bytes.fromhex(hex_str).decode('utf-8')
print(ascii)  # 输出: sed.ji
```

### ASCII → 十六进制

```python
ascii = "com.jiuan.dev"
hex_str = ascii.encode().hex()
print(hex_str)  # 输出: 636f6d2e6a697561616e2e646576
```

---

## 相关文档

- [BLE 通用 UUID 列表](https://www.bluetooth.com/specifications/gatt-services-database/)
- [Bleak 文档](https://bleak.readthedocs.io/)
- [iHealth API 文档](https://ihealthdevicesupport.com/) (可能需要注册)

---

## 快速检查清单

使用 `bluetooth_test.py` 验证时，应该看到：

- [ ] ✓ "Found X devices"
- [ ] ✓ "iHealth KN-550BT" 在列表中
- [ ] ✓ "Connected!" 
- [ ] ✓ 显示多个 Service UUID
- [ ] ✓ 找到 measurement characteristic(s)
- [ ] ✓ (可选) "Received data" 当在设备上测量时

---

## 下一步

✅ UUID 验证完成后：
1. 更新 `backend.py` 中的 UUID
2. 运行主程序
3. 从前端测试连接

如有问题，运行 `bluetooth_test.py` 收集详细信息。
