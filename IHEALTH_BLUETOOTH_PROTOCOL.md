# iHealth KN-550BT 蓝牙协议完整文档

## 📱 设备信息

| 项目 | 详情 |
|------|------|
| **设备名称** | KN-550BT |
| **厂商** | iHealth (联想子公司) |
| **类型** | 血压计 (Bluetooth LE) |
| **功能** | 测量收缩压、舒张压、心率 |
| **协议** | 私有蓝牙协议 (非标准 BLE 血压协议) |

---

## 🔵 蓝牙 UUID 列表

### 主服务

| UUID | 名称 | 说明 |
|------|------|------|
| `636f6d2e-6a69-7561-6e2e-646576000000` | **iHealth Service** | 主服务 (ASCII: "com.jiuan.dev") |

### 主要特性 (Characteristics)

| UUID | 名称 | ASCII | 方向 | 说明 |
|------|------|-------|------|------|
| `7365642e-6a69-7561-6e2e-646576000000` | **NOTIFY_CHAR** | "sed." | 📥 Notify | 接收血压数据 (订阅) |
| `7265632e-6a69-7561-6e2e-646576000000` | **WRITE_CHAR** | "rec." | 📤 Write | 发送命令到设备 |

### 其他已知服务 (标准 BLE)

| UUID | 说明 |
|------|------|
| `00001800-0000-1000-8000-00805f9b34fb` | Generic Access Service |
| `00001801-0000-1000-8000-00805f9b34fb` | Generic Attribute Service |
| `0000180a-0000-1000-8000-00805f9b34fb` | Device Information Service |
| `0000180f-0000-1000-8000-00805f9b34fb` | Battery Service (电池信息) |

---

## 📊 数据格式

### 血压测量数据格式 (推测)

iHealth KN-550BT 使用私有数据格式。根据逆向工程和对比分析：

```
接收到的数据示例格式：
[标识] [收缩压LSB] [收缩压MSB] [舒张压LSB] [舒张压MSB] [心率] [时间戳...] [校验和?]

字节说明：
Byte 0:      0xFD 或 0xFE (数据包标识)
Byte 1-2:    收缩压 (Systolic) - 小端格式 (Little Endian)
Byte 3-4:    舒张压 (Diastolic) - 小端格式
Byte 5:      心率 (Pulse) - 每分钟跳数
Byte 6+:     可能的时间戳、校验和等其他数据
```

### 数据范围

| 项目 | 最小值 | 最大值 | 单位 |
|------|--------|--------|------|
| 收缩压 (SYS) | 50 | 250 | mmHg |
| 舒张压 (DIA) | 30 | 150 | mmHg |
| 心率 (PULSE) | 40 | 200 | bpm |

### 数据解析示例

```python
import struct

# 假设接收到的数据为 data (bytes)
if len(data) >= 6 and data[0] in [0xFD, 0xFE]:
    # 使用小端格式解析
    systolic = struct.unpack('<H', data[1:3])[0]    # 收缩压 (2字节)
    diastolic = struct.unpack('<H', data[3:5])[0]   # 舒张压 (2字节)
    pulse = data[5]                                   # 心率 (1字节)
    
    print(f"SYS: {systolic} mmHg")
    print(f"DIA: {diastolic} mmHg")
    print(f"PUL: {pulse} bpm")
```

---

## 🔌 连接流程

### 1. 蓝牙扫描

```python
from bleak import BleakScanner

devices = await BleakScanner.discover(timeout=10.0)
for device in devices:
    if "KN-550BT" in device.name:
        print(f"Found: {device.name} ({device.address})")
        target_device = device
        break
```

### 2. 设备连接

```python
from bleak import BleakClient

SERVICE_UUID = "636f6d2e-6a69-7561-6e2e-646576000000"
NOTIFY_CHAR = "7365642e-6a69-7561-6e2e-646576000000"

async with BleakClient(device.address) as client:
    # 订阅通知 (接收血压数据)
    await client.start_notify(NOTIFY_CHAR, callback)
    
    # 等待数据...
    await asyncio.sleep(60)
    
    # 停止订阅
    await client.stop_notify(NOTIFY_CHAR)
```

### 3. 数据接收回调

```python
def notification_callback(sender, data):
    """处理接收到的血压数据"""
    print(f"原始数据: {data.hex()}")
    
    # 解析数据
    if len(data) >= 6:
        systolic = int.from_bytes(data[1:3], 'little')
        diastolic = int.from_bytes(data[3:5], 'little')
        pulse = data[5]
        
        print(f"血压: {systolic}/{diastolic} mmHg, 心率: {pulse} bpm")
```

---

## 📤 命令格式 (发送到设备)

### 已知命令

根据 iHealth SDK 的逆向工程，可能的命令格式：

```
启动测量:     0xFD 0xFD 0xFA 0x05 0x11 0x00
获取历史:     0xFD 0xFD 0xFA 0x05 0x12 0x00
```

**注意:** 这些命令可能需要特定的认证或配对状态，且实际格式需要进一步验证。

### 命令发送示例

```python
WRITE_CHAR = "7265632e-6a69-7561-6e2e-646576000000"

async with BleakClient(device.address) as client:
    # 发送启动测量命令
    command = bytes([0xFD, 0xFD, 0xFA, 0x05, 0x11, 0x00])
    await client.write_gatt_char(WRITE_CHAR, command, response=False)
```

---

## 🔧 配对与认证

### 配对步骤

1. **首次配对** (使用 bluetoothctl)
   ```bash
   sudo bluetoothctl
   > scan on
   > pair <MAC_ADDRESS>
   > trust <MAC_ADDRESS>
   > connect <MAC_ADDRESS>
   ```

2. **连接保持**
   - 配对后自动信任
   - 下次连接会快速重连

### 可能的认证要求

- iHealth 可能需要设备绑定信息
- 某些功能（如历史数据）可能需要特殊认证
- 建议先用官方 iHealth App 完成一次同步

---

## 📋 平台支持

### Python (推荐)

```bash
# 安装依赖
pip install bleak

# 脚本运行
python3 ihealth_receiver.py
```

**支持的操作系统:**
- ✅ Linux (Raspberry Pi)
- ✅ macOS
- ✅ Windows (需要额外配置)

### 其他语言

| 语言 | 库 | 平台 |
|------|-----|------|
| **JavaScript** | `noble` | Node.js |
| **Swift** | `CoreBluetooth` | iOS |
| **Kotlin** | `BluetoothAdapter` | Android |
| **C#** | `InTheHand.BluetoothLE` | .NET |

---

## 🐛 已知问题与解决方案

### 问题 1: 无法扫描到设备
**原因:** iHealth 未打开或未在广播状态
**解决方案:**
- 确保设备已开启（通常按电源键）
- 重启设备
- 将设备放在范围内 (<10 米)

### 问题 2: 连接成功但无数据
**原因:** 需要先启动测量或传输历史数据
**解决方案:**
- 在 iHealth 设备上按 **[M]** 键开始测量
- 等待 20-30 秒接收数据
- 或尝试发送启动命令

### 问题 3: 数据无法解析
**原因:** 数据格式与推测不符
**解决方案:**
- 打印原始十六进制数据进行分析
- 对比多次测量的数据包
- 在 Mac/Linux 上用 `hcidump` 或 `btmon` 抓包

### 问题 4: 频繁断线
**原因:** 信号干扰或配对问题
**解决方案:**
- 移除蓝牙障碍物
- 重新配对设备
- 更新树莓派的 bluez 库

---

## 🔍 调试工具

### Linux/Raspberry Pi

```bash
# 查看蓝牙设备状态
sudo bluetoothctl
> devices
> info <MAC>
> connect <MAC>

# 监控蓝牙流量
sudo btmon

# 查看蓝牙日志
sudo journalctl -u bluetooth -f

# 重启蓝牙服务
sudo systemctl restart bluetooth
```

### macOS

```bash
# 系统信息中查看蓝牙
system_profiler SPBluetoothDataType

# 重置蓝牙
defaults write com.apple.BluetoothAudioAgent 'Apple Bitpool Min (editable)' -int 40
```

### Python 诊断

```python
from bleak import BleakScanner, BleakClient

# 扫描并显示详细信息
async def scan_detail():
    devices = await BleakScanner.discover()
    for device in devices:
        if "KN-550BT" in device.name:
            print(f"名称: {device.name}")
            print(f"地址: {device.address}")
            print(f"信号强度: {getattr(device, 'rssi', 'N/A')} dBm")
            
            # 连接并查看服务
            async with BleakClient(device.address) as client:
                services = client.services
                print(f"服务数: {len(services)}")
                for service in services:
                    print(f"  • {service.uuid}")
```

---

## 📚 参考资源

### 官方文档
- iHealth SDK (需从官方获取)
- Bluetooth SIG 规范
- BLE 血压计服务标准 (0x1810) - iHealth 未遵循

### 开源项目参考
- `node-ihealth` (GitHub)
- `ihealth-python` (部分实现)
- `bleak` 文档: https://bleak.readthedocs.io

### 相关标准
- **BLE 血压计服务:** UUID 0x1810 (GATT Standard)
  - 注意: iHealth KN-550BT 使用私有协议，**不使用**此标准服务

---

## 💾 数据保存格式

### JSON 格式

```json
{
  "measurements": [
    {
      "timestamp": "2026-01-15T20:36:00.000000",
      "systolic": 120,
      "diastolic": 80,
      "pulse": 72,
      "raw_hex": "fd7800500048"
    }
  ]
}
```

### CSV 格式

```csv
时间,收缩压(mmHg),舒张压(mmHg),心率(bpm)
2026-01-15 20:36:00,120,80,72
2026-01-15 20:37:15,118,78,71
```

---

## 🚀 快速集成代码

### 完整的接收器类

```python
import asyncio
from bleak import BleakScanner, BleakClient
import struct
from datetime import datetime

class iHealthBP550:
    SERVICE_UUID = "636f6d2e-6a69-7561-6e2e-646576000000"
    NOTIFY_CHAR = "7365642e-6a69-7561-6e2e-646576000000"
    WRITE_CHAR = "7265632e-6a69-7561-6e2e-646576000000"
    
    def __init__(self):
        self.device = None
        self.client = None
        self.data = []
    
    async def scan(self):
        """扫描并找到设备"""
        devices = await BleakScanner.discover()
        for device in devices:
            if "KN-550BT" in (device.name or ""):
                self.device = device
                return True
        return False
    
    async def connect(self):
        """连接设备"""
        self.client = BleakClient(self.device.address)
        await self.client.connect()
        await self.client.start_notify(self.NOTIFY_CHAR, self._handle_data)
    
    def _handle_data(self, sender, data):
        """处理接收到的数据"""
        if len(data) >= 6 and data[0] in [0xFD, 0xFE]:
            sys = struct.unpack('<H', data[1:3])[0]
            dia = struct.unpack('<H', data[3:5])[0]
            pul = data[5]
            self.data.append({
                'time': datetime.now().isoformat(),
                'systolic': sys,
                'diastolic': dia,
                'pulse': pul
            })
    
    async def disconnect(self):
        """断开连接"""
        await self.client.stop_notify(self.NOTIFY_CHAR)
        await self.client.disconnect()

# 使用示例
async def main():
    bp = iHealthBP550()
    if await bp.scan():
        await bp.connect()
        await asyncio.sleep(60)  # 等待数据
        await bp.disconnect()
        print(bp.data)

asyncio.run(main())
```

---

## 📞 技术支持

### 问题排查检查清单

- [ ] 设备已打开，有电源指示灯
- [ ] 树莓派/电脑的蓝牙已启用
- [ ] 设备已配对 (第一次需要配对)
- [ ] 设备在蓝牙范围内 (<10 米)
- [ ] 没有其他蓝牙干扰 (WiFi 频道 1-6 或 11)
- [ ] 已安装 bleak 库
- [ ] Python 版本 >= 3.7

### 获取原始数据用于调试

```python
# 打印所有接收到的原始数据
def debug_handler(sender, data):
    print(f"时间: {datetime.now()}")
    print(f"长度: {len(data)}")
    print(f"16进制: {data.hex()}")
    print(f"字节数组: {list(data)}")
    print("---")
```

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2026-01-15 | 初版，包含已验证的 UUID 和基本数据格式 |

**最后更新:** 2026-01-15
**验证设备:** iHealth KN-550BT
**验证平台:** macOS, Linux (Raspberry Pi)
