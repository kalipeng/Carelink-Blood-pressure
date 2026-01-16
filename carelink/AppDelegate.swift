//
//  AppDelegate.swift
//  HealthPad
//
//  Created for Three-Tier Platform Design Project
//  GATE 4 - Tier 1: Senior-Friendly Health Monitoring Application
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 配置全局外观
        configureAppearance()
        
        // 禁用自动锁屏（专用设备模式）
        UIApplication.shared.isIdleTimerDisabled = true
        
        // 初始化 iHealth SDK
        initializeSDK()
        
        print("✅ HealthPad 应用启动成功")
        
        return true
    }
    
    // MARK: - 配置全局外观
    private func configureAppearance() {
        // T-Mobile Magenta 主题色
        let magenta = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        
        // 导航栏外观
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = magenta
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
        
        // 标签栏外观
        UITabBar.appearance().tintColor = magenta
        UITabBar.appearance().unselectedItemTintColor = .gray
        
        // 禁用暗黑模式（老年人友好）
        // 注意：实际的 window 配置会在 SceneDelegate 中处理
    }
    
    // MARK: - 初始化 SDK
    private func initializeSDK() {
        // 在实际部署时，这里会初始化 iHealth SDK
        // 需要有效的许可证文件
        print("📱 准备初始化 iHealth SDK...")
        
        // SDK 初始化代码将在 iHealthService 中实现
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
