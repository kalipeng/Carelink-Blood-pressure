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
        
        // Set root view controller
        let tabBarController = createMainTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // Force light mode
        window?.overrideUserInterfaceStyle = .light
    }
    
    // MARK: - Create main interface
    private func createMainTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // Home
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        let homeNav = UINavigationController(rootViewController: homeVC)
        
        // Measure
        let measureVC = MeasureViewController()
        measureVC.tabBarItem = UITabBarItem(
            title: "Measure",
            image: UIImage(systemName: "heart.text.square.fill"),
            tag: 1
        )
        let measureNav = UINavigationController(rootViewController: measureVC)
        
        // History
        let historyVC = HistoryViewController()
        historyVC.tabBarItem = UITabBarItem(
            title: "History",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            tag: 2
        )
        let historyNav = UINavigationController(rootViewController: historyVC)
        
        // Settings
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape.fill"),
            tag: 3
        )
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        
        tabBarController.viewControllers = [homeNav, measureNav, historyNav, settingsNav]
        
        // Default to Home
        tabBarController.selectedIndex = 0
        
        // Tab bar font size
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
