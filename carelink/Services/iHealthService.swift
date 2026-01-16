//
//  iHealthService.swift
//  HealthPad
//
//  iHealth SDK 封装服务
//  处理与 KN-550BT 血压计的所有通信
//
//  协议文档版本: 1.0
//  设备型号: iHealth KN-550BT
//  最后更新: 2026-01-15
//

import Foundation
import CoreBluetooth

// MARK: - 额外通知名称
extension Notification.Name {
    static let measurementStarted = Notification.Name("measurementStarted")
    static let measurementError = Notification.Name("measurementError")
    static let batteryLevelUpdated = Notification.Name("batteryLevelUpdated")
}

// MARK: - iHealth 服务
class iHealthService: NSObject {
    
    static let shared = iHealthService()
    
    // MARK: - iHealth KN-550BT 蓝牙 UUID（根据协议文档）
    // 主服务: ASCII "com.jiuan.dev"
    private let serviceUUID = CBUUID(string: "636f6d2e-6a69-7561-6e2e-646576000000")
    
    // NOTIFY 特性: ASCII "sed." - 接收血压数据
    private let notifyCharUUID = CBUUID(string: "7365642e-6a69-7561-6e2e-646576000000")
    
    // WRITE 特性: ASCII "rec." - 发送命令到设备
    private let writeCharUUID = CBUUID(string: "7265632e-6a69-7561-6e2e-646576000000")
    
    // 电池服务（标准 BLE）
    private let batteryServiceUUID = CBUUID(string: "0000180F-0000-1000-8000-00805F9B34FB")
    private let batteryLevelCharUUID = CBUUID(string: "00002A19-0000-1000-8000-00805F9B34FB")
    
    // MARK: - 蓝牙对象
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var notifyCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?
    private var batteryCharacteristic: CBCharacteristic?
    
    // MARK: - 状态
    private(set) var isInitialized = false
    private(set) var isConnected = false
    private(set) var isScanning = false
    private(set) var batteryLevel: Int = 100
    
    // MARK: - 回调
    private var measurementCallback: ((BloodPressureReading) -> Void)?
    private var connectionCallback: ((Bool, String?) -> Void)?
    
    // MARK: - 数据解析缓冲
    private var dataBuffer = Data()
    
    private override init() {
        super.init()
    }
    
    // MARK: - 初始化
    func initialize(completion: @escaping (Bool) -> Void) {
        print("📱 初始化 iHealth 服务...")
        
        // 注意：实际部署时需要使用 iHealth Native SDK
        // 这里使用 CoreBluetooth 作为演示
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // 等待蓝牙准备就绪
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.centralManager?.state == .poweredOn {
                self.isInitialized = true
                completion(true)
                print("✅ iHealth 服务初始化成功")
            } else {
                completion(false)
                print("❌ 蓝牙未准备就绪")
            }
        }
    }
    
    // MARK: - 扫描设备
    func scanDevices(timeout: TimeInterval = 10.0, completion: @escaping (Bool, String?) -> Void) {
        guard isInitialized else {
            completion(false, "服务未初始化")
            return
        }
        
        guard centralManager?.state == .poweredOn else {
            completion(false, "请开启蓝牙")
            return
        }
        
        print("🔍 开始扫描 iHealth 设备...")
        isScanning = true
        connectionCallback = completion
        
        // 扫描指定服务
        centralManager?.scanForPeripherals(
            withServices: [serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
        
        // 超时停止
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            if self.isScanning {
                self.stopScanning()
                if !self.isConnected {
                    completion(false, "未找到设备，请确保血压计已开启")
                }
            }
        }
    }
    
    private func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
        print("⏸️ 停止扫描")
    }
    
    // MARK: - 连接设备
    func connect(to peripheral: CBPeripheral, completion: @escaping (Bool, String?) -> Void) {
        connectionCallback = completion
        self.peripheral = peripheral
        peripheral.delegate = self
        
        print("📡 连接设备: \(peripheral.name ?? "未知")")
        centralManager?.connect(peripheral, options: nil)
    }
    
    // MARK: - 断开连接
    func disconnect() {
        guard let peripheral = peripheral else { return }
        centralManager?.cancelPeripheralConnection(peripheral)
        print("🔌 断开连接")
    }
    
    // MARK: - 开始测量
    // 两种模式：
    // 1. App 主动触发测量（发送命令到设备）
    // 2. 设备已经在测量，App 只接收数据（不发送命令）
    func startMeasurement(callback: @escaping (BloodPressureReading) -> Void) {
        print("\n🩺 [iHealthService] ========== 开始测量 ==========")
        
        guard isConnected else {
            print("❌ [iHealthService] 设备未连接，无法测量")
            print("💡 [iHealthService] 提示：请先连接血压计")
            return
        }
        
        measurementCallback = callback
        
        print("📱 [iHealthService] 设备已连接: \(peripheral?.name ?? "未知")")
        print("📤 [iHealthService] 准备发送测量命令...")
        
        // 🎯 方案 1：发送命令让血压计自动开始测量
        // 根据 iHealth KN-550BT 协议文档：
        // 命令格式: 0xFD 0xFD 0xFA 0x05 0x11 0x00
        let command = Data([0xFD, 0xFD, 0xFA, 0x05, 0x11, 0x00])
        sendCommand(command)
        
        print("✅ [iHealthService] 已发送测量命令")
        print("⏳ [iHealthService] 等待血压计开始测量...")
        print("💡 [iHealthService] 请确保已正确佩戴袖带")
        print("🩺 [iHealthService] =====================================\n")
        
        NotificationCenter.default.post(name: .measurementStarted, object: nil)
    }
    
    // MARK: - 被动接收测量数据
    // 如果用户手动按了血压计的按钮，app 会自动接收数据
    // 不需要调用 startMeasurement()
    func listenForMeasurement(callback: @escaping (BloodPressureReading) -> Void) {
        print("👂 [iHealthService] 开始监听血压计数据...")
        print("💡 [iHealthService] 你可以直接按血压计上的按钮开始测量")
        measurementCallback = callback
    }
    
    // MARK: - 发送命令
    private func sendCommand(_ data: Data) {
        guard let characteristic = writeCharacteristic else {
            print("❌ 写入特性未找到")
            return
        }
        
        peripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
        print("📤 发送命令: \(data.hexString)")
    }
    
    // MARK: - 解析数据
    // MARK: - 数据解析（根据 iHealth KN-550BT 协议文档）
    private func parseBloodPressureData(_ data: Data) -> BloodPressureReading? {
        print("📥 收到数据 (\(data.count) 字节): \(data.hexString)")
        
        // 根据协议文档，最小数据包长度为 6 字节
        guard data.count >= 6 else {
            print("⚠️ 数据包太短 (< 6 字节)")
            return nil
        }
        
        // 检查数据包标识符 (Byte 0)
        // 必须是 0xFD 或 0xFE
        guard data[0] == 0xFD || data[0] == 0xFE else {
            print("⚠️ 无效的数据包标识符: 0x\(String(format: "%02X", data[0]))")
            return nil
        }
        
        // 解析数据（小端格式 Little Endian）
        // Byte 1-2: 收缩压 (Systolic) - LSB first
        let systolic = Int(data[1]) | (Int(data[2]) << 8)
        
        // Byte 3-4: 舒张压 (Diastolic) - LSB first
        let diastolic = Int(data[3]) | (Int(data[4]) << 8)
        
        // Byte 5: 心率 (Pulse) - 单字节
        let pulse = Int(data[5])
        
        // 数据合理性检查（根据协议文档的范围）
        // 收缩压: 50-250 mmHg
        // 舒张压: 30-150 mmHg
        // 心率: 40-200 bpm
        guard (50...250).contains(systolic) else {
            print("⚠️ 收缩压超出范围: \(systolic) mmHg (应在 50-250)")
            return nil
        }
        
        guard (30...150).contains(diastolic) else {
            print("⚠️ 舒张压超出范围: \(diastolic) mmHg (应在 30-150)")
            return nil
        }
        
        guard (40...200).contains(pulse) else {
            print("⚠️ 心率超出范围: \(pulse) bpm (应在 40-200)")
            return nil
        }
        
        print("✅ 数据解析成功: \(systolic)/\(diastolic) mmHg, 心率 \(pulse) bpm")
        
        return BloodPressureReading(
            systolic: systolic,
            diastolic: diastolic,
            pulse: pulse,
            source: "bluetooth"  // 🔍 标记为真实蓝牙数据
        )
    }
}

// MARK: - CBCentralManagerDelegate
extension iHealthService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("✅ 蓝牙已开启")
        case .poweredOff:
            print("❌ 蓝牙已关闭")
        case .unsupported:
            print("❌ 设备不支持蓝牙")
        case .unauthorized:
            print("❌ 蓝牙权限未授权")
        case .resetting:
            print("⏳ 蓝牙重置中")
        case .unknown:
            print("❓ 蓝牙状态未知")
        @unknown default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let name = peripheral.name ?? "未知设备"
        let rssiValue = RSSI.intValue
        
        print("🔍 发现设备: \(name)")
        print("   • MAC: \(peripheral.identifier.uuidString)")
        print("   • RSSI: \(rssiValue) dBm")
        
        // 检查是否是 iHealth KN-550BT 设备
        // 设备名称可能是 "KN-550BT" 或包含 "iHealth" 或 "KN-550"
        let isIHealthDevice = name.contains("KN-550BT") ||
                              name.contains("iHealth") ||
                              name.contains("KN-550")
        
        if !isIHealthDevice {
            print("   ⏭️ 不是 iHealth 设备，跳过")
            return
        }
        
        // 检查信号强度（避免连接信号太弱的设备）
        if rssiValue < -80 {
            print("   ⚠️ 信号太弱 (\(rssiValue) dBm)，建议靠近设备")
        }
        
        // 自动连接找到的 iHealth 设备
        if !isConnected && self.peripheral == nil {
            print("   ✨ 找到 iHealth KN-550BT，准备连接...")
            stopScanning()
            connect(to: peripheral) { success, message in
                self.connectionCallback?(success, message)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ 设备已连接: \(peripheral.name ?? "未知")")
        
        // 发现服务（包括 iHealth 主服务和电池服务）
        peripheral.discoverServices([serviceUUID, batteryServiceUUID])
        
        NotificationCenter.default.post(name: .deviceConnected, object: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("❌ 设备已断开")
        isConnected = false
        self.peripheral = nil
        notifyCharacteristic = nil
        writeCharacteristic = nil
        
        NotificationCenter.default.post(name: .deviceDisconnected, object: nil)
        
        if let error = error {
            print("断开原因: \(error.localizedDescription)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ 连接失败")
        connectionCallback?(false, error?.localizedDescription ?? "连接失败")
    }
}

// MARK: - CBPeripheralDelegate
extension iHealthService: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("❌ 发现服务失败: \(error)")
            connectionCallback?(false, "发现服务失败")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        print("🔍 找到 \(services.count) 个服务")
        
        for service in services {
            print("   • 服务: \(service.uuid)")
            
            // iHealth 主服务
            if service.uuid == serviceUUID {
                print("   ✅ iHealth 主服务")
                peripheral.discoverCharacteristics([notifyCharUUID, writeCharUUID], for: service)
            }
            
            // 电池服务
            else if service.uuid == batteryServiceUUID {
                print("   🔋 电池服务")
                peripheral.discoverCharacteristics([batteryLevelCharUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ 发现特性失败: \(error)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("🔍 发现特性: \(characteristic.uuid)")
            
            // iHealth 主服务的特性
            if characteristic.uuid == notifyCharUUID {
                notifyCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("✅ 订阅数据通知特性 (NOTIFY)")
            }
            
            if characteristic.uuid == writeCharUUID {
                writeCharacteristic = characteristic
                print("✅ 找到命令写入特性 (WRITE)")
            }
            
            // 电池服务特性
            if characteristic.uuid == batteryLevelCharUUID {
                batteryCharacteristic = characteristic
                // 读取电池电量
                peripheral.readValue(for: characteristic)
                // 订阅电池电量变化通知（如果支持）
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                print("✅ 找到电池电量特性")
            }
        }
        
        // iHealth 主服务连接完成
        if service.uuid == serviceUUID &&
           notifyCharacteristic != nil &&
           writeCharacteristic != nil {
            isConnected = true
            print("🎉 iHealth KN-550BT 设备已就绪")
            connectionCallback?(true, "设备已就绪")
            
            // 发送连接成功通知
            NotificationCenter.default.post(name: .deviceConnected, object: nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ 读取数据失败: \(error)")
            return
        }
        
        guard let data = characteristic.value else { return }
        
        // 根据特性 UUID 处理不同类型的数据
        switch characteristic.uuid {
        case notifyCharUUID:
            // iHealth 血压数据
            handleBloodPressureData(data)
            
        case batteryLevelCharUUID:
            // 电池电量数据
            handleBatteryData(data)
            
        default:
            print("📦 未知特性数据: \(characteristic.uuid)")
        }
    }
    
    // MARK: - 处理血压数据
    private func handleBloodPressureData(_ data: Data) {
        if let reading = parseBloodPressureData(data) {
            print("🩺 测量完成: \(reading.systolic)/\(reading.diastolic) mmHg, 心率: \(reading.pulse) bpm")
            
            // 保存到本地
            BloodPressureReading.add(reading)
            
            // 回调
            measurementCallback?(reading)
            
            // 发送通知
            NotificationCenter.default.post(
                name: .measurementCompleted,
                object: reading
            )
            
            // 语音播报 (暂时不需要)
            // VoiceService.shared.speakMeasurement(reading)
        }
    }
    
    // MARK: - 处理电池数据
    private func handleBatteryData(_ data: Data) {
        guard data.count > 0 else { return }
        
        let level = Int(data[0])
        batteryLevel = level
        
        print("🔋 电池电量: \(level)%")
        
        // 发送电池电量更新通知
        NotificationCenter.default.post(
            name: .batteryLevelUpdated,
            object: level
        )
        
        // 如果电量过低，发出警告
        if level < 20 {
            print("⚠️ 电池电量低，请充电")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ 写入失败: \(error)")
        } else {
            print("✅ 命令发送成功")
        }
    }
}

// MARK: - Data 扩展
extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined(separator: " ")
    }
}
