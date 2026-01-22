//
//  HomeViewController.swift
//  HealthPad
//
//  Home - Health Pad Main Screen
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        // 📱 Adaptive font size: 32pt (small) -> 42pt (regular) -> 48pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 32, regular: 42, large: 48), weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.text = "Health Pad"
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        // 📱 Adaptive font size: 16pt (small) -> 20pt (regular) -> 22pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 16, regular: 20, large: 22))
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        return label
    }()
    
    // MARK: - 🔵 Prominent Bluetooth Connection Status Panel
    
    private let bluetoothStatusPanel: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.82, alpha: 1.0).cgColor
        return view
    }()
    
    private let bluetoothIconLabel: UILabel = {
        let label = UILabel()
        label.text = "📡"
        // 📱 Adaptive icon size: 48pt (small) -> 60pt (regular) -> 72pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 48, regular: 60, large: 72))
        label.textAlignment = .center
        return label
    }()
    
    private let connectionStatusLabel: UILabel = {
        let label = UILabel()
        // 📱 Adaptive font size: 22pt (small) -> 28pt (regular) -> 32pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 22, regular: 28, large: 32), weight: .bold)
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        label.text = "Not Connected"
        label.textAlignment = .center
        return label
    }()
    
    private let deviceNameLabel: UILabel = {
        let label = UILabel()
        // 📱 Adaptive font size: 15pt (small) -> 18pt (regular) -> 20pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 15, regular: 18, large: 20))
        label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        label.text = "Waiting to scan device..."
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let connectionTimeLabel: UILabel = {
        let label = UILabel()
        // 📱 Adaptive font size: 14pt (small) -> 16pt (regular) -> 18pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 14, regular: 16, large: 18))
        label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        label.text = ""
        label.textAlignment = .center
        return label
    }()
    
    private let statusIndicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        return view
    }()
    
    private let pulseAnimationView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)
        view.alpha = 0
        return view
    }()
    
    // 兼容旧的 UI 组件
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
    
    // Connection time tracking
    private var connectionStartTime: Date?
    private var connectionTimeTimer: Timer?
    
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
        
        // 🧪 Debug: Print currently saved data
        #if DEBUG
        print("\n🏠 [HomeVC] ========== App Launch ==========")
        DebugHelper.printSavedData()
        
        // 🎯 Uncomment the line below to automatically add test data
        // DebugHelper.addTestData()
        
        // Add a hidden test gesture (three-finger double tap on title to add test data)
        let testGesture = UITapGestureRecognizer(target: self, action: #selector(handleDebugTap))
        testGesture.numberOfTapsRequired = 2
        testGesture.numberOfTouchesRequired = 3
        titleLabel.addGestureRecognizer(testGesture)
        titleLabel.isUserInteractionEnabled = true
        #endif
        
        // 🔍 Add Bluetooth check gesture (double tap device status area)
        let connectionCheckGesture = UITapGestureRecognizer(target: self, action: #selector(checkBluetoothConnection))
        connectionCheckGesture.numberOfTapsRequired = 2
        deviceStatusView.addGestureRecognizer(connectionCheckGesture)
        deviceStatusView.isUserInteractionEnabled = true
        
        // 🔧 Force connect gesture (triple tap device status area)
        let forceConnectGesture = UITapGestureRecognizer(target: self, action: #selector(forceConnect))
        forceConnectGesture.numberOfTapsRequired = 3
        deviceStatusView.addGestureRecognizer(forceConnectGesture)
        
        // 🔌 Auto force connect on launch (if not connected)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            if !iHealthService.shared.isConnected {
                print("\n⚡ [HomeVC] Not connected detected, starting auto-connect workflow...")
                BluetoothConnectionHelper.fullConnectionWorkflow()
            } else {
                print("\n✅ [HomeVC] Device already connected")
            }
        }
    }
    
    #if DEBUG
    @objc private func handleDebugTap() {
        print("🧪 [HomeVC] Debug gesture triggered: Adding test data")
        DebugHelper.addTestData()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    #endif
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDateTime()
        updateDeviceStatus()
        
        // 🔄 Reload data statistics each time it appears
        #if DEBUG
        DebugHelper.printSavedData()
        #endif
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        
        // Add all subviews
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(dateLabel)
        headerView.addSubview(deviceStatusView)
        
        deviceStatusView.addSubview(statusDot)
        deviceStatusView.addSubview(statusLabel)
        
        // 🔵 Add prominent Bluetooth status panel
        view.addSubview(bluetoothStatusPanel)
        bluetoothStatusPanel.addSubview(pulseAnimationView)
        bluetoothStatusPanel.addSubview(statusIndicatorView)
        bluetoothStatusPanel.addSubview(bluetoothIconLabel)
        bluetoothStatusPanel.addSubview(connectionStatusLabel)
        bluetoothStatusPanel.addSubview(deviceNameLabel)
        bluetoothStatusPanel.addSubview(connectionTimeLabel)
        
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
        setupBluetoothPanelGestures()
    }
    
    // MARK: - 🔵 Bluetooth Panel Gestures
    private func setupBluetoothPanelGestures() {
        // Single tap: Show detailed status
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showBluetoothDetails))
        bluetoothStatusPanel.addGestureRecognizer(tapGesture)
        
        // Long press: Force connect
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(forceLongPressConnect))
        longPressGesture.minimumPressDuration = 1.0
        bluetoothStatusPanel.addGestureRecognizer(longPressGesture)
        
        bluetoothStatusPanel.isUserInteractionEnabled = true
    }
    
    @objc private func showBluetoothDetails() {
        print("\n📊 [HomeVC] Showing detailed Bluetooth status")
        BluetoothConnectionHelper.showDetailedStatus()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func forceLongPressConnect(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            print("\n🔧 [HomeVC] Long press triggered force connect")
            BluetoothConnectionHelper.forceConnectToDevice()
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
    
    private func setupConstraints() {
        // Disable autoresizing mask
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceStatusView.translatesAutoresizingMaskIntoConstraints = false
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        bluetoothStatusPanel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        pulseAnimationView.translatesAutoresizingMaskIntoConstraints = false
        bluetoothIconLabel.translatesAutoresizingMaskIntoConstraints = false
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        connectionTimeLabel.translatesAutoresizingMaskIntoConstraints = false
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
        
        // 📱 Use adaptive padding based on screen size
        let padding: CGFloat = UIScreen.adaptivePadding
        let verticalSpacing: CGFloat = UIScreen.adaptiveVerticalSpacing
        let headerHeight: CGFloat = UIScreen.adaptiveSpacing(small: 80, regular: 100, large: 120)
        let panelHeight: CGFloat = UIScreen.adaptiveSpacing(small: 160, regular: 200, large: 240)
        let buttonHeight: CGFloat = UIScreen.adaptiveSpacing(small: 200, regular: 250, large: 280)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalSpacing),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            
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
            
            // 🔵 Bluetooth status panel (below header)
            bluetoothStatusPanel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: verticalSpacing),
            bluetoothStatusPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            bluetoothStatusPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            bluetoothStatusPanel.heightAnchor.constraint(equalToConstant: panelHeight),
            
            // Status indicator (center dot)
            statusIndicatorView.centerXAnchor.constraint(equalTo: bluetoothStatusPanel.centerXAnchor),
            statusIndicatorView.topAnchor.constraint(equalTo: bluetoothStatusPanel.topAnchor, constant: 20),
            statusIndicatorView.widthAnchor.constraint(equalToConstant: 24),
            statusIndicatorView.heightAnchor.constraint(equalToConstant: 24),
            
            // Pulse animation
            pulseAnimationView.centerXAnchor.constraint(equalTo: statusIndicatorView.centerXAnchor),
            pulseAnimationView.centerYAnchor.constraint(equalTo: statusIndicatorView.centerYAnchor),
            pulseAnimationView.widthAnchor.constraint(equalToConstant: 30),
            pulseAnimationView.heightAnchor.constraint(equalToConstant: 30),
            
            // Bluetooth icon
            bluetoothIconLabel.centerXAnchor.constraint(equalTo: bluetoothStatusPanel.centerXAnchor),
            bluetoothIconLabel.topAnchor.constraint(equalTo: statusIndicatorView.bottomAnchor, constant: 10),
            
            // Connection status text
            connectionStatusLabel.centerXAnchor.constraint(equalTo: bluetoothStatusPanel.centerXAnchor),
            connectionStatusLabel.topAnchor.constraint(equalTo: bluetoothIconLabel.bottomAnchor, constant: 5),
            connectionStatusLabel.leadingAnchor.constraint(equalTo: bluetoothStatusPanel.leadingAnchor, constant: 20),
            connectionStatusLabel.trailingAnchor.constraint(equalTo: bluetoothStatusPanel.trailingAnchor, constant: -20),
            
            // 设备名称
            deviceNameLabel.centerXAnchor.constraint(equalTo: bluetoothStatusPanel.centerXAnchor),
            deviceNameLabel.topAnchor.constraint(equalTo: connectionStatusLabel.bottomAnchor, constant: 5),
            deviceNameLabel.leadingAnchor.constraint(equalTo: bluetoothStatusPanel.leadingAnchor, constant: 20),
            deviceNameLabel.trailingAnchor.constraint(equalTo: bluetoothStatusPanel.trailingAnchor, constant: -20),
            
            // Connection time
            connectionTimeLabel.centerXAnchor.constraint(equalTo: bluetoothStatusPanel.centerXAnchor),
            connectionTimeLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 5),
            connectionTimeLabel.leadingAnchor.constraint(equalTo: bluetoothStatusPanel.leadingAnchor, constant: 20),
            connectionTimeLabel.trailingAnchor.constraint(equalTo: bluetoothStatusPanel.trailingAnchor, constant: -20),
            
            // Buttons Container (adjusted position, moved below Bluetooth panel)
            buttonsContainer.topAnchor.constraint(equalTo: bluetoothStatusPanel.bottomAnchor, constant: verticalSpacing),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding + UIScreen.adaptiveSpacing(small: 20, regular: 40, large: 60)),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + UIScreen.adaptiveSpacing(small: 20, regular: 40, large: 60))),
            buttonsContainer.bottomAnchor.constraint(equalTo: statusBar.topAnchor, constant: -verticalSpacing),
            
            measureButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            measureButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            measureButton.trailingAnchor.constraint(equalTo: buttonsContainer.centerXAnchor, constant: -UIScreen.adaptiveSpacing(small: 10, regular: 20, large: 24)),
            measureButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            measureButton.heightAnchor.constraint(greaterThanOrEqualToConstant: buttonHeight),
            
            historyButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            historyButton.leadingAnchor.constraint(equalTo: buttonsContainer.centerXAnchor, constant: UIScreen.adaptiveSpacing(small: 10, regular: 20, large: 24)),
            historyButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            historyButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            historyButton.heightAnchor.constraint(greaterThanOrEqualToConstant: buttonHeight),
            
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
            statusBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -verticalSpacing),
            statusBar.heightAnchor.constraint(equalToConstant: UIScreen.adaptiveSpacing(small: 60, regular: 80, large: 90)),
            
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
        // 🔍 Get actual connection status from iHealthService
        let isConnected = iHealthService.shared.isConnected
        let isScanning = iHealthService.shared.isScanning
        
        print("🔌 [HomeVC] Update device status: \(isConnected ? "Connected" : "Not Connected"), Scanning: \(isScanning)")
        
        // Update old status bar
        if isConnected {
            statusDot.backgroundColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
            statusLabel.text = "Connected"
            statusLabel.textColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
        } else {
            statusDot.backgroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
            statusLabel.text = "Not Connected"
            statusLabel.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        }
        
        // 🔵 Update new Bluetooth status panel
        updateBluetoothPanel(isConnected: isConnected, isScanning: isScanning)
    }
    
    // MARK: - 🔵 Update Bluetooth Status Panel
    private func updateBluetoothPanel(isConnected: Bool, isScanning: Bool) {
        if isConnected {
            // ✅ Connected status
            connectionStatusLabel.text = "Connected"
            connectionStatusLabel.textColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
            bluetoothIconLabel.text = "✅"
            
            // Green indicator
            statusIndicatorView.backgroundColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
            pulseAnimationView.backgroundColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 0.3)
            
            // Device name
            if let deviceName = iHealthService.shared.connectedDeviceName {
                deviceNameLabel.text = "Device: \(deviceName)"
                deviceNameLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            } else {
                deviceNameLabel.text = "iHealth KN-550BT"
                deviceNameLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            }
            
            // Panel style
            bluetoothStatusPanel.backgroundColor = UIColor(red: 0.92, green: 0.99, blue: 0.95, alpha: 1.0)
            bluetoothStatusPanel.layer.borderColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 0.5).cgColor
            
            // Start pulse animation
            startPulseAnimation()
            
            // Start timer
            if connectionStartTime == nil {
                connectionStartTime = Date()
            }
            startConnectionTimeUpdate()
            
        } else if isScanning {
            // 🔍 Scanning status
            connectionStatusLabel.text = "Scanning for devices..."
            connectionStatusLabel.textColor = UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 1.0)
            bluetoothIconLabel.text = "🔍"
            
            // Blue indicator
            statusIndicatorView.backgroundColor = UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 1.0)
            pulseAnimationView.backgroundColor = UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 0.3)
            
            deviceNameLabel.text = "Looking for iHealth KN-550BT\nPlease ensure device is powered on and in range"
            deviceNameLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            
            connectionTimeLabel.text = ""
            
            // Panel style
            bluetoothStatusPanel.backgroundColor = UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 1.0)
            bluetoothStatusPanel.layer.borderColor = UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 0.5).cgColor
            
            // Start pulse animation
            startPulseAnimation()
            
        } else {
            // ❌ Not connected status
            connectionStatusLabel.text = "Not Connected"
            connectionStatusLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            bluetoothIconLabel.text = "📡"
            
            // Gray indicator
            statusIndicatorView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            pulseAnimationView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)
            
            deviceNameLabel.text = "Tap to view details\nLong press for 1 second to force connect"
            deviceNameLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            
            connectionTimeLabel.text = ""
            
            // Panel style
            bluetoothStatusPanel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
            bluetoothStatusPanel.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.82, alpha: 1.0).cgColor
            
            // Stop animation
            stopPulseAnimation()
            
            // Reset timer
            connectionStartTime = nil
            stopConnectionTimeUpdate()
        }
    }
    
    // MARK: - 🎬 Pulse Animation
    private func startPulseAnimation() {
        pulseAnimationView.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            self.pulseAnimationView.alpha = 0.8
            self.pulseAnimationView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        })
    }
    
    private func stopPulseAnimation() {
        pulseAnimationView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3) {
            self.pulseAnimationView.alpha = 0
            self.pulseAnimationView.transform = .identity
        }
    }
    
    // MARK: - ⏱️ Connection Time Update
    private func startConnectionTimeUpdate() {
        stopConnectionTimeUpdate()
        connectionTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateConnectionTime()
        }
        updateConnectionTime()
    }
    
    private func stopConnectionTimeUpdate() {
        connectionTimeTimer?.invalidate()
        connectionTimeTimer = nil
    }
    
    private func updateConnectionTime() {
        guard let startTime = connectionStartTime else {
            connectionTimeLabel.text = ""
            return
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        
        if minutes > 0 {
            connectionTimeLabel.text = "Connected: \(minutes) min \(seconds) sec"
        } else {
            connectionTimeLabel.text = "Connected: \(seconds) sec"
        }
        connectionTimeLabel.textColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
    }
    
    // MARK: - Actions
    @objc private func measureTapped() {
        tabBarController?.selectedIndex = 1
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func historyTapped() {
        tabBarController?.selectedIndex = 2
        // Add haptic feedback
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
        // Home doesn't need to show detailed results, just update device status
        updateDeviceStatus()
    }
    
    @objc private func deviceConnectionChanged() {
        print("📡 [HomeVC] Device connection status change notification received")
        updateDeviceStatus()
    }
    
    // MARK: - 🔧 Force Connect Bluetooth Device
    @objc private func forceConnect() {
        print("\n🔧 [HomeVC] User triggered force connect")
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        // Execute full connection workflow
        BluetoothConnectionHelper.fullConnectionWorkflow()
    }
    
    // MARK: - 🔍 Bluetooth Connection Checker
    @objc private func checkBluetoothConnection() {
        print("\n🔍 [HomeVC] ========== Bluetooth Connection Check ==========")
        
        let service = iHealthService.shared
        print("📊 [HomeVC] Service status:")
        print("   • Initialized: \(service.isInitialized)")
        print("   • Connected: \(service.isConnected)")
        print("   • Scanning: \(service.isScanning)")
        
        if service.isConnected {
            print("✅ [HomeVC] Bluetooth connected, ready to measure")
        } else if service.isInitialized {
            print("⚠️ [HomeVC] Service initialized but no device connected")
            print("💡 [HomeVC] Suggestion: Start Bluetooth scanning")
            
            // Auto start scanning
            service.scanDevices { success, message in
                print(success ? "✅ [HomeVC] Scan started successfully" : "❌ [HomeVC] Scan failed: \(message ?? "")")
            }
        } else {
            print("❌ [HomeVC] Service not initialized")
            print("💡 [HomeVC] Suggestion: Initialize iHealthService")
            
            // Auto initialize
            service.initialize { success in
                print(success ? "✅ [HomeVC] Initialization successful" : "❌ [HomeVC] Initialization failed")
                if success {
                    service.scanDevices { scanSuccess, message in
                        print(scanSuccess ? "✅ [HomeVC] Scan started successfully" : "❌ [HomeVC] Scan failed: \(message ?? "")")
                    }
                }
            }
        }
        
        print("🔍 [HomeVC] ========================================\n")
        
        // Update status display
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
        // Update view controller (if needed)
    }
}
#endif
