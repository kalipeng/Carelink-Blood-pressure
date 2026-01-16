//
//  SceneDelegate.swift
//  HealthPad
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // 设置根视图控制器
        let tabBarController = createMainTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // 强制亮色模式
        window?.overrideUserInterfaceStyle = .light
    }
    
    // MARK: - 创建主界面
    private func createMainTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // 主页
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "主页",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        let homeNav = UINavigationController(rootViewController: homeVC)
        
        // 测量
        let measureVC = MeasureViewController()
        measureVC.tabBarItem = UITabBarItem(
            title: "测量",
            image: UIImage(systemName: "heart.text.square.fill"),
            tag: 1
        )
        let measureNav = UINavigationController(rootViewController: measureVC)
        
        // 历史
        let historyVC = HistoryViewController()
        historyVC.tabBarItem = UITabBarItem(
            title: "历史",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            tag: 2
        )
        let historyNav = UINavigationController(rootViewController: historyVC)
        
        // 设置
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(
            title: "设置",
            image: UIImage(systemName: "gearshape.fill"),
            tag: 3
        )
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        
        tabBarController.viewControllers = [homeNav, measureNav, historyNav, settingsNav]
        
        // 默认选中主页
        tabBarController.selectedIndex = 0
        
        // 设置标签栏字体大小（老年人友好）
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .selected)
        
        return tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
