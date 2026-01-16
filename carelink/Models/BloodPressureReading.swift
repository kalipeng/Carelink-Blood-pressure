//
//  BloodPressureReading.swift
//  HealthPad
//
//  血压测量数据模型
//

import Foundation
import UIKit

struct BloodPressureReading: Codable {
    let id: UUID
    let systolic: Int       // 收缩压 (高压)
    let diastolic: Int      // 舒张压 (低压)
    let pulse: Int          // 心率
    let timestamp: Date     // 测量时间
    
    init(systolic: Int, diastolic: Int, pulse: Int, timestamp: Date = Date()) {
        self.id = UUID()
        self.systolic = systolic
        self.diastolic = diastolic
        self.pulse = pulse
        self.timestamp = timestamp
    }
    
    // 血压分类
    var category: String {
        if systolic < 120 && diastolic < 80 {
            return "正常"
        } else if systolic < 130 && diastolic < 80 {
            return "正常偏高"
        } else if systolic < 140 || diastolic < 90 {
            return "高血压1期"
        } else if systolic < 180 || diastolic < 120 {
            return "高血压2期"
        } else {
            return "高血压危象"
        }
    }
    
    // 血压状态颜色
    var statusColor: (red: Double, green: Double, blue: Double) {
        switch category {
        case "正常":
            return (0, 0.78, 0.33)  // 绿色
        case "正常偏高":
            return (1.0, 0.8, 0)     // 黄色
        case "高血压1期":
            return (1.0, 0.58, 0)    // 橙色
        case "高血压2期", "高血压危象":
            return (0.89, 0, 0.45)   // 红色
        default:
            return (0.46, 0.46, 0.46) // 灰色
        }
    }
    
    // UIColor 版本的分类颜色
    var categoryColor: UIColor {
        let color = statusColor
        return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: 1.0)
    }
    
    // 格式化的血压值
    var formattedValue: String {
        return "\(systolic)/\(diastolic)"
    }
    
    // 健康建议
    var recommendation: String {
        switch category {
        case "正常":
            return "您的血压正常。保持健康的生活方式。"
        case "正常偏高":
            return "血压略高。建议减少盐分摄入，增加运动。"
        case "高血压1期":
            return "建议咨询医生，调整饮食和生活习惯。"
        case "高血压2期":
            return "血压偏高，请尽快就医咨询。"
        case "高血压危象":
            return "血压危险！请立即就医！"
        default:
            return "请咨询医生获取专业建议。"
        }
    }
    
    // MARK: - 静态方法：数据持久化
    
    private static let storageKey = "bloodPressureReadings"
    
    // 保存单个读数
    static func add(_ reading: BloodPressureReading) {
        var readings = load()
        readings.insert(reading, at: 0) // 最新的在前
        save(readings)
    }
    
    // 加载所有读数
    static func load() -> [BloodPressureReading] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let readings = try? JSONDecoder().decode([BloodPressureReading].self, from: data) else {
            return []
        }
        return readings
    }
    
    // 保存所有读数
    private static func save(_ readings: [BloodPressureReading]) {
        if let data = try? JSONEncoder().encode(readings) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // 删除所有读数
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
