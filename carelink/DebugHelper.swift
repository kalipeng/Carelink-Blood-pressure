//
//  DebugHelper.swift
//  carelink
//
//  调试辅助工具：用于测试数据保存和验证
//

import Foundation

class DebugHelper {
    
    // MARK: - 添加测试数据
    static func addTestData() {
        print("🧪 [DebugHelper] 开始添加测试数据...")
        
        let testReadings = [
            BloodPressureReading(systolic: 120, diastolic: 80, pulse: 72, source: "simulated"),
            BloodPressureReading(systolic: 135, diastolic: 85, pulse: 78, source: "simulated"),
            BloodPressureReading(systolic: 118, diastolic: 75, pulse: 68, source: "simulated"),
        ]
        
        for (index, reading) in testReadings.enumerated() {
            BloodPressureReading.add(reading)
            print("✅ [DebugHelper] 添加测试数据 \(index + 1): \(reading.formattedValue)")
        }
        
        printSavedData()
    }
    
    // MARK: - 打印所有保存的数据
    static func printSavedData() {
        print("\n📊 [DebugHelper] ========== 已保存的数据 ==========")
        let readings = BloodPressureReading.load()
        print("📝 [DebugHelper] 总共 \(readings.count) 条记录\n")
        
        if readings.isEmpty {
            print("❌ [DebugHelper] 没有保存的数据")
        } else {
            for (index, reading) in readings.enumerated() {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd HH:mm"
                let timeStr = dateFormatter.string(from: reading.timestamp)
                
                print("   \(index + 1). \(reading.formattedValue) mmHg | 心率: \(reading.pulse) | \(reading.category) | \(timeStr)")
            }
        }
        print("📊 [DebugHelper] =====================================\n")
    }
    
    // MARK: - 验证数据保存功能
    static func testSaveAndLoad() {
        print("\n🧪 [DebugHelper] ========== 测试保存功能 ==========")
        
        // 1. 清空现有数据
        print("🗑️ [DebugHelper] 清空现有数据...")
        BloodPressureReading.clearAll()
        
        // 2. 验证清空成功
        var readings = BloodPressureReading.load()
        print("✅ [DebugHelper] 清空后: \(readings.count) 条记录 (应为 0)")
        
        // 3. 添加新数据
        print("\n💾 [DebugHelper] 添加测试数据...")
        let testReading = BloodPressureReading(
            systolic: 125,
            diastolic: 82,
            pulse: 75,
            source: "simulated"
        )
        BloodPressureReading.add(testReading)
        
        // 4. 验证保存成功
        readings = BloodPressureReading.load()
        print("✅ [DebugHelper] 保存后: \(readings.count) 条记录 (应为 1)")
        
        if let first = readings.first {
            print("📝 [DebugHelper] 数据内容:")
            print("   • 收缩压: \(first.systolic) mmHg (预期: 125)")
            print("   • 舒张压: \(first.diastolic) mmHg (预期: 82)")
            print("   • 心率: \(first.pulse) bpm (预期: 75)")
            
            // 5. 验证数据正确性
            if first.systolic == 125 && first.diastolic == 82 && first.pulse == 75 {
                print("\n🎉 [DebugHelper] ✅ 保存功能测试通过！")
            } else {
                print("\n❌ [DebugHelper] 数据不匹配，测试失败！")
            }
        } else {
            print("\n❌ [DebugHelper] 无法读取数据，测试失败！")
        }
        
        print("🧪 [DebugHelper] =======================================\n")
    }
    
    // MARK: - 清空所有数据
    static func clearAllData() {
        print("🗑️ [DebugHelper] 清空所有数据...")
        BloodPressureReading.clearAll()
        let readings = BloodPressureReading.load()
        print("✅ [DebugHelper] 清空完成，当前 \(readings.count) 条记录")
    }
}
