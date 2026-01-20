//
//  BloodPressureReading.swift
//  HealthPad
//
//  Blood Pressure Measurement Data Model
//

import Foundation
import UIKit

struct BloodPressureReading: Codable {
    let id: UUID
    let systolic: Int       // Systolic (high pressure)
    let diastolic: Int      // Diastolic (low pressure)
    let pulse: Int          // Heart rate
    let timestamp: Date     // Measurement time
    let source: String      // Data source: "bluetooth", "simulated", "manual"
    
    init(systolic: Int, diastolic: Int, pulse: Int, timestamp: Date = Date(), source: String = "simulated") {
        self.id = UUID()
        self.systolic = systolic
        self.diastolic = diastolic
        self.pulse = pulse
        self.timestamp = timestamp
        self.source = source
        
        // 🔍 Debug: Print created data
        print("📊 [BloodPressureReading] Creating new data:")
        print("   • ID: \(id.uuidString.prefix(8))...")
        print("   • Values: \(systolic)/\(diastolic) mmHg, Pulse \(pulse)")
        print("   • Time: \(timestamp)")
        print("   • Source: \(source)")
    }
    
    // Blood pressure category
    var category: String {
        if systolic < 120 && diastolic < 80 {
            return "Normal"
        } else if systolic < 130 && diastolic < 80 {
            return "Slightly Elevated"
        } else if systolic < 140 || diastolic < 90 {
            return "Hypertension Stage 1"
        } else if systolic < 180 || diastolic < 120 {
            return "Hypertension Stage 2"
        } else {
            return "Hypertensive Crisis"
        }
    }
    
    // Blood pressure status color
    var statusColor: (red: Double, green: Double, blue: Double) {
        switch category {
        case "Normal":
            return (0, 0.78, 0.33)  // Green
        case "Slightly Elevated":
            return (1.0, 0.8, 0)     // Yellow
        case "Hypertension Stage 1":
            return (1.0, 0.58, 0)    // Orange
        case "Hypertension Stage 2", "Hypertensive Crisis":
            return (0.89, 0, 0.45)   // Red
        default:
            return (0.46, 0.46, 0.46) // Gray
        }
    }
    
    // UIColor version of category color
    var categoryColor: UIColor {
        let color = statusColor
        return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: 1.0)
    }
    
    // Formatted blood pressure value
    var formattedValue: String {
        return "\(systolic)/\(diastolic)"
    }
    
    // Health recommendations
    var recommendation: String {
        switch category {
        case "Normal":
            return "Your blood pressure is normal. Maintain a healthy lifestyle."
        case "Slightly Elevated":
            return "Blood pressure is slightly elevated. Reduce salt intake and increase exercise."
        case "Hypertension Stage 1":
            return "Consult a doctor and adjust diet and lifestyle habits."
        case "Hypertension Stage 2":
            return "Blood pressure is high. Please see a doctor soon."
        case "Hypertensive Crisis":
            return "Blood pressure is dangerously high! Seek immediate medical attention!"
        default:
            return "Please consult a doctor for professional advice."
        }
    }
    
    // MARK: - Static Methods: Data Persistence
    
    private static let storageKey = "bloodPressureReadings"
    
    // Save single reading
    static func add(_ reading: BloodPressureReading) {
        print("💾 [BloodPressureReading] Starting to save data...")
        print("   • Systolic: \(reading.systolic) mmHg")
        print("   • Diastolic: \(reading.diastolic) mmHg")
        print("   • Pulse: \(reading.pulse) bpm")
        print("   • Time: \(reading.timestamp)")
        
        var readings = load()
        print("💾 [BloodPressureReading] Currently \(readings.count) records")
        
        readings.insert(reading, at: 0) // Latest first
        save(readings)
        
        print("✅ [BloodPressureReading] Save complete! Total \(readings.count) records")
    }
    
    // Load all readings
    static func load() -> [BloodPressureReading] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let readings = try? JSONDecoder().decode([BloodPressureReading].self, from: data) else {
            return []
        }
        return readings
    }
    
    // Save all readings
    private static func save(_ readings: [BloodPressureReading]) {
        if let data = try? JSONEncoder().encode(readings) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // Delete all readings
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
