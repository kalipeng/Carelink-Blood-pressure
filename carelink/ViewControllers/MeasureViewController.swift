//
//  MeasureViewController.swift
//  carelink
//
//  AI-Guided Blood Pressure Measurement Screen
//  iPad Optimized: Large camera preview (80%) + Single step display
//

import UIKit
import AVFoundation
import CoreImage
import SwiftUI

class MeasureViewController: UIViewController {
    
    /// Why we are capturing a photo: BP reading vs behavior-based AI guidance
    private enum CaptureMode {
        case bloodPressureReading
        case behaviorGuidance
    }
    
    // MARK: - Properties
    private var isMeasuring = false
    private var currentStep = 0
    private var timer: Timer?
    private var elapsedSeconds = 0
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private let videoDataQueue = DispatchQueue(label: "carelink.videoData")
    /// Latest frame from camera for auto guidance (main thread only); updated every ~15 frames
    private var latestCaptureFrame: UIImage?
    private var videoFrameCount = 0
    private var guidanceRequestInFlight = false
    private var autoGuidanceTimer: Timer?
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var currentCaptureMode: CaptureMode = .bloodPressureReading
    /// Auto-capture countdown timer (fires when elderly reaches Step 5)
    private var autoCaptureTimer: Timer?
    private var autoCaptureCountdown = 0
    
    // T-Mobile Pink color
    private let primaryColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0) // #E3007A
    
    private let steps = [
        "Turn on your blood pressure monitor and wait for it to be ready",
        "Put on the cuff correctly on your left arm, about one inch above your elbow",
        "Sit still, relax, and press the START button on your monitor",
        "Wait quietly for the measurement to complete. Do not move or talk",
        "When the numbers appear, point the camera at the screen so I can read them"
    ]
    
    // Time for each step in seconds
    private let stepDurations: [TimeInterval] = [8, 20, 10, 60, 0]
    
    // MARK: - UI Components
    
    // Large Camera Container (80% of screen)
    private let cameraContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.clipsToBounds = true
        return view
    }()
    
    // Header elements
    private let backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "← Back"
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer([.font: UIFont.systemFont(ofSize: 18, weight: .medium)])
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.background.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        config.background.cornerRadius = 8
        return UIButton(configuration: config)
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI-Guided Measurement"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = .monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    private let cameraSwitchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔄", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 18
        return button
    }()
    
    // Camera placeholder (shown when camera not available)
    private let cameraPlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        return view
    }()
    
    private let cameraIconLabel: UILabel = {
        let label = UILabel()
        label.text = "📷"
        label.font = .systemFont(ofSize: 80)
        label.textAlignment = .center
        return label
    }()
    
    private let cameraErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Camera Preview"
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Capture button (centered on camera) – large, easy to tap
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 28, weight: .heavy)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0)
        button.layer.cornerRadius = 40
        button.layer.shadowColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0).cgColor
        button.layer.shadowOpacity = 0.6
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 14
        return button
    }()
    
    // Bottom instruction panel (compact)
    private let instructionPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    // Title row
    private let bpIconLabel: UILabel = {
        let label = UILabel()
        label.text = "🩺"
        label.font = .systemFont(ofSize: 32)
        return label
    }()
    
    private let panelTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Blood Pressure Measurement"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        return label
    }()
    
    private let panelSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Follow the voice guide or capture anytime"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        return label
    }()
    
    // Single step display (instead of all 5)
    private let stepContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 0.08)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0).cgColor
        return view
    }()
    
    private let stepProgressLabel: UILabel = {
        let label = UILabel()
        label.text = "1/5"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0)
        label.layer.cornerRadius = 14
        label.clipsToBounds = true
        return label
    }()
    
    private let stepTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Turn on your blood pressure monitor and wait for it to be ready"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.numberOfLines = 0
        return label
    }()
    
    // Analyzing state
    private let analyzingLabel: UILabel = {
        let label = UILabel()
        label.text = "🔍 Analyzing reading..."
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // Bottom buttons
    private let manualEntryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "✏️ Enter Manually Instead"
        config.baseForegroundColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer([.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        config.background.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 0.1)
        config.background.cornerRadius = 12
        return UIButton(configuration: config)
    }()
    
    private let voiceInputButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "🎤 Voice Input"
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer([.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        config.background.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        config.background.cornerRadius = 12
        return UIButton(configuration: config)
    }()
    
    private let aiGuidanceButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "AI Guidance"
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer([.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.background.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0)
        config.background.cornerRadius = 12
        return UIButton(configuration: config)
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCameraSession()
        
        // Auto-start guidance after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.startGuidance()
        }
        // Auto AI guidance every 5s (first run after 5s so we have frames)
        startAutoGuidanceTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCameraSession()
        stopTimer()
        stopAutoGuidanceTimer()
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
        
        // Camera placeholder
        cameraContainerView.addSubview(cameraPlaceholderView)
        cameraPlaceholderView.addSubview(cameraIconLabel)
        cameraPlaceholderView.addSubview(cameraErrorLabel)
        
        // Header
        cameraContainerView.addSubview(backButton)
        cameraContainerView.addSubview(titleLabel)
        cameraContainerView.addSubview(timerLabel)
        cameraContainerView.addSubview(cameraSwitchButton)
        
        // Capture button
        cameraContainerView.addSubview(captureButton)
        
        // Instruction panel
        view.addSubview(instructionPanelView)
        instructionPanelView.addSubview(bpIconLabel)
        instructionPanelView.addSubview(panelTitleLabel)
        instructionPanelView.addSubview(panelSubtitleLabel)
        instructionPanelView.addSubview(stepContainerView)
        stepContainerView.addSubview(stepProgressLabel)
        stepContainerView.addSubview(stepTextLabel)
        instructionPanelView.addSubview(analyzingLabel)
        instructionPanelView.addSubview(manualEntryButton)
        instructionPanelView.addSubview(voiceInputButton)
        instructionPanelView.addSubview(aiGuidanceButton)
        
        // Button actions
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(captureReading), for: .touchUpInside)
        cameraSwitchButton.addTarget(self, action: #selector(switchCameraTapped), for: .touchUpInside)
        manualEntryButton.addTarget(self, action: #selector(manualEntryTapped), for: .touchUpInside)
        voiceInputButton.addTarget(self, action: #selector(voiceInputTapped), for: .touchUpInside)
        aiGuidanceButton.addTarget(self, action: #selector(aiGuidanceTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Disable autoresizing masks
        [cameraContainerView, cameraPlaceholderView, cameraIconLabel, cameraErrorLabel,
         backButton, titleLabel, timerLabel, cameraSwitchButton, captureButton,
         instructionPanelView, bpIconLabel, panelTitleLabel, panelSubtitleLabel,
         stepContainerView, stepProgressLabel, stepTextLabel, analyzingLabel,
         manualEntryButton, voiceInputButton, aiGuidanceButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Camera container - 80% of screen height
            cameraContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.72),
            
            // Camera placeholder (fills camera container)
            cameraPlaceholderView.topAnchor.constraint(equalTo: cameraContainerView.topAnchor),
            cameraPlaceholderView.leadingAnchor.constraint(equalTo: cameraContainerView.leadingAnchor),
            cameraPlaceholderView.trailingAnchor.constraint(equalTo: cameraContainerView.trailingAnchor),
            cameraPlaceholderView.bottomAnchor.constraint(equalTo: cameraContainerView.bottomAnchor),
            
            // Camera icon
            cameraIconLabel.centerXAnchor.constraint(equalTo: cameraPlaceholderView.centerXAnchor),
            cameraIconLabel.centerYAnchor.constraint(equalTo: cameraPlaceholderView.centerYAnchor, constant: -20),
            
            // Camera error label
            cameraErrorLabel.topAnchor.constraint(equalTo: cameraIconLabel.bottomAnchor, constant: 16),
            cameraErrorLabel.centerXAnchor.constraint(equalTo: cameraPlaceholderView.centerXAnchor),
            cameraErrorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cameraPlaceholderView.leadingAnchor, constant: 40),
            cameraErrorLabel.trailingAnchor.constraint(lessThanOrEqualTo: cameraPlaceholderView.trailingAnchor, constant: -40),
            
            // Back button
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: cameraContainerView.leadingAnchor, constant: 16),
            
            // Title
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: cameraContainerView.centerXAnchor),
            
            // Timer
            timerLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: cameraSwitchButton.leadingAnchor, constant: -8),
            timerLabel.widthAnchor.constraint(equalToConstant: 70),
            timerLabel.heightAnchor.constraint(equalToConstant: 32),
            
            // Camera switch button
            cameraSwitchButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            cameraSwitchButton.trailingAnchor.constraint(equalTo: cameraContainerView.trailingAnchor, constant: -16),
            cameraSwitchButton.widthAnchor.constraint(equalToConstant: 36),
            cameraSwitchButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Capture button (bottom of camera area)
            captureButton.centerXAnchor.constraint(equalTo: cameraContainerView.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: cameraContainerView.bottomAnchor, constant: -20),
            captureButton.heightAnchor.constraint(equalToConstant: 80),
            captureButton.widthAnchor.constraint(equalToConstant: 300),
            
            // Instruction panel (bottom 28%)
            instructionPanelView.topAnchor.constraint(equalTo: cameraContainerView.bottomAnchor, constant: -16),
            instructionPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            instructionPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            instructionPanelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // BP Icon
            bpIconLabel.topAnchor.constraint(equalTo: instructionPanelView.topAnchor, constant: 20),
            bpIconLabel.leadingAnchor.constraint(equalTo: instructionPanelView.leadingAnchor, constant: 20),
            
            // Panel title
            panelTitleLabel.centerYAnchor.constraint(equalTo: bpIconLabel.centerYAnchor, constant: -8),
            panelTitleLabel.leadingAnchor.constraint(equalTo: bpIconLabel.trailingAnchor, constant: 10),
            
            // Panel subtitle
            panelSubtitleLabel.topAnchor.constraint(equalTo: panelTitleLabel.bottomAnchor, constant: 2),
            panelSubtitleLabel.leadingAnchor.constraint(equalTo: panelTitleLabel.leadingAnchor),
            
            // Step container (single step display)
            stepContainerView.topAnchor.constraint(equalTo: bpIconLabel.bottomAnchor, constant: 16),
            stepContainerView.leadingAnchor.constraint(equalTo: instructionPanelView.leadingAnchor, constant: 20),
            stepContainerView.trailingAnchor.constraint(equalTo: instructionPanelView.trailingAnchor, constant: -20),
            stepContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            // Step progress label (1/5)
            stepProgressLabel.leadingAnchor.constraint(equalTo: stepContainerView.leadingAnchor, constant: 12),
            stepProgressLabel.centerYAnchor.constraint(equalTo: stepContainerView.centerYAnchor),
            stepProgressLabel.widthAnchor.constraint(equalToConstant: 40),
            stepProgressLabel.heightAnchor.constraint(equalToConstant: 28),
            
            // Step text
            stepTextLabel.leadingAnchor.constraint(equalTo: stepProgressLabel.trailingAnchor, constant: 12),
            stepTextLabel.trailingAnchor.constraint(equalTo: stepContainerView.trailingAnchor, constant: -12),
            stepTextLabel.topAnchor.constraint(equalTo: stepContainerView.topAnchor, constant: 12),
            stepTextLabel.bottomAnchor.constraint(equalTo: stepContainerView.bottomAnchor, constant: -12),
            
            // Analyzing label (centered in step container area)
            analyzingLabel.centerXAnchor.constraint(equalTo: stepContainerView.centerXAnchor),
            analyzingLabel.centerYAnchor.constraint(equalTo: stepContainerView.centerYAnchor),
            
            // Manual entry button
            manualEntryButton.topAnchor.constraint(equalTo: stepContainerView.bottomAnchor, constant: 16),
            manualEntryButton.leadingAnchor.constraint(equalTo: instructionPanelView.leadingAnchor, constant: 20),
            manualEntryButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            
            // Voice input button
            voiceInputButton.centerYAnchor.constraint(equalTo: manualEntryButton.centerYAnchor),
            voiceInputButton.leadingAnchor.constraint(equalTo: manualEntryButton.trailingAnchor, constant: 12),
            
            // AI guidance (behavior-based from camera)
            aiGuidanceButton.centerYAnchor.constraint(equalTo: manualEntryButton.centerYAnchor),
            aiGuidanceButton.leadingAnchor.constraint(equalTo: voiceInputButton.trailingAnchor, constant: 12),
        ])
    }
    
    // MARK: - Step Display
    private func updateStepDisplay(to stepIndex: Int, animated: Bool = true) {
        guard stepIndex >= 0, stepIndex < steps.count else { return }
        let animationBlock = {
            // Update progress label
            self.stepProgressLabel.text = "\(stepIndex + 1)/5"
            
            // Update step text
            self.stepTextLabel.text = self.steps[stepIndex]
            
            // Update colors based on step
            if stepIndex == self.steps.count - 1 {
                // Last step - ready to capture
                self.stepContainerView.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0.3, alpha: 0.1)
                self.stepContainerView.layer.borderColor = UIColor(red: 0, green: 0.7, blue: 0.3, alpha: 1.0).cgColor
                self.stepProgressLabel.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0.3, alpha: 1.0)
            } else {
                // Normal step
                self.stepContainerView.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 0.08)
                self.stepContainerView.layer.borderColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0).cgColor
                self.stepProgressLabel.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.48, alpha: 1.0)
            }
        }
        
        if animated {
            // Fade out, change, fade in
            UIView.animate(withDuration: 0.15, animations: {
                self.stepContainerView.alpha = 0
            }) { _ in
                animationBlock()
                UIView.animate(withDuration: 0.15) {
                    self.stepContainerView.alpha = 1
                }
            }
        } else {
            animationBlock()
        }
    }
    
    private func showAnalyzingState() {
        UIView.animate(withDuration: 0.2) {
            self.stepContainerView.isHidden = true
            self.analyzingLabel.isHidden = false
        }
    }
    
    private func hideAnalyzingState() {
        UIView.animate(withDuration: 0.2) {
            self.stepContainerView.isHidden = false
            self.analyzingLabel.isHidden = true
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
            cameraErrorLabel.text = "Camera not available\nUse manual entry"
            cameraPlaceholderView.isHidden = false
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
            
            // Only add outputs once
            if photoOutput == nil {
                photoOutput = AVCapturePhotoOutput()
                if let photoOutput = photoOutput, captureSession?.canAddOutput(photoOutput) == true {
                    captureSession?.addOutput(photoOutput)
                }
            }
            if videoDataOutput == nil {
                let videoOut = AVCaptureVideoDataOutput()
                videoOut.setSampleBufferDelegate(self, queue: videoDataQueue)
                videoOut.alwaysDiscardsLateVideoFrames = true
                if captureSession?.canAddOutput(videoOut) == true {
                    captureSession?.addOutput(videoOut)
                    videoDataOutput = videoOut
                }
            }
            
            // Only add preview layer once
            if previewLayer == nil, let session = captureSession {
                let layer = AVCaptureVideoPreviewLayer(session: session)
                layer.videoGravity = .resizeAspectFill
                layer.frame = cameraContainerView.bounds
                cameraContainerView.layer.insertSublayer(layer, at: 0)
                previewLayer = layer
            }
            
            cameraPlaceholderView.isHidden = true
            print("✅ [Camera] Setup complete - using \(position == .front ? "front" : "back") camera")
            
        } catch {
            print("❌ [Camera] Setup failed: \(error)")
            cameraErrorLabel.text = "Camera error\nUse manual entry"
            cameraPlaceholderView.isHidden = false
        }
    }
    
    @objc private func switchCameraTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        configureCamera(position: currentCameraPosition)
        
        print("📷 [Camera] Switched to \(currentCameraPosition == .front ? "front" : "back") camera")
    }
    
    private func startCameraSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self?.captureSession?.startRunning()
                        }
                    } else {
                        self?.cameraErrorLabel.text = "Please allow camera access in Settings\nor use manual entry"
                        self?.cameraPlaceholderView.isHidden = false
                    }
                }
            }
        case .denied, .restricted:
            cameraErrorLabel.text = "Please allow camera access in Settings\nor use manual entry"
            cameraPlaceholderView.isHidden = false
        @unknown default:
            break
        }
    }
    
    private func stopCameraSession() {
        captureSession?.stopRunning()
    }
    
    // MARK: - Auto guidance (every 5 seconds from video stream)
    private func startAutoGuidanceTimer() {
        stopAutoGuidanceTimer()
        autoGuidanceTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.tickAutoGuidance()
        }
        RunLoop.main.add(autoGuidanceTimer!, forMode: .common)
    }
    
    private func stopAutoGuidanceTimer() {
        autoGuidanceTimer?.invalidate()
        autoGuidanceTimer = nil
    }
    
    private func tickAutoGuidance() {
        guard OpenAIService.shared.hasAPIKey(),
              !guidanceRequestInFlight,
              let frame = latestCaptureFrame else { return }
        guidanceRequestInFlight = true
        OpenAIService.shared.analyzeMeasurementGuidance(image: frame) { [weak self] result in
            DispatchQueue.main.async {
                self?.guidanceRequestInFlight = false
                switch result {
                case .success(let guidance):
                    let text = guidance.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty {
                        VoiceService.shared.speak(text)
                    }
                case .failure:
                    break
                }
            }
        }
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
        guard !isMeasuring else { return }
        
        isMeasuring = true
        currentStep = 0
        
        startTimer()
        updateStepDisplay(to: 0, animated: false)
        hideAnalyzingState()
        
        // Voice guidance
        VoiceService.shared.speak("Starting blood pressure measurement. Step 1: \(steps[0])")
        
        // Auto-advance steps
        advanceStepsAutomatically()
    }
    
    private func stopGuidance() {
        isMeasuring = false
        stopTimer()
        elapsedSeconds = 0
        updateTimerLabel()
        cancelAutoCaptureTimer()
        
        currentStep = 0
        updateStepDisplay(to: 0, animated: false)
        hideAnalyzingState()
    }
    
    private func advanceStepsAutomatically() {
        guard isMeasuring else { return }
        
        let currentDuration = stepDurations[currentStep]
        
        // Step 4 (index 3) is the measurement - give countdown feedback
        if currentStep == 3 {
            startMeasurementCountdown()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentDuration) { [weak self] in
            guard let self = self, self.isMeasuring else { return }
            
            if self.currentStep < self.steps.count - 1 {
                self.currentStep += 1
                self.updateStepDisplay(to: self.currentStep)
                
                // Voice guidance for current step
                VoiceService.shared.speak("Step \(self.currentStep + 1): \(self.steps[self.currentStep])")
                
                // Continue advancing
                self.advanceStepsAutomatically()
            } else {
                // On last step – start pulse and auto-capture countdown
                VoiceService.shared.speak("Point the camera at the monitor screen. I will take the photo automatically in 10 seconds, or tap Take Photo now.")
                self.startCaptureButtonPulse()
                self.startAutoCaptureCountdown()
            }
        }
    }
    
    private func startMeasurementCountdown() {
        // Wait 30 seconds, then give a progress update
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            guard let strongSelf = self, strongSelf.isMeasuring, strongSelf.currentStep == 3 else { return }
            VoiceService.shared.speak("Keep waiting. The measurement should finish soon.")
        }
        
        // After 60 seconds, move to next step
        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) { [weak self] in
            guard let self = self, self.isMeasuring, self.currentStep == 3 else { return }
            
            self.currentStep += 1
            self.updateStepDisplay(to: self.currentStep)
            VoiceService.shared.speak("Step 5: \(self.steps[self.currentStep])")
            
            // Last step – show big pulsing button and start auto-capture countdown
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self = self else { return }
                VoiceService.shared.speak("Point the camera at the blood pressure monitor screen. I will take the photo automatically in 10 seconds, or tap Take Photo now.")
                self.startCaptureButtonPulse()
                self.startAutoCaptureCountdown()
            }
        }
    }
    
    // MARK: - Capture Button Pulse & Auto-capture
    private func startCaptureButtonPulse() {
        captureButton.layer.removeAllAnimations()
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.12
        pulse.duration = 0.6
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        captureButton.layer.add(pulse, forKey: "pulse")
        
        // Also glow the shadow
        let glow = CABasicAnimation(keyPath: "shadowOpacity")
        glow.fromValue = 0.4
        glow.toValue = 1.0
        glow.duration = 0.6
        glow.autoreverses = true
        glow.repeatCount = .infinity
        captureButton.layer.add(glow, forKey: "glow")
    }
    
    private func stopCaptureButtonPulse() {
        captureButton.layer.removeAnimation(forKey: "pulse")
        captureButton.layer.removeAnimation(forKey: "glow")
    }
    
    private func startAutoCaptureCountdown() {
        autoCaptureCountdown = 10
        autoCaptureTimer?.invalidate()
        autoCaptureTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.autoCaptureCountdown -= 1
            if self.autoCaptureCountdown > 0 {
                let label = self.autoCaptureCountdown <= 3 ? "\(self.autoCaptureCountdown)..." : nil
                if let label = label {
                    DispatchQueue.main.async {
                        self.captureButton.setTitle("Take Photo (\(label))", for: .normal)
                    }
                }
            } else {
                self.autoCaptureTimer?.invalidate()
                self.autoCaptureTimer = nil
                self.captureReading()
            }
        }
    }
    
    private func cancelAutoCaptureTimer() {
        autoCaptureTimer?.invalidate()
        autoCaptureTimer = nil
        stopCaptureButtonPulse()
        captureButton.setTitle("Take Photo", for: .normal)
    }
    
    // MARK: - Capture & Vision
    @objc private func aiGuidanceTapped() {
        guard OpenAIService.shared.hasAPIKey() else {
            VoiceService.shared.speak("Please configure your Claude API key in Settings first.")
            showAPIKeyAlert()
            return
        }
        guard let photoOutput = photoOutput else {
            VoiceService.shared.speak("Camera not available.")
            return
        }
        currentCaptureMode = .behaviorGuidance
        aiGuidanceButton.isEnabled = false
        var config = aiGuidanceButton.configuration ?? UIButton.Configuration.plain()
        config.title = "…"
        aiGuidanceButton.configuration = config
        analyzingLabel.text = "Getting AI tip..."
        analyzingLabel.isHidden = false
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func captureReading() {
        // Check if API key is configured
        guard OpenAIService.shared.hasAPIKey() else {
            VoiceService.shared.speak("Please configure your Claude API key first. Go to home screen and tap Settings.")
            showAPIKeyAlert()
            return
        }
        
        guard let photoOutput = photoOutput else {
            VoiceService.shared.speak("Camera not available. Please enter the values manually.")
            showManualEntryAlert()
            return
        }
        
        cancelAutoCaptureTimer()
        currentCaptureMode = .bloodPressureReading
        captureButton.isEnabled = false
        captureButton.setTitle("Analyzing...", for: .normal)
        showAnalyzingState()
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        VoiceService.shared.speak("Capturing image. Please hold the camera steady.")
    }
    
    private func showAPIKeyAlert() {
        let alert = UIAlertController(
            title: "API Key Required",
            message: "Please configure your Claude (Anthropic) API key to use the AI vision feature.\n\nGo to Home screen → Settings",
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
                self?.captureButton.setTitle("Take Photo", for: .normal)
                self?.hideAnalyzingState()
                
                switch result {
                case .success(let optionalReading):
                    if let reading = optionalReading {
                        print("✅ [Vision] Extracted: \(reading.systolic)/\(reading.diastolic), Pulse: \(reading.pulse)")
                        self?.showConfirmReadingAlert(
                            systolic: reading.systolic,
                            diastolic: reading.diastolic,
                            pulse: reading.pulse
                        )
                    } else {
                        print("⚠️ [Vision] Could not parse values from image")
                        VoiceService.shared.speak("I couldn't read the numbers clearly. Please try again or enter manually.")
                        self?.showRetryOrManualAlert(error: "Could not parse blood pressure values from the image.")
                    }
                    
                case .failure(let error):
                    print("❌ [Vision] Failed: \(error.localizedDescription)")
                    VoiceService.shared.speak("Sorry, there was a problem reading the monitor. Please try again or enter manually.")
                    self?.showRetryOrManualAlert(error: error.localizedDescription)
                }
            }
        }
    }
    
    private func showConfirmReadingAlert(systolic: Int, diastolic: Int, pulse: Int) {
        VoiceService.shared.speak("I read \(systolic) over \(diastolic), pulse \(pulse). Is this correct?")
        
        let alert = UIAlertController(
            title: "Confirm Reading",
            message: "I detected:\n\n📊 Blood Pressure: \(systolic)/\(diastolic) mmHg\n❤️ Pulse: \(pulse) bpm\n\nIs this correct?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "✓ Correct, Save", style: .default) { [weak self] _ in
            VoiceService.shared.speak("Saving your result.")
            self?.handleMeasurementComplete(systolic: systolic, diastolic: diastolic, pulse: pulse, source: "vision")
        })
        
        alert.addAction(UIAlertAction(title: "✗ Wrong, Re-capture", style: .default) { _ in
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
        
        AudioRecorderService.shared.recordForDuration(10) { [weak self] audioURL in
            guard let audioURL = audioURL else {
                DispatchQueue.main.async {
                    VoiceService.shared.speak("Could not record audio. Please try manual entry.")
                }
                return
            }
            
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
                    
                    AudioRecorderService.shared.deleteRecording(at: audioURL)
                }
            }
        }
    }
    
    private func parseVoiceInput(_ text: String) {
        let prompt = """
        Extract blood pressure readings from this voice input: "\(text)"
        
        Return ONLY a JSON object: {"systolic": NUMBER, "diastolic": NUMBER, "pulse": NUMBER}
        If you can't find a value, use -1.
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
        
        print("✅ [MeasureVC] Measurement complete: \(reading.systolic)/\(reading.diastolic) mmHg, Pulse: \(reading.pulse)")
        
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
            if currentCaptureMode == .behaviorGuidance {
                resetAIGuidanceButton()
            } else {
                hideAnalyzingState()
                captureButton.isEnabled = true
                captureButton.setTitle("Take Photo", for: .normal)
                showManualEntryAlert()
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ [Camera] Could not get image data")
            if currentCaptureMode == .behaviorGuidance {
                resetAIGuidanceButton()
            } else {
                hideAnalyzingState()
                captureButton.isEnabled = true
                captureButton.setTitle("Take Photo", for: .normal)
                showManualEntryAlert()
            }
            return
        }
        
        if currentCaptureMode == .behaviorGuidance {
            currentCaptureMode = .bloodPressureReading
            print("📸 [Camera] Photo for behavior guidance, calling Claude...")
            OpenAIService.shared.analyzeMeasurementGuidance(image: image) { [weak self] result in
                DispatchQueue.main.async {
                    self?.resetAIGuidanceButton()
                    switch result {
                    case .success(let guidance):
                        let text = guidance.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !text.isEmpty {
                            VoiceService.shared.speak(text)
                        }
                    case .failure(let err):
                        VoiceService.shared.speak("Sorry, I couldn't get a tip right now. Try again.")
                        print("❌ [Guidance] \(err.localizedDescription)")
                    }
                }
            }
            return
        }
        
        print("📸 [Camera] Photo captured, sending to Vision API...")
        analyzeImageWithVision(image)
    }
    
    private func resetAIGuidanceButton() {
        analyzingLabel.isHidden = true
        aiGuidanceButton.isEnabled = true
        var config = aiGuidanceButton.configuration ?? UIButton.Configuration.plain()
        config.title = "AI Guidance"
        aiGuidanceButton.configuration = config
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate (for 5s auto guidance)
extension MeasureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        videoFrameCount += 1
        guard videoFrameCount % 15 == 0,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        DispatchQueue.main.async { [weak self] in
            self?.latestCaptureFrame = image
        }
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
    
    func updateUIViewController(_ uiViewController: MeasureViewController, context: Context) {}
}
#endif
