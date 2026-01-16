//
//  BluetoothConnectionHelper.swift
//  carelink
//
//  蓝牙连接强制助手 - 帮助调试和连接 iHealth KN-550BT
//

import Foundation
import CoreBluetooth

class BluetoothConnectionHelper {
    
    static let shared = BluetoothConnectionHelper()
    
    private init() {}
    
    // MARK: - 🔧 强制初始化并扫描
    static func forceConnectToDevice() {
        print("\n" + String(repeating: "=", count: 60))
        print("🔧 [BluetoothHelper] 强制连接蓝牙设备")
        print(String(repeating: "=", count: 60))
        
        let service = iHealthService.shared
        
        // Step 1: 检查当前状态
        print("\n📊 Step 1: 检查当前状态")
        print("   • 已初始化: \(service.isInitialized)")
        print("   • 已连接: \(service.isConnected)")
        print("   • 正在扫描: \(service.isScanning)")
        
        // Step 2: 初始化服务（如果需要）
        if !service.isInitialized {
            print("\n🔄 Step 2: 初始化服务...")
            service.initialize { success in
                if success {
                    print("✅ 初始化成功")
                    // 初始化成功后立即扫描
                    BluetoothConnectionHelper.startScanning()
                } else {
                    print("❌ 初始化失败")
                    BluetoothConnectionHelper.showTroubleshooting()
                }
            }
        } else {
            print("\n✅ Step 2: 服务已初始化")
            // 直接扫描
            BluetoothConnectionHelper.startScanning()
        }
    }
    
    // MARK: - 🔍 开始扫描
    static func startScanning() {
        print("\n🔍 Step 3: 开始扫描设备...")
        
        iHealthService.shared.scanDevices(timeout: 30.0) { success, message in
            if success {
                print("✅ 扫描启动成功")
                print("⏳ 等待 30 秒寻找设备...")
                print("💡 请确保血压计已开机并在范围内")
            } else {
                print("❌ 扫描失败: \(message ?? "未知错误")")
                BluetoothConnectionHelper.showTroubleshooting()
            }
        }
    }
    
    // MARK: - 📊 显示详细状态
    static func showDetailedStatus() {
        print("\n" + String(repeating: "=", count: 60))
        print("📊 [BluetoothHelper] 蓝牙详细状态")
        print(String(repeating: "=", count: 60))
        
        let service = iHealthService.shared
        
        // 1. 服务状态
        print("\n1️⃣ iHealthService 状态:")
        print("   • 已初始化: \(service.isInitialized ? "✅" : "❌")")
        print("   • 已连接: \(service.isConnected ? "✅" : "❌")")
        print("   • 正在扫描: \(service.isScanning ? "✅" : "❌")")
        
        // 2. 蓝牙权限
        print("\n2️⃣ 蓝牙权限:")
        print("   • 检查方法: iPhone 设置 > carelink > 蓝牙")
        print("   • 必须开启: ✅")
        
        // 3. 设备配置
        print("\n3️⃣ iHealth KN-550BT 配置:")
        print("   • 服务 UUID: 636F6D2E-6A69-7561-6E2E-646576000000")
        print("   • NOTIFY UUID: 7365642E-6A69-7561-6E2E-646576000000")
        print("   • WRITE UUID: 7265632E-6A69-7561-6E2E-646576000000")
        
        // 4. 设备检查清单
        print("\n4️⃣ 设备检查清单:")
        print("   [ ] 血压计已开机")
        print("   [ ] 血压计在 5 米范围内")
        print("   [ ] iPhone 蓝牙已开启")
        print("   [ ] App 蓝牙权限已授权")
        print("   [ ] 血压计显示配对模式")
        
        print("\n" + String(repeating: "=", count: 60) + "\n")
    }
    
    // MARK: - 🆘 故障排查
    static func showTroubleshooting() {
        print("\n" + String(repeating: "⚠️", count: 30))
        print("🆘 蓝牙连接故障排查")
        print(String(repeating: "⚠️", count: 30))
        
        print("\n📋 请按顺序检查以下项目：")
        
        print("\n1️⃣ 检查血压计:")
        print("   • 按下电源按钮开机")
        print("   • 屏幕应该亮起")
        print("   • 设备应该显示准备状态")
        
        print("\n2️⃣ 检查 iPhone 蓝牙:")
        print("   • 打开 iPhone 设置")
        print("   • 点击 蓝牙")
        print("   • 确保蓝牙开关已开启（绿色）")
        
        print("\n3️⃣ 检查 App 权限:")
        print("   • 打开 iPhone 设置")
        print("   • 向下滚动找到 carelink")
        print("   • 点击进入")
        print("   • 确保 蓝牙 权限已开启")
        
        print("\n4️⃣ 检查距离:")
        print("   • 将血压计放在 iPhone 旁边（< 1 米）")
        print("   • 避免金属物体阻挡")
        
        print("\n5️⃣ 重启设备:")
        print("   • 关闭血压计")
        print("   • 等待 5 秒")
        print("   • 重新开机")
        print("   • 重新运行 app")
        
        print("\n6️⃣ 检查蓝牙配对:")
        print("   • 打开 iPhone 设置 > 蓝牙")
        print("   • 查看 我的设备 列表")
        print("   • 如果看到 KN-550BT，点击 (i) > 忽略此设备")
        print("   • 然后重新扫描")
        
        print("\n" + String(repeating: "=", count: 60) + "\n")
    }
    
    // MARK: - 🧪 测试蓝牙系统
    static func testBluetoothSystem() {
        print("\n" + String(repeating: "=", count: 60))
        print("🧪 [BluetoothHelper] 测试蓝牙系统")
        print(String(repeating: "=", count: 60))
        
        // 创建临时 CentralManager 测试
        let testManager = CBCentralManager(delegate: nil, queue: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("\n📊 蓝牙系统状态:")
            
            switch testManager.state {
            case .poweredOn:
                print("   ✅ 蓝牙已开启并可用")
            case .poweredOff:
                print("   ❌ 蓝牙已关闭")
                print("   💡 解决: iPhone 设置 > 蓝牙 > 开启")
            case .unauthorized:
                print("   ❌ 蓝牙权限未授权")
                print("   💡 解决: iPhone 设置 > carelink > 蓝牙 > 开启")
            case .unsupported:
                print("   ❌ 设备不支持蓝牙")
            case .resetting:
                print("   ⏳ 蓝牙正在重置")
            case .unknown:
                print("   ❓ 蓝牙状态未知")
            @unknown default:
                print("   ❓ 未知状态")
            }
            
            print("\n" + String(repeating: "=", count: 60) + "\n")
        }
    }
    
    // MARK: - 🔄 完整连接流程
    static func fullConnectionWorkflow() {
        print("\n" + String(repeating: "🚀", count: 30))
        print("开始完整连接流程")
        print(String(repeating: "🚀", count: 30))
        
        // 1. 测试蓝牙系统
        testBluetoothSystem()
        
        // 2. 等待 1.5 秒后显示状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showDetailedStatus()
        }
        
        // 3. 等待 2 秒后强制连接
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            forceConnectToDevice()
        }
    }
}
