//
//  iHealthHistoryService.swift
//  HealthPad
//
//  使用 iHealth 官方 SDK 同步历史数据
//  支持 KN-550BT 和 NMSBBT 型号
//

import Foundation

// MARK: - 历史数据同步服务
class iHealthHistoryService {
    
    static let shared = iHealthHistoryService()
    
    private init() {}
    
    // MARK: - 同步历史数据（KN-550BT）
    /// 从设备拉取所有离线历史数据并上传到云端
    func syncHistoryDataKN550BT(completion: @escaping (Bool, Int, String?) -> Void) {
        print("📥 [History] 开始同步 KN-550BT 历史数据...")
        
        // ⚠️ 前提：需要先集成 iHealth 官方 SDK
        // 1. 添加 SDK 到项目（通过 CocoaPods 或手动导入）
        // 2. 导入头文件：
        //    #import <iHealthSDK/iHealthSDK.h>
        
        // 伪代码流程（实际需要替换为真实SDK调用）：
        /*
        guard let controller = KN550BTController.shareKN550BTController() else {
            completion(false, 0, "设备未连接")
            return
        }
        
        // 步骤1: 获取历史数据总数
        controller.commandTransferMemoryTotalCount({ totalCount in
            print("📊 [History] 发现 \(totalCount) 条历史数据")
            
            guard totalCount > 0 else {
                completion(true, 0, "无历史数据")
                return
            }
            
            // 步骤2: 拉取所有历史数据
            controller.commandTransferMemoryDataWithTotalCount(
                totalCount: { totalCount },
                progress: { progress in
                    print("📥 [History] 同步进度: \(Int(progress * 100))%")
                },
                dataArray: { dataArray in
                    // 步骤3: 转换每条数据为 BloodPressureReading
                    var readings: [BloodPressureReading] = []
                    
                    for data in dataArray {
                        guard let sys = data["sys"] as? Int,
                              let dia = data["dia"] as? Int,
                              let heartRate = data["heartRate"] as? Int,
                              let timeStr = data["time"] as? String else {
                            continue
                        }
                        
                        // 解析时间字符串（格式: "2020-01-01 08:56:38"）
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let timestamp = formatter.date(from: timeStr) ?? Date()
                        
                        // 检查时间是否需要校正（固件 2.0.1+）
                        if let isRightTime = data["isRightTime"] as? Int, isRightTime == 1 {
                            print("⚠️ [History] 数据时间需要校正: \(timeStr)")
                            // 可以在这里校正时间
                        }
                        
                        let reading = BloodPressureReading(
                            systolic: sys,
                            diastolic: dia,
                            pulse: heartRate,
                            timestamp: timestamp,
                            source: "bluetooth"
                        )
                        
                        readings.append(reading)
                    }
                    
                    print("✅ [History] 转换了 \(readings.count) 条数据")
                    
                    // 步骤4: 批量上传到云端
                    CloudSyncService.shared.uploadReadings(readings) { success, error in
                        if success {
                            print("✅ [History] 所有历史数据已上传到云端")
                            
                            // 步骤5: 删除设备上的历史数据（固件 2.0.1+）
                            // 注意：固件 < 2.0.1 会自动删除，不需要调用
                            if let firmwareVersion = self.getFirmwareVersion(),
                               firmwareVersion >= "2.0.1" {
                                controller.commandDeleteMemoryDataResult({ result in
                                    if result {
                                        print("✅ [History] 设备历史数据已清除")
                                    }
                                }, errorBlock: { error in
                                    print("⚠️ [History] 清除历史数据失败: \(error)")
                                })
                            }
                            
                            completion(true, readings.count, nil)
                        } else {
                            completion(false, readings.count, error)
                        }
                    }
                },
                errorBlock: { error in
                    print("❌ [History] 同步失败: \(error)")
                    completion(false, 0, "同步失败: \(error)")
                }
            )
        }, errorBlock: { error in
            print("❌ [History] 获取总数失败: \(error)")
            completion(false, 0, "获取总数失败: \(error)")
        })
        */
        
        // 临时实现：提示需要集成SDK
        print("⚠️ [History] 需要先集成 iHealth 官方 SDK")
        print("📚 参考文档: iHealth iOS SDK Integration Guide")
        completion(false, 0, "需要集成 iHealth SDK")
    }
    
    // MARK: - 同步历史数据（NMSBBT）
    func syncHistoryDataNMSBBT(completion: @escaping (Bool, Int, String?) -> Void) {
        print("📥 [History] 开始同步 NMSBBT 历史数据...")
        
        // 类似 KN-550BT 的流程，但使用 NMSBBTController
        /*
        guard let controller = NMSBBTController.sharedNMSBBTController() else {
            completion(false, 0, "设备未连接")
            return
        }
        
        controller.commandTransferMemoryTotalCount({ totalCount in
            controller.commandTransferMemoryDataWithTotalCount(
                totalCount: { totalCount },
                progress: { progress in
                    print("📥 [History] 同步进度: \(Int(progress * 100))%")
                },
                dataArray: { dataArray in
                    // 转换并上传（同KN-550BT）
                    var readings: [BloodPressureReading] = []
                    
                    for data in dataArray {
                        // NMSBBT 的 key 是: Hrs, Sys, DIs, HeartRate, Irregular
                        guard let sys = data["Sys"] as? Int,
                              let dia = data["DIs"] as? Int,
                              let heartRate = data["HeartRate"] as? Int,
                              let timeStr = data["Hrs"] as? String else {
                            continue
                        }
                        
                        // ... 转换逻辑 ...
                    }
                    
                    CloudSyncService.shared.uploadReadings(readings) { success, error in
                        completion(success, readings.count, error)
                    }
                },
                errorBlock: { error in
                    completion(false, 0, "同步失败: \(error)")
                }
            )
        }, errorBlock: { error in
            completion(false, 0, "获取总数失败: \(error)")
        })
        */
        
        completion(false, 0, "需要集成 iHealth SDK")
    }
    
    // MARK: - 获取固件版本（辅助方法）
    private func getFirmwareVersion() -> String? {
        // 从连接通知的 userInfo 中获取 FirmwareVersion
        // 实际实现需要从 SDK 的连接回调中获取
        return nil
    }
}
