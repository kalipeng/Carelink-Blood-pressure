//
//  BluetoothConnectionHelper.swift
//  carelink
//
//  Bluetooth Connection Helper - Helps debug and connect iHealth KN-550BT
//

import Foundation
import CoreBluetooth

class BluetoothConnectionHelper {
    
    static let shared = BluetoothConnectionHelper()
    
    private init() {}
    
    // MARK: - 🔧 Force Initialize and Scan
    static func forceConnectToDevice() {
        print("\n" + String(repeating: "=", count: 60))
        print("🔧 [BluetoothHelper] Force Connect Bluetooth Device")
        print(String(repeating: "=", count: 60))
        
        let service = iHealthService.shared
        
        // Step 1: Check current status
        print("\n📊 Step 1: Check current status")
        print("   • Initialized: \(service.isInitialized)")
        print("   • Connected: \(service.isConnected)")
        print("   • Scanning: \(service.isScanning)")
        
        // Step 2: Initialize service (if needed)
        if !service.isInitialized {
            print("\n🔄 Step 2: Initializing service...")
            service.initialize { success in
                if success {
                    print("✅ Initialization successful")
                    // Start scanning after successful initialization
                    BluetoothConnectionHelper.startScanning()
                } else {
                    print("❌ Initialization failed")
                    BluetoothConnectionHelper.showTroubleshooting()
                }
            }
        } else {
            print("\n✅ Step 2: Service already initialized")
            // Start scanning directly
            BluetoothConnectionHelper.startScanning()
        }
    }
    
    // MARK: - 🔍 Start Scanning
    static func startScanning() {
        print("\n🔍 Step 3: Starting device scan...")
        
        iHealthService.shared.scanDevices(timeout: 30.0) { success, message in
            if success {
                print("✅ Scan started successfully")
                print("⏳ Waiting 30 seconds to find device...")
                print("💡 Please ensure blood pressure monitor is powered on and in range")
            } else {
                print("❌ Scan failed: \(message ?? "Unknown error")")
                BluetoothConnectionHelper.showTroubleshooting()
            }
        }
    }
    
    // MARK: - 📊 Show Detailed Status
    static func showDetailedStatus() {
        print("\n" + String(repeating: "=", count: 60))
        print("📊 [BluetoothHelper] Detailed Bluetooth Status")
        print(String(repeating: "=", count: 60))
        
        let service = iHealthService.shared
        
        // 1. Service status
        print("\n1️⃣ iHealthService Status:")
        print("   • Initialized: \(service.isInitialized ? "✅" : "❌")")
        print("   • Connected: \(service.isConnected ? "✅" : "❌")")
        print("   • Scanning: \(service.isScanning ? "✅" : "❌")")
        
        // 2. Bluetooth permissions
        print("\n2️⃣ Bluetooth Permissions:")
        print("   • Check method: iPhone Settings > carelink > Bluetooth")
        print("   • Must be enabled: ✅")
        
        // 3. Device configuration
        print("\n3️⃣ iHealth KN-550BT Configuration:")
        print("   • Service UUID: 636F6D2E-6A69-7561-6E2E-646576000000")
        print("   • NOTIFY UUID: 7365642E-6A69-7561-6E2E-646576000000")
        print("   • WRITE UUID: 7265632E-6A69-7561-6E2E-646576000000")
        
        // 4. Device checklist
        print("\n4️⃣ Device Checklist:")
        print("   [ ] Blood pressure monitor powered on")
        print("   [ ] Blood pressure monitor within 5 meters range")
        print("   [ ] iPhone Bluetooth enabled")
        print("   [ ] App Bluetooth permission granted")
        print("   [ ] Blood pressure monitor in pairing mode")
        
        print("\n" + String(repeating: "=", count: 60) + "\n")
    }
    
    // MARK: - 🆘 Troubleshooting
    static func showTroubleshooting() {
        print("\n" + String(repeating: "⚠️", count: 30))
        print("🆘 Bluetooth Connection Troubleshooting")
        print(String(repeating: "⚠️", count: 30))
        
        print("\n📋 Please check the following in order:")
        
        print("\n1️⃣ Check Blood Pressure Monitor:")
        print("   • Press power button to turn on")
        print("   • Screen should light up")
        print("   • Device should show ready state")
        
        print("\n2️⃣ Check iPhone Bluetooth:")
        print("   • Open iPhone Settings")
        print("   • Tap Bluetooth")
        print("   • Ensure Bluetooth toggle is on (green)")
        
        print("\n3️⃣ Check App Permissions:")
        print("   • Open iPhone Settings")
        print("   • Scroll down to find carelink")
        print("   • Tap to enter")
        print("   • Ensure Bluetooth permission is enabled")
        
        print("\n4️⃣ Check Distance:")
        print("   • Place blood pressure monitor next to iPhone (< 1 meter)")
        print("   • Avoid metal objects blocking")
        
        print("\n5️⃣ Restart Devices:")
        print("   • Turn off blood pressure monitor")
        print("   • Wait 5 seconds")
        print("   • Power on again")
        print("   • Re-run app")
        
        print("\n6️⃣ Check Bluetooth Pairing:")
        print("   • Open iPhone Settings > Bluetooth")
        print("   • Check My Devices list")
        print("   • If you see KN-550BT, tap (i) > Forget This Device")
        print("   • Then scan again")
        
        print("\n" + String(repeating: "=", count: 60) + "\n")
    }
    
    // MARK: - 🧪 Test Bluetooth System
    static func testBluetoothSystem() {
        print("\n" + String(repeating: "=", count: 60))
        print("🧪 [BluetoothHelper] Test Bluetooth System")
        print(String(repeating: "=", count: 60))
        
        // Create temporary CentralManager for testing
        let testManager = CBCentralManager(delegate: nil, queue: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("\n📊 Bluetooth System Status:")
            
            switch testManager.state {
            case .poweredOn:
                print("   ✅ Bluetooth is on and available")
            case .poweredOff:
                print("   ❌ Bluetooth is off")
                print("   💡 Solution: iPhone Settings > Bluetooth > Turn On")
            case .unauthorized:
                print("   ❌ Bluetooth permission not authorized")
                print("   💡 Solution: iPhone Settings > carelink > Bluetooth > Enable")
            case .unsupported:
                print("   ❌ Device doesn't support Bluetooth")
            case .resetting:
                print("   ⏳ Bluetooth is resetting")
            case .unknown:
                print("   ❓ Bluetooth state unknown")
            @unknown default:
                print("   ❓ Unknown state")
            }
            
            print("\n" + String(repeating: "=", count: 60) + "\n")
        }
    }
    
    // MARK: - 🔄 Full Connection Workflow
    static func fullConnectionWorkflow() {
        print("\n" + String(repeating: "🚀", count: 30))
        print("Starting Full Connection Workflow")
        print(String(repeating: "🚀", count: 30))
        
        // 1. Test Bluetooth system
        testBluetoothSystem()
        
        // 2. Wait 1.5 seconds then show status
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showDetailedStatus()
        }
        
        // 3. Wait 2 seconds then force connect
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            forceConnectToDevice()
        }
    }
}
