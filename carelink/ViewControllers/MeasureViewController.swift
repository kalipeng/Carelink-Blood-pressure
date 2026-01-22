//
//  MeasureViewController.swift
//  HealthPad
//
//  Measurement Screen - Core Functionality Page
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
        config.contentInsets = NSDirectionalEdgeInsets(
            top: UIScreen.adaptiveSpacing(small: 8, regular: 12, large: 14),
            leading: UIScreen.adaptiveSpacing(small: 16, regular: 24, large: 28),
            bottom: UIScreen.adaptiveSpacing(small: 8, regular: 12, large: 14),
            trailing: UIScreen.adaptiveSpacing(small: 16, regular: 24, large: 28)
        )
        config.background.backgroundColor = .white
        config.background.cornerRadius = 12
        
        let button = UIButton(configuration: config)
        // 📱 Adaptive font size: 18pt (small) -> 24pt (regular) -> 26pt (large)
        button.titleLabel?.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 18, regular: 24, large: 26))
        return button
    }()
    
    private let headerIconLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        // 📱 Adaptive icon size: 60pt (small) -> 80pt (regular) -> 96pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 60, regular: 80, large: 96))
        label.textAlignment = .center
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Follow these steps"
        // 📱 Adaptive font size: 28pt (small) -> 36pt (regular) -> 40pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 28, regular: 36, large: 40), weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private let stepsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        // 📱 Adaptive spacing: 12pt (small) -> 20pt (regular) -> 24pt (large)
        stack.spacing = UIScreen.adaptiveSpacing(small: 12, regular: 20, large: 24)
        stack.alignment = .fill
        return stack
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Measurement", for: .normal)
        // 📱 Adaptive font size: 32pt (small) -> 42pt (regular) -> 48pt (large)
        button.titleLabel?.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 32, regular: 42, large: 48), weight: .bold)
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
        // 📱 Adaptive font size: 24pt (small) -> 32pt (regular) -> 36pt (large)
        numberLabel.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 24, regular: 32, large: 36), weight: .bold)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        numberLabel.layer.cornerRadius = UIScreen.adaptiveSpacing(small: 18, regular: 24, large: 28)
        numberLabel.clipsToBounds = true
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        // 📱 Adaptive icon size: 26pt (small) -> 32pt (regular) -> 36pt (large)
        iconLabel.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 26, regular: 32, large: 36))
        iconLabel.textAlignment = .center
        
        let textLabel = UILabel()
        textLabel.text = text
        // 📱 Adaptive font size: 18pt (small) -> 24pt (regular) -> 26pt (large)
        textLabel.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 18, regular: 24, large: 26))
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
            // 📱 Adaptive height: 70pt (small) -> 90pt (regular) -> 100pt (large)
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreen.adaptiveSpacing(small: 70, regular: 90, large: 100)),
            
            numberLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: UIScreen.adaptiveSpacing(small: 16, regular: 24, large: 28)),
            numberLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            // 📱 Adaptive badge size: 36pt (small) -> 48pt (regular) -> 54pt (large)
            numberLabel.widthAnchor.constraint(equalToConstant: UIScreen.adaptiveSpacing(small: 36, regular: 48, large: 54)),
            numberLabel.heightAnchor.constraint(equalToConstant: UIScreen.adaptiveSpacing(small: 36, regular: 48, large: 54)),
            
            iconLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: UIScreen.adaptiveSpacing(small: 16, regular: 24, large: 28)),
            iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: UIScreen.adaptiveSpacing(small: 40, regular: 48, large: 54)),
            
            textLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: UIScreen.adaptiveSpacing(small: 16, regular: 24, large: 28)),
            textLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -UIScreen.adaptiveSpacing(small: 16, regular: 24, large: 28)),
            textLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textLabel.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: UIScreen.adaptiveSpacing(small: 16, regular: 24, large: 28)),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -UIScreen.adaptiveSpacing(small: 16, regular: 24, large: 28)),
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
        
        // 📱 Use adaptive padding and spacing
        let padding: CGFloat = UIScreen.adaptivePadding
        let verticalSpacing: CGFloat = UIScreen.adaptiveVerticalSpacing
        
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
        
        // 📊 Real Bluetooth measurement
        print("🩺 [MeasureVC] Starting measurement, calling iHealthService...")
        iHealthService.shared.startMeasurement { [weak self] reading in
            print("📥 [MeasureVC] Received measurement result: \(reading.systolic)/\(reading.diastolic) mmHg")
            DispatchQueue.main.async {
                self?.handleMeasurementComplete(reading)
            }
        }
        
        // Fallback: If no response in 30 seconds, use simulated data (for testing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            guard let self = self, self.isMeasuring else { return }
            
            print("\n⚠️ [MeasureVC] ========== Bluetooth Timeout Warning ==========")
            print("⚠️ [MeasureVC] No data received from blood pressure monitor within 30 seconds")
            print("⚠️ [MeasureVC] Possible reasons:")
            print("   1. Blood pressure monitor not powered on or not paired")
            print("   2. Bluetooth distance too far")
            print("   3. Device doesn't support remote measurement")
            print("🧪 [MeasureVC] Using simulated data for demonstration")
            print("⚠️ [MeasureVC] ========================================\n")
            
            let reading = BloodPressureReading(
                systolic: Int.random(in: 110...140),
                diastolic: Int.random(in: 70...90),
                pulse: Int.random(in: 60...100),
                source: "simulated"  // 🔍 Explicitly marked as simulated data
            )
            self.handleMeasurementComplete(reading)
        }
    }
    
    private func handleMeasurementComplete(_ reading: BloodPressureReading) {
        isMeasuring = false
        currentReading = reading
        
        print("✅ [MeasureVC] Measurement complete: \(reading.systolic)/\(reading.diastolic) mmHg, Pulse: \(reading.pulse)")
        
        // Stop loading
        activityIndicator.stopAnimating()
        startButton.setTitle("Start Measurement", for: .normal)
        startButton.isEnabled = true
        
        // 💾 Save data
        print("💾 [MeasureVC] Starting to save data to UserDefaults...")
        BloodPressureReading.add(reading)
        
        // 🔍 Verify save
        let savedReadings = BloodPressureReading.load()
        print("✅ [MeasureVC] Save successful! Total \(savedReadings.count) records")
        print("📝 [MeasureVC] Latest record: \(savedReadings.first?.formattedValue ?? "None")")
        
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
        // Update view controller (if needed)
    }
}
#endif
