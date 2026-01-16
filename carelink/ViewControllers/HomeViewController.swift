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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDateTime()
        updateDeviceStatus()
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
        // 这里需要检查实际的设备连接状态
        // 暂时使用模拟状态
        let isConnected = false // 从 iHealthService 获取实际状态
        
        if isConnected {
            statusDot.backgroundColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
            statusLabel.text = "Connected"
            statusLabel.textColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
        } else {
            statusDot.backgroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
            statusLabel.text = "Not Connected"
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
