//
//  HomeViewController.swift
//  carelink
//
//  Home - Health Pad Main Screen with AI Voice Assistant
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 32, regular: 42, large: 48), weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.text = "Health Pad"
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 16, regular: 20, large: 22))
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        return label
    }()
    
    // MARK: - AI Voice Assistant Panel
    
    private let aiAssistantPanel: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 0.97, blue: 0.98, alpha: 1.0) // Subtle pink tint
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 0.2).cgColor
        return view
    }()
    
    // T-Mobile Pink: #E20074
    private let tMobilePink = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
    
    // Wave ripple circles
    private let waveContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let waveCircle1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 0.1)
        view.layer.cornerRadius = 50
        return view
    }()
    
    private let waveCircle2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 0.2)
        view.layer.cornerRadius = 40
        return view
    }()
    
    private let waveCircle3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 0.35)
        view.layer.cornerRadius = 30
        return view
    }()
    
    private let micButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        button.layer.cornerRadius = 35
        button.setTitle("", for: .normal)
        button.layer.shadowColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 0.4).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 8
        return button
    }()
    
    private let aiGreetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 20, regular: 26, large: 30), weight: .semibold)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        label.text = "How can I help you today?"
        label.textAlignment = .center
        return label
    }()
    
    private let aiSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 14, regular: 16, large: 18))
        label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
        label.text = "Tap to start talking"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let apiStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 12, regular: 14, large: 16))
        label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        label.text = ""
        label.textAlignment = .center
        return label
    }()
    
    private let configureAPIButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0), for: .normal)
        return button
    }()
    
    // Buttons
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
    
    // Voice recording state
    private var isRecording = false
    private var isAnalyzing = false
    private var waveAnimationTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        updateDateTime()
        updateAPIStatus()
        
        #if DEBUG
        print("\n🏠 [HomeVC] ========== App Launch ==========")
        DebugHelper.printSavedData()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDateTime()
        updateAPIStatus()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        
        // Add all subviews
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(dateLabel)
        
        // AI Assistant Panel with wave animation
        view.addSubview(aiAssistantPanel)
        aiAssistantPanel.addSubview(waveContainer)
        waveContainer.addSubview(waveCircle1)
        waveContainer.addSubview(waveCircle2)
        waveContainer.addSubview(waveCircle3)
        waveContainer.addSubview(micButton)
        aiAssistantPanel.addSubview(aiGreetingLabel)
        aiAssistantPanel.addSubview(aiSubtitleLabel)
        aiAssistantPanel.addSubview(apiStatusLabel)
        aiAssistantPanel.addSubview(configureAPIButton)
        
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
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        aiAssistantPanel.translatesAutoresizingMaskIntoConstraints = false
        waveContainer.translatesAutoresizingMaskIntoConstraints = false
        waveCircle1.translatesAutoresizingMaskIntoConstraints = false
        waveCircle2.translatesAutoresizingMaskIntoConstraints = false
        waveCircle3.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false
        aiGreetingLabel.translatesAutoresizingMaskIntoConstraints = false
        aiSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        apiStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        configureAPIButton.translatesAutoresizingMaskIntoConstraints = false
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
        
        let padding: CGFloat = UIScreen.adaptivePadding
        let verticalSpacing: CGFloat = UIScreen.adaptiveVerticalSpacing
        let headerHeight: CGFloat = UIScreen.adaptiveSpacing(small: 80, regular: 100, large: 120)
        let panelHeight: CGFloat = UIScreen.adaptiveSpacing(small: 220, regular: 260, large: 300)
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
            
            // AI Assistant Panel
            aiAssistantPanel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: verticalSpacing),
            aiAssistantPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            aiAssistantPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            aiAssistantPanel.heightAnchor.constraint(equalToConstant: panelHeight),
            
            // Wave container (centered at top)
            waveContainer.centerXAnchor.constraint(equalTo: aiAssistantPanel.centerXAnchor),
            waveContainer.topAnchor.constraint(equalTo: aiAssistantPanel.topAnchor, constant: 20),
            waveContainer.widthAnchor.constraint(equalToConstant: 100),
            waveContainer.heightAnchor.constraint(equalToConstant: 100),
            
            // Wave circles (outer to inner)
            waveCircle1.centerXAnchor.constraint(equalTo: waveContainer.centerXAnchor),
            waveCircle1.centerYAnchor.constraint(equalTo: waveContainer.centerYAnchor),
            waveCircle1.widthAnchor.constraint(equalToConstant: 100),
            waveCircle1.heightAnchor.constraint(equalToConstant: 100),
            
            waveCircle2.centerXAnchor.constraint(equalTo: waveContainer.centerXAnchor),
            waveCircle2.centerYAnchor.constraint(equalTo: waveContainer.centerYAnchor),
            waveCircle2.widthAnchor.constraint(equalToConstant: 80),
            waveCircle2.heightAnchor.constraint(equalToConstant: 80),
            
            waveCircle3.centerXAnchor.constraint(equalTo: waveContainer.centerXAnchor),
            waveCircle3.centerYAnchor.constraint(equalTo: waveContainer.centerYAnchor),
            waveCircle3.widthAnchor.constraint(equalToConstant: 60),
            waveCircle3.heightAnchor.constraint(equalToConstant: 60),
            
            // Mic button (center)
            micButton.centerXAnchor.constraint(equalTo: waveContainer.centerXAnchor),
            micButton.centerYAnchor.constraint(equalTo: waveContainer.centerYAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 70),
            micButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Greeting label
            aiGreetingLabel.centerXAnchor.constraint(equalTo: aiAssistantPanel.centerXAnchor),
            aiGreetingLabel.topAnchor.constraint(equalTo: waveContainer.bottomAnchor, constant: 16),
            aiGreetingLabel.leadingAnchor.constraint(equalTo: aiAssistantPanel.leadingAnchor, constant: 20),
            aiGreetingLabel.trailingAnchor.constraint(equalTo: aiAssistantPanel.trailingAnchor, constant: -20),
            
            // Subtitle label
            aiSubtitleLabel.centerXAnchor.constraint(equalTo: aiAssistantPanel.centerXAnchor),
            aiSubtitleLabel.topAnchor.constraint(equalTo: aiGreetingLabel.bottomAnchor, constant: 8),
            aiSubtitleLabel.leadingAnchor.constraint(equalTo: aiAssistantPanel.leadingAnchor, constant: 20),
            aiSubtitleLabel.trailingAnchor.constraint(equalTo: aiAssistantPanel.trailingAnchor, constant: -20),
            
            // API status
            apiStatusLabel.centerXAnchor.constraint(equalTo: aiAssistantPanel.centerXAnchor),
            apiStatusLabel.topAnchor.constraint(equalTo: aiSubtitleLabel.bottomAnchor, constant: 12),
            
            // Configure button
            configureAPIButton.centerXAnchor.constraint(equalTo: aiAssistantPanel.centerXAnchor),
            configureAPIButton.topAnchor.constraint(equalTo: apiStatusLabel.bottomAnchor, constant: 4),
            
            // Buttons Container
            buttonsContainer.topAnchor.constraint(equalTo: aiAssistantPanel.bottomAnchor, constant: verticalSpacing),
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
        micButton.addTarget(self, action: #selector(micButtonTapped), for: .touchUpInside)
        configureAPIButton.addTarget(self, action: #selector(configureAPITapped), for: .touchUpInside)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(measurementCompleted(_:)),
            name: .measurementCompleted,
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
    
    private func updateAPIStatus() {
        if OpenAIService.shared.hasAPIKey() {
            apiStatusLabel.text = OpenAIService.shared.hasOpenAIKey() ? "AI + Voice Ready" : "AI Ready"
            apiStatusLabel.textColor = UIColor(red: 0.2, green: 0.7, blue: 0.4, alpha: 1.0)
            micButton.isEnabled = true
            micButton.alpha = 1.0
            configureAPIButton.setTitle("Settings", for: .normal)
        } else {
            apiStatusLabel.text = "API Key Required"
            apiStatusLabel.textColor = UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1.0)
            micButton.isEnabled = true // Still allow tap to prompt setup
            micButton.alpha = 0.7
            configureAPIButton.setTitle("Configure API Key", for: .normal)
        }
    }
    
    // MARK: - Wave Animation
    private func startWaveAnimation() {
        stopWaveAnimation()
        
        // Animate waves
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.waveCircle1.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.waveCircle1.alpha = 0.3
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.waveCircle2.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            self.waveCircle2.alpha = 0.5
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.waveCircle3.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.waveCircle3.alpha = 0.7
        }
    }
    
    private func stopWaveAnimation() {
        waveCircle1.layer.removeAllAnimations()
        waveCircle2.layer.removeAllAnimations()
        waveCircle3.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.3) {
            self.waveCircle1.transform = .identity
            self.waveCircle2.transform = .identity
            self.waveCircle3.transform = .identity
            self.waveCircle1.alpha = 1.0
            self.waveCircle2.alpha = 1.0
            self.waveCircle3.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    @objc private func measureTapped() {
        tabBarController?.selectedIndex = 1
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func historyTapped() {
        tabBarController?.selectedIndex = 2
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func voiceToggled() {
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
        // Update UI if needed
    }
    
    // MARK: - AI Voice Assistant Actions
    @objc private func micButtonTapped() {
        guard OpenAIService.shared.hasAPIKey() else {
            VoiceService.shared.speak("Please add your Claude API key first.")
            configureAPITapped()
            return
        }
        // Voice input uses OpenAI Whisper for speech-to-text.
        if !OpenAIService.shared.hasOpenAIKey() {
            let alert = UIAlertController(
                title: "Voice input needs OpenAI key",
                message: "To talk by voice, add an OpenAI API key (used to turn your speech into text). Claude key is for answers.\n\nTap Settings to add both keys.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { [weak self] _ in
                self?.configureAPITapped()
            })
            present(alert, animated: true)
            return
        }
        
        if isAnalyzing {
            return
        }
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        isRecording = true
        
        // Update UI - darker pink when recording
        micButton.backgroundColor = UIColor(red: 0.7, green: 0, blue: 0.35, alpha: 1.0)
        aiGreetingLabel.text = "Listening..."
        aiSubtitleLabel.text = "Tap again to stop"
        
        // Start wave animation
        startWaveAnimation()
        
        VoiceService.shared.speak("I'm listening")
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Start recording
        AudioRecorderService.shared.startRecording { [weak self] audioURL in
            guard let audioURL = audioURL else {
                DispatchQueue.main.async {
                    self?.resetMicButton()
                    VoiceService.shared.speak("Sorry, I couldn't record. Please try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.processRecording(audioURL: audioURL)
            }
        }
    }
    
    private func stopRecording() {
        isRecording = false
        isAnalyzing = true
        micButton.isEnabled = false
        
        // Update UI - gray while processing
        micButton.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        aiGreetingLabel.text = "Processing..."
        aiSubtitleLabel.text = "Please wait"
        
        AudioRecorderService.shared.stopRecording()
    }
    
    private func processRecording(audioURL: URL) {
        stopWaveAnimation()
        
        // Transcribe with Whisper
        OpenAIService.shared.transcribeAudio(audioURL: audioURL) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    print("🎤 [HomeVC] Transcribed: \(text)")
                    self?.askAI(question: text)
                    
                case .failure(let error):
                    print("❌ [HomeVC] Transcription error: \(error)")
                    self?.resetMicButton()
                    let msg = (error as NSError).domain == "Whisper" ? "Voice input needs an OpenAI API key. Add it in Settings." : "Sorry, I couldn't hear clearly. Please try again."
                    VoiceService.shared.speak(msg)
                    self?.aiSubtitleLabel.text = error.localizedDescription
                }
                AudioRecorderService.shared.deleteRecording(at: audioURL)
            }
        }
    }
    
    private func askAI(question: String) {
        aiSubtitleLabel.text = "You: \"\(question)\""
        
        let recentReadings = BloodPressureReading.load().prefix(5).map { $0 }
        
        OpenAIService.shared.chatCompletion(
            userMessage: question,
            recentReadings: Array(recentReadings)
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.resetMicButton()
                
                switch result {
                case .success(let response):
                    print("🤖 [HomeVC] AI Response: \(response)")
                    self?.aiGreetingLabel.text = response
                    self?.aiSubtitleLabel.text = "Tap to ask another question"
                    VoiceService.shared.speak(response)
                    
                case .failure(let error):
                    print("❌ [HomeVC] AI error: \(error)")
                    self?.aiGreetingLabel.text = "How can I help you today?"
                    let msg = error.localizedDescription
                    if msg.lowercased().contains("model") || msg.contains("404") || msg.contains("invalid") {
                        self?.aiSubtitleLabel.text = "API or model error. Check Settings → Claude key and try again."
                    } else {
                        self?.aiSubtitleLabel.text = "Error: \(msg)"
                    }
                    VoiceService.shared.speak("Sorry, I had trouble answering. Please try again.")
                }
            }
        }
    }
    
    private func resetMicButton() {
        isRecording = false
        isAnalyzing = false
        micButton.isEnabled = true
        stopWaveAnimation()
        micButton.setTitle("", for: .normal)
        micButton.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        
        if aiGreetingLabel.text == "Listening..." || aiGreetingLabel.text == "Processing..." {
            aiGreetingLabel.text = "How can I help you today?"
            aiSubtitleLabel.text = "Tap to start talking"
        }
    }
    
    @objc private func configureAPITapped() {
        let alert = UIAlertController(
            title: "API Keys",
            message: "• Claude key (required): answers your questions + reads BP from camera.\n• OpenAI key (required for voice): turns your speech into text.\n\nGet Claude key: console.anthropic.com\nGet OpenAI key: platform.openai.com",
            preferredStyle: .alert
        )
        
        // Claude (Anthropic) – required
        alert.addTextField { textField in
            textField.placeholder = "Claude API key (sk-ant-...)"
            textField.isSecureTextEntry = true
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            if OpenAIService.shared.hasAPIKey() {
                textField.text = OpenAIService.shared.getAPIKey()
            }
        }
        
        // OpenAI – optional, for voice
        alert.addTextField { textField in
            textField.placeholder = "OpenAI key (optional, for voice)"
            textField.isSecureTextEntry = true
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            if OpenAIService.shared.hasOpenAIKey() {
                textField.text = OpenAIService.shared.getOpenAIKey()
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            let claudeKey = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let openaiKey = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            guard !claudeKey.isEmpty else {
                VoiceService.shared.speak("Please enter your Claude API key.")
                return
            }
            
            OpenAIService.shared.setAPIKey(claudeKey)
            if !openaiKey.isEmpty {
                OpenAIService.shared.setOpenAIKey(openaiKey)
            }
            self?.updateAPIStatus()
            
            VoiceService.shared.speak("API key saved. I'm ready to help!")
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        })
        
        if OpenAIService.shared.hasAPIKey() {
            alert.addAction(UIAlertAction(title: "Clear Keys", style: .destructive) { [weak self] _ in
                OpenAIService.shared.clearAPIKey()
                self?.updateAPIStatus()
            })
        }
        
        present(alert, animated: true)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
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
    
    func updateUIViewController(_ uiViewController: HomeViewController, context: Context) {}
}
#endif
