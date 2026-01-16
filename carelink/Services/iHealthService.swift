//
//  iHealthService.swift
//  HealthPad
//
//  iHealth SDK 封装服务
//  处理与 KN-550BT 血压计的所有通信
//

import Foundation
import CoreBluetooth

// MARK: - 额外通知名称
extension Notification.Name {
    static let measurementStarted = Notification.Name("measurementStarted")
    static let measurementError = Notification.Name("measurementError")
}

// MARK: - iHealth 服务
class iHealthService: NSObject {
    
    static let shared = iHealthService()
    
    // iHealth KN-550BT 蓝牙配置
    private let serviceUUID = CBUUID(string: "636f6d2e-6a69-7561-6e2e-646576000000")
    private let notifyCharUUID = CBUUID(string: "7365642e-6a69-7561-6e2e-646576000000")
    private let writeCharUUID = CBUUID(string: "7265632e-6a69-7561-6e2e-646576000000")
    
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var notifyCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?
    
    private(set) var isInitialized = false
    private(set) var isConnected = false
    private(set) var isScanning = false
    
    private var measurementCallback: ((BloodPressureReading) -> Void)?
    private var connectionCallback: ((Bool, String?) -> Void)?
    
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
    func startMeasurement(callback: @escaping (BloodPressureReading) -> Void) {
        guard isConnected else {
            print("❌ 设备未连接")
            return
        }
        
        measurementCallback = callback
        
        // 发送测量命令
        // 注意：实际命令格式需要参考 iHealth SDK 文档
        let command = Data([0xFD, 0xFD, 0xFA, 0x05, 0x11, 0x00])
        sendCommand(command)
        
        NotificationCenter.default.post(name: .measurementStarted, object: nil)
        print("🩺 开始测量...")
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
    private func parseBloodPressureData(_ data: Data) -> BloodPressureReading? {
        print("📥 收到数据: \(data.hexString)")
        
        // 这是一个示例解析
        // 实际格式需要参考 iHealth SDK 文档或通过抓包分析
        guard data.count >= 7 else {
            return nil
        }
        
        // 常见格式（需要验证）:
        // Byte 0: 标志位
        // Byte 1-2: 收缩压 (little-endian)
        // Byte 3-4: 舒张压 (little-endian)
        // Byte 5-6: 心率
        
        let systolic = Int(data[1]) | (Int(data[2]) << 8)
        let diastolic = Int(data[3]) | (Int(data[4]) << 8)
        let pulse = Int(data[5])
        
        // 合理性检查
        guard (60...250).contains(systolic),
              (40...150).contains(diastolic),
              (40...200).contains(pulse) else {
            print("⚠️ 数据异常")
            return nil
        }
        
        return BloodPressureReading(
            systolic: systolic,
            diastolic: diastolic,
            pulse: pulse
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
        print("🔍 发现设备: \(name)")
        
        // 自动连接第一个找到的设备
        if !isConnected {
            stopScanning()
            connect(to: peripheral) { success, message in
                self.connectionCallback?(success, message)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ 设备已连接: \(peripheral.name ?? "未知")")
        isConnected = true
        
        // 发现服务
        peripheral.discoverServices([serviceUUID])
        
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
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("🔍 发现服务: \(service.uuid)")
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([notifyCharUUID, writeCharUUID], for: service)
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
            
            if characteristic.uuid == notifyCharUUID {
                notifyCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("✅ 订阅通知特性")
            }
            
            if characteristic.uuid == writeCharUUID {
                writeCharacteristic = characteristic
                print("✅ 找到写入特性")
            }
        }
        
        // 连接完成
        if notifyCharacteristic != nil && writeCharacteristic != nil {
            connectionCallback?(true, "设备已就绪")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ 读取数据失败: \(error)")
            return
        }
        
        guard let data = characteristic.value else { return }
        
        // 解析血压数据
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
