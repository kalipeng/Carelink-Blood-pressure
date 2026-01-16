//
//  Notification+Extensions.swift
//  HealthPad
//
//  通知名称定义
//

import Foundation

extension Notification.Name {
    // 测量完成通知
    static let measurementCompleted = Notification.Name("measurementCompleted")
    
    // 设备连接状态通知
    static let deviceConnected = Notification.Name("deviceConnected")
    static let deviceDisconnected = Notification.Name("deviceDisconnected")
    
    // 数据同步通知
    static let dataSynced = Notification.Name("dataSynced")
    static let syncFailed = Notification.Name("syncFailed")
}
