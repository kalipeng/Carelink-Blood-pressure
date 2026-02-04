//
//  MeasureViewController.swift
//  carelink
//
//  AI-Guided Blood Pressure Measurement Screen
//  Features: Camera + GPT-4 Vision + Whisper + Step-by-step guidance
//

import UIKit
import AVFoundation
import SwiftUI

class MeasureViewController: UIViewController {
    
    // MARK: - Properties
    private var isMeasuring = false
    private var currentStep = 0
    private var timer: Timer?
    private var elapsedSeconds = 0
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // T-Mobile Pink color
    private let primaryColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0) // #E3007A
    
    private let steps = [
        "Turn on your blood pressure monitor and wait for it to be ready",
        "Put on the cuff correctly on your left arm, about one inch above your elbow",
        "Sit still, relax, and press the START button on your monitor",
        "Wait quietly for the measurement to complete. Do not move or talk",
        "When the numbers appear, point the camera at the screen so I can read them"
    ]
    
    // MARK: - UI Components
    
    // Top section - Camera
    private let cameraContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.clipsToBounds = true
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("← Back", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI-Guided Measurement"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    // Camera switch button
    private let cameraSwitchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔄", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let cameraPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "📷\nCamera Preview"
        label.font = .systemFont(ofSize: 24)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Capture button (floating on camera) - Always visible for quick capture
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📸 Capture Reading", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0)
        button.layer.cornerRadius = 25
        button.isHidden = false // Always visible - capture anytime if numbers are ready
        return button
    }()
    
    // Quick capture hint label
    private let quickCaptureHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have numbers? Tap to capture now!"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    // Bottom section - Instructions panel
    private let instructionsPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let bpIconLabel: UILabel = {
        let label = UILabel()
        label.text = "🩺"
        label.font = .systemFont(ofSize: 40)
        return label
    }()
    
    private let measurementTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Blood Pressure Measurement"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        return label
    }()
    
    private let measurementSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Follow the voice guide or capture anytime"
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        return label
    }()
    
    private let activityStepsLabel: UILabel = {
        let label = UILabel()
        label.text = "Activity Steps"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        return label
    }()
    
    private let stepsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()
    
    private var stepViews: [UIView] = []
    
    private let manualEntryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✍️ Enter Manually Instead", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0), for: .normal)
        button.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 0.1)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    private let voiceInputButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎤 Voice Input", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
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
        setupCamera()
        setupStepViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCameraSession()
        
        // Auto-start guidance after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.startGuidance()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCameraSession()
        stopTimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraContainerView.bounds
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add subviews
        view.addSubview(cameraContainerView)
        cameraContainerView.addSubview(cameraPlaceholderLabel)
        cameraContainerView.addSubview(backButton)
        cameraContainerView.addSubview(titleLabel)
        cameraContainerView.addSubview(timerLabel)
        cameraContainerView.addSubview(cameraSwitchButton)
        cameraContainerView.addSubview(captureButton)
        cameraContainerView.addSubview(quickCaptureHintLabel)
        
        view.addSubview(instructionsPanelView)
        instructionsPanelView.addSubview(bpIconLabel)
        instructionsPanelView.addSubview(measurementTitleLabel)
        instructionsPanelView.addSubview(measurementSubtitleLabel)
        instructionsPanelView.addSubview(activityStepsLabel)
        instructionsPanelView.addSubview(stepsStackView)
        instructionsPanelView.addSubview(manualEntryButton)
        instructionsPanelView.addSubview(voiceInputButton)
        
        // Button actions
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(captureReading), for: .touchUpInside)
        cameraSwitchButton.addTarget(self, action: #selector(switchCameraTapped), for: .touchUpInside)
        manualEntryButton.addTarget(self, action: #selector(manualEntryTapped), for: .touchUpInside)
        voiceInputButton.addTarget(self, action: #selector(voiceInputTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        cameraContainerView.translatesAutoresizingMaskIntoConstraints = false
        cameraPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        cameraSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        quickCaptureHintLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsPanelView.translatesAutoresizingMaskIntoConstraints = false
        bpIconLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityStepsLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsStackView.translatesAutoresizingMaskIntoConstraints = false
        manualEntryButton.translatesAutoresizingMaskIntoConstraints = false
        voiceInputButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Camera container - top 45%
            cameraContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45),
            
            // Camera placeholder
            cameraPlaceholderLabel.centerXAnchor.constraint(equalTo: cameraContainerView.centerXAnchor),
            cameraPlaceholderLabel.centerYAnchor.constraint(equalTo: cameraContainerView.centerYAnchor),
            
            // Back button
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: cameraContainerView.leadingAnchor, constant: 20),
            
            // Title
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: cameraContainerView.centerXAnchor),
            
            // Timer
            timerLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: cameraSwitchButton.leadingAnchor, constant: -8),
            timerLabel.widthAnchor.constraint(equalToConstant: 80),
            timerLabel.heightAnchor.constraint(equalToConstant: 36),
            
            // Camera switch button
            cameraSwitchButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            cameraSwitchButton.trailingAnchor.constraint(equalTo: cameraContainerView.trailingAnchor, constant: -20),
            cameraSwitchButton.widthAnchor.constraint(equalToConstant: 40),
            cameraSwitchButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Quick capture hint (above capture button)
            quickCaptureHintLabel.centerXAnchor.constraint(equalTo: cameraContainerView.centerXAnchor),
            quickCaptureHintLabel.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -8),
            quickCaptureHintLabel.widthAnchor.constraint(equalToConstant: 280),
            quickCaptureHintLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // Capture button
            captureButton.centerXAnchor.constraint(equalTo: cameraContainerView.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: cameraContainerView.bottomAnchor, constant: -20),
            captureButton.heightAnchor.constraint(equalToConstant: 50),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            
            // Instructions panel - bottom 55%
            instructionsPanelView.topAnchor.constraint(equalTo: cameraContainerView.bottomAnchor, constant: -24),
            instructionsPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            instructionsPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            instructionsPanelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // BP Icon
            bpIconLabel.topAnchor.constraint(equalTo: instructionsPanelView.topAnchor, constant: 24),
            bpIconLabel.leadingAnchor.constraint(equalTo: instructionsPanelView.leadingAnchor, constant: 24),
            
            // Measurement title
            measurementTitleLabel.centerYAnchor.constraint(equalTo: bpIconLabel.centerYAnchor, constant: -10),
            measurementTitleLabel.leadingAnchor.constraint(equalTo: bpIconLabel.trailingAnchor, constant: 12),
            
            // Measurement subtitle
            measurementSubtitleLabel.topAnchor.constraint(equalTo: measurementTitleLabel.bottomAnchor, constant: 2),
            measurementSubtitleLabel.leadingAnchor.constraint(equalTo: measurementTitleLabel.leadingAnchor),
            
            // Activity steps label
            activityStepsLabel.topAnchor.constraint(equalTo: bpIconLabel.bottomAnchor, constant: 20),
            activityStepsLabel.leadingAnchor.constraint(equalTo: instructionsPanelView.leadingAnchor, constant: 24),
            
            // Steps stack view
            stepsStackView.topAnchor.constraint(equalTo: activityStepsLabel.bottomAnchor, constant: 12),
            stepsStackView.leadingAnchor.constraint(equalTo: instructionsPanelView.leadingAnchor, constant: 24),
            stepsStackView.trailingAnchor.constraint(equalTo: instructionsPanelView.trailingAnchor, constant: -24),
            
            // Manual entry button
            manualEntryButton.topAnchor.constraint(equalTo: stepsStackView.bottomAnchor, constant: 20),
            manualEntryButton.leadingAnchor.constraint(equalTo: instructionsPanelView.leadingAnchor, constant: 24),
            
            // Voice input button
            voiceInputButton.centerYAnchor.constraint(equalTo: manualEntryButton.centerYAnchor),
            voiceInputButton.leadingAnchor.constraint(equalTo: manualEntryButton.trailingAnchor, constant: 12),
            
            // Bottom constraint for manual entry row
            manualEntryButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
    // MARK: - Setup Steps
    private func setupStepViews() {
        for (index, stepText) in steps.enumerated() {
            let stepView = createStepView(number: index + 1, text: stepText, isActive: index == 0)
            stepViews.append(stepView)
            stepsStackView.addArrangedSubview(stepView)
        }
    }
    
    private func createStepView(number: Int, text: String, isActive: Bool) -> UIView {
        let container = UIView()
        container.backgroundColor = isActive ? primaryColor.withAlphaComponent(0.1) : UIColor(white: 0.97, alpha: 1)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = isActive ? 2 : 0
        container.layer.borderColor = isActive ? primaryColor.cgColor : UIColor.clear.cgColor
        
        let numberLabel = UILabel()
        numberLabel.text = "\(number)"
        numberLabel.font = .systemFont(ofSize: 16, weight: .bold)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = isActive ? primaryColor : UIColor(white: 0.7, alpha: 1)
        numberLabel.layer.cornerRadius = 14
        numberLabel.clipsToBounds = true
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 16)
        textLabel.textColor = isActive ? UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1) : UIColor(white: 0.5, alpha: 1)
        textLabel.numberOfLines = 0
        
        container.addSubview(numberLabel)
        container.addSubview(textLabel)
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            numberLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            numberLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            numberLabel.widthAnchor.constraint(equalToConstant: 28),
            numberLabel.heightAnchor.constraint(equalToConstant: 28),
            
            textLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            textLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textLabel.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 12),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12),
        ])
        
        return container
    }
    
    private func updateStepHighlight(to stepIndex: Int) {
        for (index, stepView) in stepViews.enumerated() {
            let isActive = index == stepIndex
            let isCompleted = index < stepIndex
            
            UIView.animate(withDuration: 0.3) {
                stepView.backgroundColor = isActive ? self.primaryColor.withAlphaComponent(0.1) :
                                          isCompleted ? UIColor(red: 0.9, green: 1, blue: 0.9, alpha: 1) :
                                          UIColor(white: 0.97, alpha: 1)
                stepView.layer.borderWidth = isActive ? 2 : 0
                stepView.layer.borderColor = isActive ? self.primaryColor.cgColor : UIColor.clear.cgColor
                
                // Update number badge color
                if let numberLabel = stepView.subviews.first(where: { ($0 as? UILabel)?.text == "\(index + 1)" }) as? UILabel {
                    numberLabel.backgroundColor = isActive ? self.primaryColor :
                                                 isCompleted ? UIColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 1) :
                                                 UIColor(white: 0.7, alpha: 1)
                }
                
                // Update text color
                if let textLabel = stepView.subviews.last as? UILabel {
                    textLabel.textColor = isActive || isCompleted ? UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1) :
                                         UIColor(white: 0.5, alpha: 1)
                }
            }
        }
        
        // Capture button is always visible - hide hint once guidance starts
        if isMeasuring {
            quickCaptureHintLabel.isHidden = true
        }
    }
    
    // MARK: - Camera Setup
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        configureCamera(position: currentCameraPosition)
    }
    
    private func configureCamera(position: AVCaptureDevice.Position) {
        // Remove existing inputs
        if let inputs = captureSession?.inputs {
            for input in inputs {
                captureSession?.removeInput(input)
            }
        }
        
        // Get camera for specified position
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            print("❌ [Camera] No \(position == .front ? "front" : "back") camera available")
            cameraPlaceholderLabel.text = "📷\nCamera not available\nUse manual entry"
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
            
            // Only add output once
            if photoOutput == nil {
                photoOutput = AVCapturePhotoOutput()
                if let photoOutput = photoOutput, captureSession?.canAddOutput(photoOutput) == true {
                    captureSession?.addOutput(photoOutput)
                }
            }
            
            // Only add preview layer once
            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer?.videoGravity = .resizeAspectFill
                previewLayer?.frame = cameraContainerView.bounds
                
                if let previewLayer = previewLayer {
                    cameraContainerView.layer.insertSublayer(previewLayer, at: 0)
                }
            }
            
            cameraPlaceholderLabel.isHidden = true
            print("✅ [Camera] Setup complete - using \(position == .front ? "front" : "back") camera")
            
        } catch {
            print("❌ [Camera] Setup failed: \(error)")
            cameraPlaceholderLabel.text = "📷\nCamera error\nUse manual entry"
        }
    }
    
    @objc private func switchCameraTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Toggle camera position
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        // Reconfigure camera
        configureCamera(position: currentCameraPosition)
        
        // Update button appearance
        let cameraName = currentCameraPosition == .front ? "Front" : "Back"
        print("📷 [Camera] Switched to \(cameraName) camera")
    }
    
    private func startCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopCameraSession() {
        captureSession?.stopRunning()
    }
    
    // MARK: - Timer
    private func startTimer() {
        elapsedSeconds = 0
        updateTimerLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
            self?.updateTimerLabel()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimerLabel() {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        stopGuidance()
        VoiceService.shared.stop()
        tabBarController?.selectedIndex = 0
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func startGuidance() {
        guard !isMeasuring else { return } // Prevent double-start
        
        isMeasuring = true
        currentStep = 0
        
        startTimer()
        updateStepHighlight(to: 0)
        
        // Hide quick capture hint during guidance
        quickCaptureHintLabel.isHidden = true
        
        // Voice guidance - starts automatically
        VoiceService.shared.speak("Starting blood pressure measurement. Step 1: \(steps[0])")
        
        // Auto-advance steps
        advanceStepsAutomatically()
    }
    
    private func stopGuidance() {
        isMeasuring = false
        stopTimer()
        elapsedSeconds = 0
        updateTimerLabel()
        
        currentStep = 0
        updateStepHighlight(to: 0)
        quickCaptureHintLabel.isHidden = false
    }
    
    // Time for each step in seconds
    // Step 1: Turn on monitor - 8 seconds
    // Step 2: Put on cuff - 20 seconds  
    // Step 3: Press START - 10 seconds
    // Step 4: Wait for measurement - 60 seconds (blood pressure measurement takes ~45-60 seconds)
    // Step 5: Point camera - user controlled
    private let stepDurations: [TimeInterval] = [8, 20, 10, 60, 0]
    
    private func advanceStepsAutomatically() {
        guard isMeasuring else { return }
        
        let currentDuration = stepDurations[currentStep]
        
        // Step 4 (index 3) is the measurement - give countdown feedback
        if currentStep == 3 {
            // Give periodic updates during measurement
            startMeasurementCountdown()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentDuration) { [weak self] in
            guard let self = self, self.isMeasuring else { return }
            
            if self.currentStep < self.steps.count - 1 {
                self.currentStep += 1
                self.updateStepHighlight(to: self.currentStep)
                
                // Voice guidance for current step
                VoiceService.shared.speak("Step \(self.currentStep + 1): \(self.steps[self.currentStep])")
                
                // Continue advancing
                self.advanceStepsAutomatically()
            } else {
                // On last step - wait for capture
                VoiceService.shared.speak("When the numbers appear on your monitor, point the camera at the screen and tap Capture Reading.")
            }
        }
    }
    
    private func startMeasurementCountdown() {
        // Wait 30 seconds, then give a progress update
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            guard let self = self, self.isMeasuring, self.currentStep == 3 else { return }
            VoiceService.shared.speak("Keep waiting. The measurement should finish soon.")
        }
        
        // After 60 seconds, move to next step
        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) { [weak self] in
            guard let self = self, self.isMeasuring, self.currentStep == 3 else { return }
            
            self.currentStep += 1
            self.updateStepHighlight(to: self.currentStep)
            VoiceService.shared.speak("Step 5: \(self.steps[self.currentStep])")
            
            // Last step - wait for user to capture
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                VoiceService.shared.speak("When the numbers appear on your monitor, point the camera at the screen and tap Capture Reading.")
            }
        }
    }
    
    // MARK: - Capture & Vision
    @objc private func captureReading() {
        // Check if API key is configured
        guard OpenAIService.shared.hasAPIKey() else {
            VoiceService.shared.speak("Please configure your OpenAI API key first. Go to home screen and tap Settings.")
            showAPIKeyAlert()
            return
        }
        
        guard let photoOutput = photoOutput else {
            VoiceService.shared.speak("Camera not available. Please enter the values manually.")
            showManualEntryAlert()
            return
        }
        
        captureButton.isEnabled = false
        captureButton.setTitle("Analyzing...", for: .normal)
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        VoiceService.shared.speak("Capturing image. Please hold the camera steady and make sure the numbers are clearly visible.")
    }
    
    private func showAPIKeyAlert() {
        let alert = UIAlertController(
            title: "API Key Required",
            message: "Please configure your OpenAI API key to use the AI vision feature.\n\nGo to Home screen → Settings",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Enter Manually Instead", style: .default) { [weak self] _ in
            self?.showManualEntryAlert()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func analyzeImageWithVision(_ image: UIImage) {
        print("🔍 [Vision] Analyzing blood pressure monitor image...")
        
        VoiceService.shared.speak("Analyzing the image. Please wait.")
        
        OpenAIService.shared.analyzeBloodPressureImage(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.captureButton.isEnabled = true
                self?.captureButton.setTitle("Capture Reading", for: .normal)
                
                switch result {
                case .success(let optionalReading):
                    if let reading = optionalReading {
                        print("✅ [Vision] Extracted: \(reading.systolic)/\(reading.diastolic), Pulse: \(reading.pulse)")
                        
                        // Show confirmation dialog to verify accuracy
                        self?.showConfirmReadingAlert(
                            systolic: reading.systolic,
                            diastolic: reading.diastolic,
                            pulse: reading.pulse
                        )
                    } else {
                        print("⚠️ [Vision] Could not parse values from image")
                        VoiceService.shared.speak("I couldn't read the numbers clearly. Please make sure the screen is fully visible and well-lit, then try again. Or you can enter the values manually.")
                        self?.showRetryOrManualAlert(error: "Could not parse blood pressure values from the image. Make sure the monitor screen is clearly visible.")
                    }
                    
                case .failure(let error):
                    print("❌ [Vision] Failed: \(error.localizedDescription)")
                    VoiceService.shared.speak("Sorry, there was a problem reading the monitor. Please check your internet connection and try again, or enter the values manually.")
                    self?.showRetryOrManualAlert(error: error.localizedDescription)
                }
            }
        }
    }
    
    private func showConfirmReadingAlert(systolic: Int, diastolic: Int, pulse: Int) {
        // Speak the reading
        VoiceService.shared.speak("I read \(systolic) over \(diastolic), pulse \(pulse). Is this correct?")
        
        let alert = UIAlertController(
            title: "Confirm Reading",
            message: "I detected:\n\n📊 Blood Pressure: \(systolic)/\(diastolic) mmHg\n❤️ Pulse: \(pulse) bpm\n\nIs this correct?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "✓ Correct, Save", style: .default) { [weak self] _ in
            VoiceService.shared.speak("Saving your result.")
            self?.handleMeasurementComplete(
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                source: "vision"
            )
        })
        
        alert.addAction(UIAlertAction(title: "✗ Wrong, Re-capture", style: .default) { [weak self] _ in
            VoiceService.shared.speak("Please point the camera at the screen again and tap capture.")
        })
        
        alert.addAction(UIAlertAction(title: "Edit Manually", style: .default) { [weak self] _ in
            self?.showManualEntryWithPrefill(systolic: systolic, diastolic: diastolic, pulse: pulse)
        })
        
        present(alert, animated: true)
    }
    
    private func showManualEntryWithPrefill(systolic: Int, diastolic: Int, pulse: Int) {
        let alert = UIAlertController(
            title: "Edit Reading",
            message: "Correct the values if needed:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Systolic (top number)"
            textField.text = "\(systolic)"
            textField.keyboardType = .numberPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Diastolic (bottom number)"
            textField.text = "\(diastolic)"
            textField.keyboardType = .numberPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Pulse (heart rate)"
            textField.text = "\(pulse)"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let systolicText = alert.textFields?[0].text,
                  let diastolicText = alert.textFields?[1].text,
                  let pulseText = alert.textFields?[2].text,
                  let sys = Int(systolicText),
                  let dia = Int(diastolicText),
                  let pul = Int(pulseText) else {
                VoiceService.shared.speak("Invalid input. Please try again.")
                return
            }
            
            VoiceService.shared.speak("Saving \(sys) over \(dia), pulse \(pul).")
            self?.handleMeasurementComplete(systolic: sys, diastolic: dia, pulse: pul, source: "vision-edited")
        })
        
        present(alert, animated: true)
    }
    
    private func showRetryOrManualAlert(error: String) {
        let alert = UIAlertController(
            title: "Could Not Read Monitor",
            message: "The AI couldn't extract the readings. Would you like to try again or enter manually?\n\nError: \(error)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.captureReading()
        })
        
        alert.addAction(UIAlertAction(title: "Enter Manually", style: .default) { [weak self] _ in
            self?.showManualEntryAlert()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Manual Entry
    @objc private func manualEntryTapped() {
        showManualEntryAlert()
    }
    
    private func showManualEntryAlert() {
        let alert = UIAlertController(
            title: "Enter Blood Pressure",
            message: "Please enter your reading manually",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Systolic (top number)"
            textField.keyboardType = .numberPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Diastolic (bottom number)"
            textField.keyboardType = .numberPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Pulse (heart rate)"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let systolicText = alert.textFields?[0].text,
                  let diastolicText = alert.textFields?[1].text,
                  let pulseText = alert.textFields?[2].text,
                  let systolic = Int(systolicText),
                  let diastolic = Int(diastolicText),
                  let pulse = Int(pulseText) else {
                VoiceService.shared.speak("Invalid input. Please try again.")
                return
            }
            
            self?.handleMeasurementComplete(systolic: systolic, diastolic: diastolic, pulse: pulse, source: "manual")
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Voice Input
    @objc private func voiceInputTapped() {
        VoiceService.shared.speak("Please say your blood pressure reading. For example: one twenty over eighty, pulse seventy two.")
        
        // Start recording
        AudioRecorderService.shared.recordForDuration(10) { [weak self] audioURL in
            guard let audioURL = audioURL else {
                DispatchQueue.main.async {
                    VoiceService.shared.speak("Could not record audio. Please try manual entry.")
                }
                return
            }
            
            // Transcribe with Whisper
            OpenAIService.shared.transcribeAudio(audioURL: audioURL) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let text):
                        print("🎤 [Whisper] Transcribed: \(text)")
                        self?.parseVoiceInput(text)
                        
                    case .failure(let error):
                        print("❌ [Whisper] Error: \(error)")
                        VoiceService.shared.speak("Could not understand. Please try manual entry.")
                    }
                    
                    // Clean up audio file
                    AudioRecorderService.shared.deleteRecording(at: audioURL)
                }
            }
        }
    }
    
    private func parseVoiceInput(_ text: String) {
        // Use GPT to parse the voice input
        let prompt = """
        Extract blood pressure readings from this voice input: "\(text)"
        
        Return ONLY a JSON object: {"systolic": NUMBER, "diastolic": NUMBER, "pulse": NUMBER}
        If you can't find a value, use -1.
        
        Examples:
        - "one twenty over eighty pulse seventy two" → {"systolic": 120, "diastolic": 80, "pulse": 72}
        - "blood pressure is 135 over 85" → {"systolic": 135, "diastolic": 85, "pulse": -1}
        """
        
        OpenAIService.shared.chatCompletion(
            userMessage: prompt,
            systemPrompt: "You extract numbers from voice input. Return only JSON."
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.parseGPTResponse(response)
                case .failure:
                    VoiceService.shared.speak("Could not understand. Please enter manually.")
                    self?.showManualEntryAlert()
                }
            }
        }
    }
    
    private func parseGPTResponse(_ response: String) {
        let jsonString = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let systolic = json["systolic"] as? Int, systolic > 0,
              let diastolic = json["diastolic"] as? Int, diastolic > 0 else {
            VoiceService.shared.speak("Could not understand the readings. Please enter manually.")
            showManualEntryAlert()
            return
        }
        
        let pulse = (json["pulse"] as? Int) ?? 0
        
        // Confirm with user
        let confirmMsg = "I heard: \(systolic) over \(diastolic)\(pulse > 0 ? ", pulse \(pulse)" : ""). Is this correct?"
        VoiceService.shared.speak(confirmMsg)
        
        let alert = UIAlertController(
            title: "Confirm Reading",
            message: "Systolic: \(systolic)\nDiastolic: \(diastolic)\nPulse: \(pulse > 0 ? "\(pulse)" : "Not provided")",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Correct", style: .default) { [weak self] _ in
            self?.handleMeasurementComplete(systolic: systolic, diastolic: diastolic, pulse: pulse > 0 ? pulse : 72, source: "voice")
        })
        
        alert.addAction(UIAlertAction(title: "Try Again", style: .cancel) { [weak self] _ in
            self?.voiceInputTapped()
        })
        
        alert.addAction(UIAlertAction(title: "Enter Manually", style: .default) { [weak self] _ in
            self?.showManualEntryAlert()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Handle Complete
    private func handleMeasurementComplete(systolic: Int, diastolic: Int, pulse: Int, source: String) {
        stopGuidance()
        
        let reading = BloodPressureReading(
            systolic: systolic,
            diastolic: diastolic,
            pulse: pulse,
            source: source
        )
        
        print("✅ [MeasureVC] Measurement complete: \(reading.systolic)/\(reading.diastolic) mmHg, Pulse: \(reading.pulse), Source: \(source)")
        
        // Save locally
        BloodPressureReading.add(reading)
        print("💾 [MeasureVC] Saved to local storage")
        
        // Upload to API
        CloudSyncService.shared.uploadReading(reading) { success, error in
            if success {
                print("📤 [MeasureVC] Uploaded to API")
            } else {
                print("⚠️ [MeasureVC] Upload failed: \(error ?? "Unknown")")
            }
        }
        
        // Voice feedback
        VoiceService.shared.speak("Measurement recorded. \(reading.systolic) over \(reading.diastolic), pulse \(reading.pulse).")
        
        // Haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Navigate to result
        let resultVC = ResultViewController(reading: reading)
        resultVC.modalPresentationStyle = .fullScreen
        present(resultVC, animated: true)
        
        // Post notification
        NotificationCenter.default.post(name: .measurementCompleted, object: nil, userInfo: ["reading": reading])
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension MeasureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ [Camera] Photo capture error: \(error)")
            showManualEntryAlert()
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ [Camera] Could not get image data")
            showManualEntryAlert()
            return
        }
        
        print("📸 [Camera] Photo captured, sending to Vision API...")
        analyzeImageWithVision(image)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
// Canvas Preview: use a simulator. Previews often fail on physical devices.
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
    
    func updateUIViewController(_ uiViewController: MeasureViewController, context: Context) {}
}
#endif
