#!/usr/bin/env python3
"""
iHealth KN-550BT Blood Pressure Monitor - Bluetooth Handler
Receives and parses measurements from iHealth KN-550BT
"""

import asyncio
import sys
import json
from datetime import datetime
from bleak import BleakScanner, BleakClient

class iHealthBP550:
    """iHealth KN-550BT血压计处理类"""
    
    # iHealth 私有协议 UUIDs (根据你提供的信息)
    SERVICE_UUID = "636f6d2e-6a69-7561-6e2e-646576000000"  # "com.jiuan.dev"
    NOTIFY_CHAR = "7365642e-6a69-7561-6e2e-646576000000"   # "sed." (接收数据)
    WRITE_CHAR = "7265632e-6a69-7561-6e2e-646576000000"    # "rec." (发送命令)
    
    DEVICE_NAME = "KN-550BT"
    
    def __init__(self):
        self.device = None
        self.client = None
        self.measurement_data = []
    
    async def scan(self, timeout=10):
        """扫描并找到 iHealth 设备"""
        print(f"🔍 扫描蓝牙设备 ({timeout} 秒)...")
        
        try:
            devices = await BleakScanner.discover(timeout=timeout)
            
            for device in devices:
                if self.DEVICE_NAME in (device.name or ""):
                    self.device = device
                    print(f"✓ 找到设备: {device.name} ({device.address})")
                    return True
            
            print(f"✗ 未找到 {self.DEVICE_NAME}")
            return False
            
        except Exception as e:
            print(f"✗ 扫描失败: {e}")
            return False
    
    async def connect(self):
        """连接到设备"""
        if not self.device:
            print("✗ 未找到设备")
            return False
        
        try:
            print(f"🔗 正在连接到 {self.device.name}...")
            self.client = BleakClient(self.device.address)
            await self.client.connect()
            print("✓ 已连接")
            
            # 订阅通知
            await self.client.start_notify(
                self.NOTIFY_CHAR,
                self.notification_handler
            )
            print("✓ 已订阅数据通知")
            
            return True
            
        except Exception as e:
            print(f"✗ 连接失败: {e}")
            return False
    
    async def disconnect(self):
        """断开连接"""
        if self.client:
            try:
                await self.client.stop_notify(self.NOTIFY_CHAR)
                await self.client.disconnect()
                print("✓ 已断开连接")
            except Exception as e:
                print(f"⚠ 断开连接出错: {e}")
    
    def notification_handler(self, sender, data):
        """处理接收到的数据"""
        timestamp = datetime.now().isoformat()
        
        print(f"\n📩 收到数据:")
        print(f"   时间: {timestamp}")
        print(f"   长度: {len(data)} 字节")
        print(f"   16进制: {data.hex()}")
        
        # 尝试解析数据
        parsed = self.parse_data(data)
        if parsed:
            print(f"\n🩺 血压测量:")
            print(f"   收缩压 (SYS): {parsed['systolic']} mmHg")
            print(f"   舒张压 (DIA): {parsed['diastolic']} mmHg")
            print(f"   心率 (PUL): {parsed['pulse']} bpm")
            
            # 保存到列表
            parsed['timestamp'] = timestamp
            self.measurement_data.append(parsed)
    
    def parse_data(self, data):
        """
        解析血压数据
        
        注意: iHealth KN-550BT 使用私有协议，数据格式需要逆向工程
        这是一个基础的解析模板，实际格式需要根据设备反馈调整
        """
        try:
            if len(data) < 6:
                return None
            
            # 最常见的格式尝试
            # 格式: [标识] [收缩压] [舒张压] [心率] [其他数据...]
            
            # 尝试1: 直接字节解析
            if data[0] == 0xFD or data[0] == 0xFE:
                import struct
                
                # 假设字节顺序为小端
                systolic = struct.unpack('<H', data[1:3])[0]
                diastolic = struct.unpack('<H', data[3:5])[0]
                pulse = data[5]
                
                # 合理性检查 (正常血压范围)
                if 50 <= systolic <= 250 and 30 <= diastolic <= 150 and pulse <= 200:
                    return {
                        'systolic': systolic,
                        'diastolic': diastolic,
                        'pulse': pulse,
                        'raw': data.hex()
                    }
            
            # 如果不匹配，打印原始数据供调试
            print(f"   ℹ 无法自动解析，数据可能需要自定义解析器")
            print(f"   原始字节: {list(data)}")
            
        except Exception as e:
            print(f"   ✗ 解析错误: {e}")
        
        return None
    
    async def send_command(self, command_bytes):
        """发送命令到设备"""
        if not self.client or not self.client.is_connected:
            print("✗ 设备未连接")
            return False
        
        try:
            print(f"📤 发送命令: {command_bytes.hex()}")
            await self.client.write_gatt_char(
                self.WRITE_CHAR,
                command_bytes,
                response=False
            )
            return True
        except Exception as e:
            print(f"✗ 发送失败: {e}")
            return False
    
    def get_measurements(self):
        """获取已收集的测量数据"""
        return self.measurement_data
    
    def save_measurements(self, filepath):
        """保存测量数据为 JSON"""
        try:
            with open(filepath, 'w') as f:
                json.dump(self.measurement_data, f, indent=2)
            print(f"✓ 测量数据已保存到 {filepath}")
        except Exception as e:
            print(f"✗ 保存失败: {e}")


async def main():
    """主程序"""
    
    print("\n╔════════════════════════════════════════════════════════╗")
    print("║    iHealth KN-550BT - Bluetooth 血压计接收器          ║")
    print("╚════════════════════════════════════════════════════════╝\n")
    
    monitor = iHealthBP550()
    
    # 扫描设备
    if not await monitor.scan(timeout=10):
        print("\n❌ 未找到设备")
        print("   请确保:")
        print("   • iHealth KN-550BT 已开启")
        print("   • 设备在配对模式或已配对")
        print("   • 设备在蓝牙范围内 (<10 米)")
        return
    
    # 连接设备
    if not await monitor.connect():
        print("\n❌ 连接失败")
        return
    
    # 等待并接收数据
    print("\n" + "="*60)
    print("✓ 设备已就绪！")
    print("  请在 iHealth KN-550BT 上按 [M] 键开始测量")
    print("  或等待历史数据传输")
    print("  ")
    print("  按 Ctrl+C 停止")
    print("="*60)
    
    try:
        # 保持连接 5 分钟
        await asyncio.sleep(300)
    except KeyboardInterrupt:
        print("\n\n用户中断")
    finally:
        await monitor.disconnect()
    
    # 显示收集的数据
    measurements = monitor.get_measurements()
    if measurements:
        print(f"\n📊 收集到 {len(measurements)} 条测量数据:")
        for i, m in enumerate(measurements, 1):
            print(f"   {i}. SYS: {m['systolic']} DIA: {m['diastolic']} PUL: {m['pulse']}")
        
        # 保存数据
        monitor.save_measurements("/tmp/ihealth_measurements.json")
    else:
        print("\n⚠ 未收到任何测量数据")


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n\n已中断")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        sys.exit(1)
