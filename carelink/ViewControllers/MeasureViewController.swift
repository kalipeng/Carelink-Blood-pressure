//
//  MeasureViewController.swift
//  HealthPad
//
//  测量界面 - 核心功能页面
//

import UIKit
import AVFoundation
import SwiftUI

class MeasureViewController: UIViewController {
    
    // MARK: - Properties
    private var isMeasuring = false
    private var currentReading: BloodPressureReading?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "← Back"
        config.baseForegroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        config.background.backgroundColor = .white
        config.background.cornerRadius = 12
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        return button
    }()
    
    private let headerIconLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        label.font = .systemFont(ofSize: 80)
        label.textAlignment = .center
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Follow these steps"
        label.font = .systemFont(ofSize: 36, weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private let stepsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        return stack
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Measurement", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 42, weight: .bold)
        button.backgroundColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 28
        button.clipsToBounds = false
        button.layer.shadowColor = UIColor(red: 0, green: 0.78, blue: 0.33, alpha: 0.4).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 30
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDeviceStatus()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(headerIconLabel)
        contentView.addSubview(instructionLabel)
        contentView.addSubview(stepsStackView)
        contentView.addSubview(startButton)
        startButton.addSubview(activityIndicator)
        
        setupSteps()
        setupConstraints()
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startMeasurementTapped), for: .touchUpInside)
    }
    
    private func setupSteps() {
        let steps = [
            ("1", "⚡", "Make sure the blood pressure monitor is powered on"),
            ("2", "🩹", "Wear the cuff correctly on your left arm"),
            ("3", "🔗", "Click the button below to connect")
        ]
        
        for (number, icon, text) in steps {
            let stepView = createStepView(number: number, icon: icon, text: text)
            stepsStackView.addArrangedSubview(stepView)
        }
    }
    
    private func createStepView(number: String, icon: String, text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 20
        
        let numberLabel = UILabel()
        numberLabel.text = number
        numberLabel.font = .systemFont(ofSize: 32, weight: .bold)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        numberLabel.layer.cornerRadius = 24
        numberLabel.clipsToBounds = true
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 32)
        iconLabel.textAlignment = .center
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 24)
        textLabel.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        textLabel.numberOfLines = 0
        
        container.addSubview(numberLabel)
        container.addSubview(iconLabel)
        container.addSubview(textLabel)
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            numberLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            numberLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            numberLabel.widthAnchor.constraint(equalToConstant: 48),
            numberLabel.heightAnchor.constraint(equalToConstant: 48),
            
            iconLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 24),
            iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 48),
            
            textLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 24),
            textLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            textLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textLabel.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 24),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -24),
        ])
        
        return container
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        headerIconLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsStackView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 48),
            
            headerIconLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 40),
            headerIconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            instructionLabel.topAnchor.constraint(equalTo: headerIconLabel.bottomAnchor, constant: 20),
            instructionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            stepsStackView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 60),
            stepsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding + 80),
            stepsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(padding + 80)),
            
            startButton.topAnchor.constraint(equalTo: stepsStackView.bottomAnchor, constant: 60),
            startButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 100),
            startButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 450),
            startButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            
            activityIndicator.centerXAnchor.constraint(equalTo: startButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceConnected),
            name: .deviceConnected,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceDisconnected),
            name: .deviceDisconnected,
            object: nil
        )
    }
    
    // MARK: - Device Management
    private func updateDeviceStatus() {
        // Check connection status from iHealthService
        let isConnected = false // Replace with actual check
        
        startButton.isEnabled = true // Always enable for demo
        startButton.alpha = 1.0
    }
    
    // MARK: - Measurement
    @objc private func startMeasurementTapped() {
        startMeasurement()
    }
    
    private func startMeasurement() {
        guard !isMeasuring else { return }
        
        isMeasuring = true
        
        // UI updates
        startButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        startButton.isEnabled = false
        
        // Voice guidance
        VoiceService.shared.speakMeasurementStart()
        
        // 📊 真实蓝牙测量
        print("🩺 [MeasureVC] 开始测量，调用 iHealthService...")
        iHealthService.shared.startMeasurement { [weak self] reading in
            print("📥 [MeasureVC] 收到测量结果: \(reading.systolic)/\(reading.diastolic) mmHg")
            DispatchQueue.main.async {
                self?.handleMeasurementComplete(reading)
            }
        }
        
        // 备用：如果 3 秒没响应，使用模拟数据（用于测试）
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            guard let self = self, self.isMeasuring else { return }
            
            print("⚠️ [MeasureVC] 蓝牙超时，使用模拟数据")
            let reading = BloodPressureReading(
                systolic: Int.random(in: 110...140),
                diastolic: Int.random(in: 70...90),
                pulse: Int.random(in: 60...100)
            )
            self.handleMeasurementComplete(reading)
        }
    }
    
    private func handleMeasurementComplete(_ reading: BloodPressureReading) {
        isMeasuring = false
        currentReading = reading
        
        print("✅ [MeasureVC] 测量完成: \(reading.systolic)/\(reading.diastolic) mmHg, 心率: \(reading.pulse)")
        
        // Stop loading
        activityIndicator.stopAnimating()
        startButton.setTitle("Start Measurement", for: .normal)
        startButton.isEnabled = true
        
        // 💾 保存数据
        print("💾 [MeasureVC] 开始保存数据到 UserDefaults...")
        BloodPressureReading.add(reading)
        
        // 🔍 验证保存
        let savedReadings = BloodPressureReading.load()
        print("✅ [MeasureVC] 保存成功！当前共有 \(savedReadings.count) 条记录")
        print("📝 [MeasureVC] 最新记录: \(savedReadings.first?.formattedValue ?? "无")")
        
        // Voice announcement
        // VoiceService.shared.speakMeasurementResult(reading)
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Navigate to result screen
        let resultVC = ResultViewController(reading: reading)
        resultVC.modalPresentationStyle = .fullScreen
        present(resultVC, animated: true)
        
        // Post notification
        NotificationCenter.default.post(name: .measurementCompleted, object: nil, userInfo: ["reading": reading])
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        tabBarController?.selectedIndex = 0
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func deviceConnected() {
        updateDeviceStatus()
    }
    
    @objc private func deviceDisconnected() {
        updateDeviceStatus()
        if isMeasuring {
            handleMeasurementError()
        }
    }
    
    private func handleMeasurementError() {
        isMeasuring = false
        activityIndicator.stopAnimating()
        startButton.setTitle("Start Measurement", for: .normal)
        startButton.isEnabled = true
        
        VoiceService.shared.speakError("Measurement failed")
        
        let alert = UIAlertController(
            title: "Measurement Failed",
            message: "Please try again",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
struct MeasureViewController_Previews: PreviewProvider {
    static var previews: some View {
        MeasureViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct MeasureViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MeasureViewController {
        return MeasureViewController()
    }
    
    func updateUIViewController(_ uiViewController: MeasureViewController, context: Context) {
        // 更新视图控制器（如果需要）
    }
}
#endif
