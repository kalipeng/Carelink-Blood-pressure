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
    
    // MARK: - 公开属性
    var connectedDeviceName: String? {
        return peripheral?.name
    }
    
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
        print("📱 Initializing iHealth service...")
        
        // Note: For actual deployment, use iHealth Native SDK
        // Using CoreBluetooth for demonstration
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Wait for Bluetooth to be ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.centralManager?.state == .poweredOn {
                self.isInitialized = true
                completion(true)
                print("✅ iHealth service initialized successfully")
            } else {
                completion(false)
                print("❌ Bluetooth not ready")
            }
        }
    }
    
    // MARK: - 扫描设备
    func scanDevices(timeout: TimeInterval = 10.0, completion: @escaping (Bool, String?) -> Void) {
        guard isInitialized else {
            completion(false, "Service not initialized")
            return
        }
        
        guard centralManager?.state == .poweredOn else {
            completion(false, "Please turn on Bluetooth")
            return
        }
        
        print("🔍 Starting scan for iHealth devices...")
        isScanning = true
        connectionCallback = completion
        
        // 扫描指定服务
        centralManager?.scanForPeripherals(
            withServices: [serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
        
        // Timeout stop
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            if self.isScanning {
                self.stopScanning()
                if !self.isConnected {
                    completion(false, "Device not found, please ensure blood pressure monitor is powered on")
                }
            }
        }
    }
    
    private func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
        print("⏸️ Stopping scan")
    }
    
    // MARK: - Connect Device
    func connect(to peripheral: CBPeripheral, completion: @escaping (Bool, String?) -> Void) {
        connectionCallback = completion
        self.peripheral = peripheral
        peripheral.delegate = self
        
        print("📡 Connecting device: \(peripheral.name ?? "Unknown")")
        centralManager?.connect(peripheral, options: nil)
    }
    
    // MARK: - Disconnect
    func disconnect() {
        guard let peripheral = peripheral else { return }
        centralManager?.cancelPeripheralConnection(peripheral)
        print("🔌 Disconnecting")
    }
    
    // MARK: - Start Measurement
    // Two modes:
    // 1. App actively triggers measurement (sends command to device)
    // 2. Device is already measuring, App only receives data (doesn't send command)
    func startMeasurement(callback: @escaping (BloodPressureReading) -> Void) {
        print("\n🩺 [iHealthService] ========== Starting Measurement ==========")
        
        guard isConnected else {
            print("❌ [iHealthService] Device not connected, cannot measure")
            print("💡 [iHealthService] Tip: Please connect blood pressure monitor first")
            return
        }
        
        measurementCallback = callback
        
        print("📱 [iHealthService] Device connected: \(peripheral?.name ?? "Unknown")")
        print("📤 [iHealthService] Preparing to send measurement command...")
        
        // 🎯 Option 1: Send command to let blood pressure monitor auto-start measurement
        // According to iHealth KN-550BT protocol document:
        // Command format: 0xFD 0xFD 0xFA 0x05 0x11 0x00
        let command = Data([0xFD, 0xFD, 0xFA, 0x05, 0x11, 0x00])
        sendCommand(command)
        
        print("✅ [iHealthService] Measurement command sent")
        print("⏳ [iHealthService] Waiting for blood pressure monitor to start measuring...")
        print("💡 [iHealthService] Please ensure cuff is correctly worn")
        print("🩺 [iHealthService] =====================================\n")
        
        NotificationCenter.default.post(name: .measurementStarted, object: nil)
    }
    
    // MARK: - Passive Measurement Data Reception
    // If user manually presses blood pressure monitor button, app will auto-receive data
    // No need to call startMeasurement()
    func listenForMeasurement(callback: @escaping (BloodPressureReading) -> Void) {
        print("👂 [iHealthService] Starting to listen for blood pressure monitor data...")
        print("💡 [iHealthService] You can press button on blood pressure monitor directly to start measurement")
        measurementCallback = callback
    }
    
    // MARK: - Send Command
    private func sendCommand(_ data: Data) {
        guard let characteristic = writeCharacteristic else {
            print("❌ Write characteristic not found")
            return
        }
        
        peripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
        print("📤 Sending command: \(data.hexString)")
    }
    
    // MARK: - Parse Data
    // MARK: - Data Parsing (According to iHealth KN-550BT Protocol Document)
    private func parseBloodPressureData(_ data: Data) -> BloodPressureReading? {
        print("📥 Received data (\(data.count) bytes): \(data.hexString)")
        
        // According to protocol document, minimum data packet length is 6 bytes
        guard data.count >= 6 else {
            print("⚠️ Data packet too short (< 6 bytes)")
            return nil
        }
        
        // Check data packet identifier (Byte 0)
        // Must be 0xFD or 0xFE
        guard data[0] == 0xFD || data[0] == 0xFE else {
            print("⚠️ Invalid data packet identifier: 0x\(String(format: "%02X", data[0]))")
            return nil
        }
        
        // Parse data (Little Endian format)
        // Byte 1-2: Systolic - LSB first
        let systolic = Int(data[1]) | (Int(data[2]) << 8)
        
        // Byte 3-4: Diastolic - LSB first
        let diastolic = Int(data[3]) | (Int(data[4]) << 8)
        
        // Byte 5: Pulse - single byte
        let pulse = Int(data[5])
        
        // Data validity check (according to protocol document ranges)
        // Systolic: 50-250 mmHg
        // Diastolic: 30-150 mmHg
        // Pulse: 40-200 bpm
        guard (50...250).contains(systolic) else {
            print("⚠️ Systolic out of range: \(systolic) mmHg (should be 50-250)")
            return nil
        }
        
        guard (30...150).contains(diastolic) else {
            print("⚠️ Diastolic out of range: \(diastolic) mmHg (should be 30-150)")
            return nil
        }
        
        guard (40...200).contains(pulse) else {
            print("⚠️ Pulse out of range: \(pulse) bpm (should be 40-200)")
            return nil
        }
        
        print("✅ Data parsed successfully: \(systolic)/\(diastolic) mmHg, Pulse \(pulse) bpm")
        
        return BloodPressureReading(
            systolic: systolic,
            diastolic: diastolic,
            pulse: pulse,
            source: "bluetooth"  // 🔍 Marked as real Bluetooth data
        )
    }
}

// MARK: - CBCentralManagerDelegate
extension iHealthService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth is on")
        case .poweredOff:
            print("❌ Bluetooth is off")
        case .unsupported:
            print("❌ Device doesn't support Bluetooth")
        case .unauthorized:
            print("❌ Bluetooth permission not authorized")
        case .resetting:
            print("⏳ Bluetooth resetting")
        case .unknown:
            print("❓ Bluetooth state unknown")
        @unknown default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let name = peripheral.name ?? "Unknown Device"
        let rssiValue = RSSI.intValue
        
        print("🔍 Device discovered: \(name)")
        print("   • MAC: \(peripheral.identifier.uuidString)")
        print("   • RSSI: \(rssiValue) dBm")
        
        // Check if it's an iHealth KN-550BT device
        // Device name may be "KN-550BT" or contain "iHealth" or "KN-550"
        let isIHealthDevice = name.contains("KN-550BT") ||
                              name.contains("iHealth") ||
                              name.contains("KN-550")
        
        if !isIHealthDevice {
            print("   ⏭️ Not an iHealth device, skipping")
            return
        }
        
        // Check signal strength (avoid connecting to devices with weak signal)
        if rssiValue < -80 {
            print("   ⚠️ Signal too weak (\(rssiValue) dBm), please move closer to device")
        }
        
        // Auto-connect to found iHealth device
        if !isConnected && self.peripheral == nil {
            print("   ✨ Found iHealth KN-550BT, preparing to connect...")
            stopScanning()
            connect(to: peripheral) { success, message in
                self.connectionCallback?(success, message)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Device connected: \(peripheral.name ?? "Unknown")")
        
        // Discover services (including iHealth main service and battery service)
        peripheral.discoverServices([serviceUUID, batteryServiceUUID])
        
        NotificationCenter.default.post(name: .deviceConnected, object: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("❌ Device disconnected")
        isConnected = false
        self.peripheral = nil
        notifyCharacteristic = nil
        writeCharacteristic = nil
        
        NotificationCenter.default.post(name: .deviceDisconnected, object: nil)
        
        if let error = error {
            print("Disconnect reason: \(error.localizedDescription)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Connection failed")
        connectionCallback?(false, error?.localizedDescription ?? "Connection failed")
    }
}

// MARK: - CBPeripheralDelegate
extension iHealthService: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("❌ Service discovery failed: \(error)")
            connectionCallback?(false, "Service discovery failed")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        print("🔍 Found \(services.count) service(s)")
        
        for service in services {
            print("   • Service: \(service.uuid)")
            
            // iHealth main service
            if service.uuid == serviceUUID {
                print("   ✅ iHealth main service")
                peripheral.discoverCharacteristics([notifyCharUUID, writeCharUUID], for: service)
            }
            
            // Battery service
            else if service.uuid == batteryServiceUUID {
                print("   🔋 Battery service")
                peripheral.discoverCharacteristics([batteryLevelCharUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ Characteristic discovery failed: \(error)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("🔍 Discovered characteristic: \(characteristic.uuid)")
            
            // iHealth main service characteristics
            if characteristic.uuid == notifyCharUUID {
                notifyCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("✅ Subscribed to data notification characteristic (NOTIFY)")
            }
            
            if characteristic.uuid == writeCharUUID {
                writeCharacteristic = characteristic
                print("✅ Found command write characteristic (WRITE)")
            }
            
            // Battery service characteristic
            if characteristic.uuid == batteryLevelCharUUID {
                batteryCharacteristic = characteristic
                // Read battery level
                peripheral.readValue(for: characteristic)
                // Subscribe to battery level change notifications (if supported)
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                print("✅ Found battery level characteristic")
            }
        }
        
        // iHealth main service connection complete
        if service.uuid == serviceUUID &&
           notifyCharacteristic != nil &&
           writeCharacteristic != nil {
            isConnected = true
            print("🎉 iHealth KN-550BT device ready")
            connectionCallback?(true, "Device ready")
            
            // Send connection success notification
            NotificationCenter.default.post(name: .deviceConnected, object: nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Data read failed: \(error)")
            return
        }
        
        guard let data = characteristic.value else { return }
        
        // Handle different types of data based on characteristic UUID
        switch characteristic.uuid {
        case notifyCharUUID:
            // iHealth blood pressure data
            handleBloodPressureData(data)
            
        case batteryLevelCharUUID:
            // Battery level data
            handleBatteryData(data)
            
        default:
            print("📦 Unknown characteristic data: \(characteristic.uuid)")
        }
    }
    
    // MARK: - Handle Blood Pressure Data
    private func handleBloodPressureData(_ data: Data) {
        if let reading = parseBloodPressureData(data) {
            print("🩺 Measurement complete: \(reading.systolic)/\(reading.diastolic) mmHg, Pulse: \(reading.pulse) bpm")
            
            // Save locally
            BloodPressureReading.add(reading)
            
            // Callback
            measurementCallback?(reading)
            
            // Send notification
            NotificationCenter.default.post(
                name: .measurementCompleted,
                object: reading
            )
            
            // Voice announcement (not needed for now)
            // VoiceService.shared.speakMeasurement(reading)
        }
    }
    
    // MARK: - Handle Battery Data
    private func handleBatteryData(_ data: Data) {
        guard data.count > 0 else { return }
        
        let level = Int(data[0])
        batteryLevel = level
        
        print("🔋 Battery level: \(level)%")
        
        // Send battery level update notification
        NotificationCenter.default.post(
            name: .batteryLevelUpdated,
            object: level
        )
        
        // Warn if battery is low
        if level < 20 {
            print("⚠️ Low battery, please charge")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Write failed: \(error)")
        } else {
            print("✅ Command sent successfully")
        }
    }
}

// MARK: - Data 扩展
extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined(separator: " ")
    }
}
