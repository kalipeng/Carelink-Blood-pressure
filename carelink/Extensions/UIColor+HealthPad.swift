//
//  UIColor+HealthPad.swift
//  HealthPad
//
//  颜色方案定义
//

import UIKit

extension UIColor {
    // MARK: - Brand Colors (从 HTML 设计提取)
    
    /// 主要粉色 #E20074
    static let healthPadPink = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
    
    /// 粉色渐变终点 #FF4099
    static let healthPadPinkLight = UIColor(red: 1.0, green: 0.25, blue: 0.60, alpha: 1.0)
    
    /// 青色/历史按钮 #00BCD4
    static let healthPadCyan = UIColor(red: 0, green: 0.74, blue: 0.83, alpha: 1.0)
    
    /// 成功绿色 #00C853
    static let healthPadGreen = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
    
    // MARK: - Neutral Colors
    
    /// 深色文字 #212121
    static let healthPadTextDark = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
    
    /// 灰色文字 #757575
    static let healthPadTextGray = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
    
    /// 浅灰色文字 #9E9E9E
    static let healthPadTextLightGray = UIColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 1.0)
    
    /// 背景色 #FAFAFA
    static let healthPadBackground = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    
    /// 浅灰背景 #F5F5F5
    static let healthPadBackgroundLight = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    
    /// 边框灰色 #E0E0E0
    static let healthPadBorder = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
    
    // MARK: - Status Colors
    
    /// 正常 - 绿色
    static let statusNormal = UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0)
    static let statusNormalBackground = UIColor(red: 0.91, green: 0.96, blue: 0.91, alpha: 1.0)
    static let statusNormalBorder = UIColor(red: 0.51, green: 0.78, blue: 0.52, alpha: 1.0)
    
    /// 警告 - 橙色
    static let statusWarning = UIColor(red: 1.0, green: 0.60, blue: 0.00, alpha: 1.0)
    static let statusWarningBackground = UIColor(red: 1.0, green: 0.95, blue: 0.88, alpha: 1.0)
    static let statusWarningBorder = UIColor(red: 1.0, green: 0.72, blue: 0.30, alpha: 1.0)
    
    /// 危险 - 红色
    static let statusDanger = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0)
    static let statusDangerBackground = UIColor(red: 1.0, green: 0.92, blue: 0.93, alpha: 1.0)
    static let statusDangerBorder = UIColor(red: 0.90, green: 0.45, blue: 0.45, alpha: 1.0)
    
    // MARK: - Gradient Helper
    
    /// 创建粉色渐变层
    static func createPinkGradientLayer(in bounds: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [
            UIColor.healthPadPink.cgColor,
            UIColor.healthPadPinkLight.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
    
    /// 创建青色渐变层
    static func createCyanGradientLayer(in bounds: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [
            UIColor.healthPadCyan.cgColor,
            UIColor(red: 0, green: 0.90, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
}
