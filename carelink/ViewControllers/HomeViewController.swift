//
//  HomeViewController.swift
//  HealthPad
//
//  主页 - Health Pad 主屏幕
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 42, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.text = "Health Pad"
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        return label
    }()
    
    private let deviceStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let statusDot: UIView = {
        let dot = UIView()
        dot.layer.cornerRadius = 8
        dot.backgroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        return dot
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        label.text = "Not Connected"
        return label
    }()
    
    private let buttonsContainer = UIView()
    
    private let measureButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        button.layer.cornerRadius = 28
        button.clipsToBounds = false
        button.layer.shadowColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 0.3).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 30
        return button
    }()
    
    private let measureIconLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        label.font = .systemFont(ofSize: 100)
        label.textAlignment = .center
        return label
    }()
    
    private let measureTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Measure BP"
        label.font = .systemFont(ofSize: 36, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0, green: 0.74, blue: 0.83, alpha: 1.0)
        button.layer.cornerRadius = 28
        button.clipsToBounds = false
        button.layer.shadowColor = UIColor(red: 0, green: 0.74, blue: 0.83, alpha: 0.3).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 30
        return button
    }()
    
    private let historyIconLabel: UILabel = {
        let label = UILabel()
        label.text = "📈"
        label.font = .systemFont(ofSize: 100)
        label.textAlignment = .center
        return label
    }()
    
    private let historyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "History"
        label.font = .systemFont(ofSize: 36, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let statusBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let batteryLabel: UILabel = {
        let label = UILabel()
        label.text = "🔋 100%"
        label.font = .systemFont(ofSize: 20)
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        return label
    }()
    
    private let voiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔊", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.tintColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        updateDateTime()
        updateDeviceStatus()
        
        // 🧪 调试：打印当前保存的数据
        #if DEBUG
        print("\n🏠 [HomeVC] ========== App 启动 ==========")
        DebugHelper.printSavedData()
        
        // 🎯 取消注释下面这行可以自动添加测试数据
        // DebugHelper.addTestData()
        
        // 添加一个隐藏的测试手势（三指双击标题添加测试数据）
        let testGesture = UITapGestureRecognizer(target: self, action: #selector(handleDebugTap))
        testGesture.numberOfTapsRequired = 2
        testGesture.numberOfTouchesRequired = 3
        titleLabel.addGestureRecognizer(testGesture)
        titleLabel.isUserInteractionEnabled = true
        #endif
        
        // 🔍 添加蓝牙检查手势（双击设备状态区域）
        let connectionCheckGesture = UITapGestureRecognizer(target: self, action: #selector(checkBluetoothConnection))
        connectionCheckGesture.numberOfTapsRequired = 2
        deviceStatusView.addGestureRecognizer(connectionCheckGesture)
        deviceStatusView.isUserInteractionEnabled = true
        
        // 🔧 强制连接手势（三次点击设备状态区域）
        let forceConnectGesture = UITapGestureRecognizer(target: self, action: #selector(forceConnect))
        forceConnectGesture.numberOfTapsRequired = 3
        deviceStatusView.addGestureRecognizer(forceConnectGesture)
        
        // 🔌 启动时自动强制连接（如果未连接）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            if !iHealthService.shared.isConnected {
                print("\n⚡ [HomeVC] 检测到未连接，启动自动连接流程...")
                BluetoothConnectionHelper.fullConnectionWorkflow()
            } else {
                print("\n✅ [HomeVC] 设备已连接")
            }
        }
    }
    
    #if DEBUG
    @objc private func handleDebugTap() {
        print("🧪 [HomeVC] 调试手势触发：添加测试数据")
        DebugHelper.addTestData()
        
        // 震动反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    #endif
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDateTime()
        updateDeviceStatus()
        
        // 🔄 每次显示时重新加载数据统计
        #if DEBUG
        DebugHelper.printSavedData()
        #endif
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        
        // 添加所有子视图
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(dateLabel)
        headerView.addSubview(deviceStatusView)
        
        deviceStatusView.addSubview(statusDot)
        deviceStatusView.addSubview(statusLabel)
        
        view.addSubview(buttonsContainer)
        buttonsContainer.addSubview(measureButton)
        buttonsContainer.addSubview(historyButton)
        
        measureButton.addSubview(measureIconLabel)
        measureButton.addSubview(measureTitleLabel)
        
        historyButton.addSubview(historyIconLabel)
        historyButton.addSubview(historyTitleLabel)
        
        view.addSubview(statusBar)
        statusBar.addSubview(batteryLabel)
        statusBar.addSubview(voiceButton)
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        // 禁用自动布局
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceStatusView.translatesAutoresizingMaskIntoConstraints = false
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        measureButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        measureIconLabel.translatesAutoresizingMaskIntoConstraints = false
        measureTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        historyIconLabel.translatesAutoresizingMaskIntoConstraints = false
        historyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusBar.translatesAutoresizingMaskIntoConstraints = false
        batteryLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            
            deviceStatusView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            deviceStatusView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            deviceStatusView.heightAnchor.constraint(equalToConstant: 48),
            deviceStatusView.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
            
            statusDot.leadingAnchor.constraint(equalTo: deviceStatusView.leadingAnchor, constant: 24),
            statusDot.centerYAnchor.constraint(equalTo: deviceStatusView.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 16),
            statusDot.heightAnchor.constraint(equalToConstant: 16),
            
            statusLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: deviceStatusView.trailingAnchor, constant: -24),
            statusLabel.centerYAnchor.constraint(equalTo: deviceStatusView.centerYAnchor),
            
            // Buttons Container
            buttonsContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding + 40),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 40)),
            buttonsContainer.bottomAnchor.constraint(equalTo: statusBar.topAnchor, constant: -40),
            
            measureButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            measureButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            measureButton.trailingAnchor.constraint(equalTo: buttonsContainer.centerXAnchor, constant: -20),
            measureButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            measureButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 250),
            
            historyButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            historyButton.leadingAnchor.constraint(equalTo: buttonsContainer.centerXAnchor, constant: 20),
            historyButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            historyButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            historyButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 250),
            
            // Measure Button Content
            measureIconLabel.centerXAnchor.constraint(equalTo: measureButton.centerXAnchor),
            measureIconLabel.centerYAnchor.constraint(equalTo: measureButton.centerYAnchor, constant: -30),
            
            measureTitleLabel.centerXAnchor.constraint(equalTo: measureButton.centerXAnchor),
            measureTitleLabel.topAnchor.constraint(equalTo: measureIconLabel.bottomAnchor, constant: 24),
            
            // History Button Content
            historyIconLabel.centerXAnchor.constraint(equalTo: historyButton.centerXAnchor),
            historyIconLabel.centerYAnchor.constraint(equalTo: historyButton.centerYAnchor, constant: -30),
            
            historyTitleLabel.centerXAnchor.constraint(equalTo: historyButton.centerXAnchor),
            historyTitleLabel.topAnchor.constraint(equalTo: historyIconLabel.bottomAnchor, constant: 24),
            
            // Status Bar
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            statusBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            statusBar.heightAnchor.constraint(equalToConstant: 80),
            
            batteryLabel.leadingAnchor.constraint(equalTo: statusBar.leadingAnchor, constant: 32),
            batteryLabel.centerYAnchor.constraint(equalTo: statusBar.centerYAnchor),
            
            voiceButton.trailingAnchor.constraint(equalTo: statusBar.trailingAnchor, constant: -32),
            voiceButton.centerYAnchor.constraint(equalTo: statusBar.centerYAnchor),
            voiceButton.widthAnchor.constraint(equalToConstant: 44),
            voiceButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupActions() {
        measureButton.addTarget(self, action: #selector(measureTapped), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(voiceToggled), for: .touchUpInside)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(measurementCompleted(_:)),
            name: .measurementCompleted,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceConnectionChanged),
            name: .deviceConnected,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceConnectionChanged),
            name: .deviceDisconnected,
            object: nil
        )
    }
    
    // MARK: - Update UI
    private func updateDateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy - EEEE"
        formatter.locale = Locale(identifier: "en_US")
        dateLabel.text = formatter.string(from: Date())
    }
    
    private func updateDeviceStatus() {
        // 🔍 从 iHealthService 获取实际连接状态
        let isConnected = iHealthService.shared.isConnected
        
        print("🔌 [HomeVC] 更新设备状态: \(isConnected ? "已连接" : "未连接")")
        
        if isConnected {
            statusDot.backgroundColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
            statusLabel.text = "Connected"
            statusLabel.textColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
            print("✅ [HomeVC] 设备已连接 - 可以进行测量")
        } else {
            statusDot.backgroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
            statusLabel.text = "Not Connected"
            print("⚠️ [HomeVC] 设备未连接 - 测量将使用模拟数据")
            statusLabel.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        }
    }
    
    // MARK: - Actions
    @objc private func measureTapped() {
        tabBarController?.selectedIndex = 1
        // 添加触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func historyTapped() {
        tabBarController?.selectedIndex = 2
        // 添加触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func voiceToggled() {
        // Toggle voice service
        VoiceService.shared.isEnabled.toggle()
        
        if VoiceService.shared.isEnabled {
            voiceButton.setTitle("🔊", for: .normal)
            VoiceService.shared.speak("Voice guidance enabled")
        } else {
            voiceButton.setTitle("🔇", for: .normal)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func measurementCompleted(_ notification: Notification) {
        // 主页不需要显示详细结果，只更新设备状态
        updateDeviceStatus()
    }
    
    @objc private func deviceConnectionChanged() {
        print("📡 [HomeVC] 收到设备连接状态变化通知")
        updateDeviceStatus()
    }
    
    // MARK: - 🔧 强制连接蓝牙设备
    @objc private func forceConnect() {
        print("\n🔧 [HomeVC] 用户触发强制连接")
        
        // 震动反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        // 执行完整连接流程
        BluetoothConnectionHelper.fullConnectionWorkflow()
    }
    
    // MARK: - 🔍 蓝牙连接检查工具
    @objc private func checkBluetoothConnection() {
        print("\n🔍 [HomeVC] ========== 蓝牙连接检查 ==========")
        
        let service = iHealthService.shared
        print("📊 [HomeVC] 服务状态:")
        print("   • 已初始化: \(service.isInitialized)")
        print("   • 已连接: \(service.isConnected)")
        print("   • 正在扫描: \(service.isScanning)")
        
        if service.isConnected {
            print("✅ [HomeVC] 蓝牙已连接，可以进行测量")
        } else if service.isInitialized {
            print("⚠️ [HomeVC] 服务已初始化，但未连接设备")
            print("💡 [HomeVC] 建议：启动蓝牙扫描")
            
            // 自动启动扫描
            service.scanDevices { success, message in
                print(success ? "✅ [HomeVC] 扫描启动成功" : "❌ [HomeVC] 扫描失败: \(message ?? "")")
            }
        } else {
            print("❌ [HomeVC] 服务未初始化")
            print("💡 [HomeVC] 建议：初始化 iHealthService")
            
            // 自动初始化
            service.initialize { success in
                print(success ? "✅ [HomeVC] 初始化成功" : "❌ [HomeVC] 初始化失败")
                if success {
                    service.scanDevices { scanSuccess, message in
                        print(scanSuccess ? "✅ [HomeVC] 扫描启动成功" : "❌ [HomeVC] 扫描失败: \(message ?? "")")
                    }
                }
            }
        }
        
        print("🔍 [HomeVC] ========================================\n")
        
        // 更新状态显示
        updateDeviceStatus()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

struct HomeViewController_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct HomeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HomeViewController {
        return HomeViewController()
    }
    
    func updateUIViewController(_ uiViewController: HomeViewController, context: Context) {
        // 更新视图控制器（如果需要）
    }
}
#endif
