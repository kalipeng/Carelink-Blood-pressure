//
//  ResultViewController.swift
//  HealthPad
//
//  Measurement Result Display Screen
//

import UIKit

class ResultViewController: UIViewController {
    
    // MARK: - Properties
    private let reading: BloodPressureReading
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "← Back to Home"
        config.baseForegroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        config.background.backgroundColor = .white
        config.background.cornerRadius = 12
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        return button
    }()
    
    private let resultTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Latest Reading"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        label.numberOfLines = 0
        return label
    }()
    
    // 🔍 Data source label
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        label.textAlignment = .right
        return label
    }()
    
    // ⚠️ Simulated data warning banner
    private let simulatedWarningBanner: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0).cgColor
        view.isHidden = true  // 默认隐藏
        return view
    }()
    
    private let warningIconLabel: UILabel = {
        let label = UILabel()
        label.text = "⚠️"
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private let warningTextLabel: UILabel = {
        let label = UILabel()
        label.text = "This is Simulated Data (For Testing)\nPlease connect blood pressure monitor for real data"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.6, green: 0.3, blue: 0.0, alpha: 1.0)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let cardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 24
        return stack
    }()
    
    private let statusBanner: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let statusIconView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 40
        return view
    }()
    
    private let statusIconLabel: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let statusTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        return label
    }()
    
    private let statusMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initialization
    init(reading: BloodPressureReading) {
        self.reading = reading
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayResult()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(simulatedWarningBanner)
        simulatedWarningBanner.addSubview(warningIconLabel)
        simulatedWarningBanner.addSubview(warningTextLabel)
        contentView.addSubview(resultTitleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(cardsStackView)
        contentView.addSubview(statusBanner)
        
        statusBanner.addSubview(statusIconView)
        statusIconView.addSubview(statusIconLabel)
        statusBanner.addSubview(statusTitleLabel)
        statusBanner.addSubview(statusMessageLabel)
        
        setupCards()
        setupConstraints()
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    private func setupCards() {
        // Systolic card
        let systolicCard = createMeasurementCard(
            label: "Systolic",
            value: "\(reading.systolic)",
            unit: "mmHg",
            icon: "↑"
        )
        
        // Diastolic card
        let diastolicCard = createMeasurementCard(
            label: "Diastolic",
            value: "\(reading.diastolic)",
            unit: "mmHg",
            icon: "↓"
        )
        
        // Heart Rate card
        let heartRateCard = createMeasurementCard(
            label: "Heart Rate",
            value: "\(reading.pulse)",
            unit: "beats/min",
            icon: "❤️"
        )
        
        cardsStackView.addArrangedSubview(systolicCard)
        cardsStackView.addArrangedSubview(diastolicCard)
        cardsStackView.addArrangedSubview(heartRateCard)
    }
    
    private func createMeasurementCard(label: String, value: String, unit: String, icon: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 2
        card.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0).cgColor
        
        let labelText = UILabel()
        labelText.text = label
        labelText.font = .systemFont(ofSize: 24, weight: .medium)
        labelText.textColor = UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1.0)
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 28)
        iconLabel.textColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 96, weight: .bold)
        valueLabel.textColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5
        
        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.font = .systemFont(ofSize: 20)
        unitLabel.textColor = UIColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 1.0)
        unitLabel.textAlignment = .center
        
        card.addSubview(labelText)
        card.addSubview(iconLabel)
        card.addSubview(valueLabel)
        card.addSubview(unitLabel)
        
        labelText.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelText.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            labelText.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            iconLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            
            valueLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: 10),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16),
            
            unitLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            unitLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
        ])
        
        return card
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        simulatedWarningBanner.translatesAutoresizingMaskIntoConstraints = false
        warningIconLabel.translatesAutoresizingMaskIntoConstraints = false
        warningTextLabel.translatesAutoresizingMaskIntoConstraints = false
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        cardsStackView.translatesAutoresizingMaskIntoConstraints = false
        statusBanner.translatesAutoresizingMaskIntoConstraints = false
        statusIconView.translatesAutoresizingMaskIntoConstraints = false
        statusIconLabel.translatesAutoresizingMaskIntoConstraints = false
        statusTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            // ⚠️ Warning banner (shown for simulated data)
            simulatedWarningBanner.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            simulatedWarningBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            simulatedWarningBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            simulatedWarningBanner.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            warningIconLabel.leadingAnchor.constraint(equalTo: simulatedWarningBanner.leadingAnchor, constant: 20),
            warningIconLabel.centerYAnchor.constraint(equalTo: simulatedWarningBanner.centerYAnchor),
            warningIconLabel.widthAnchor.constraint(equalToConstant: 50),
            
            warningTextLabel.leadingAnchor.constraint(equalTo: warningIconLabel.trailingAnchor, constant: 12),
            warningTextLabel.trailingAnchor.constraint(equalTo: simulatedWarningBanner.trailingAnchor, constant: -20),
            warningTextLabel.centerYAnchor.constraint(equalTo: simulatedWarningBanner.centerYAnchor),
            
            resultTitleLabel.topAnchor.constraint(equalTo: simulatedWarningBanner.bottomAnchor, constant: 32),
            resultTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            timeLabel.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: sourceLabel.leadingAnchor, constant: -20),
            
            sourceLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            sourceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            cardsStackView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 32),
            cardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            cardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            cardsStackView.heightAnchor.constraint(equalToConstant: 300),
            
            statusBanner.topAnchor.constraint(equalTo: cardsStackView.bottomAnchor, constant: 30),
            statusBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            statusBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            statusBanner.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            statusBanner.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            
            statusIconView.leadingAnchor.constraint(equalTo: statusBanner.leadingAnchor, constant: 40),
            statusIconView.centerYAnchor.constraint(equalTo: statusBanner.centerYAnchor),
            statusIconView.widthAnchor.constraint(equalToConstant: 80),
            statusIconView.heightAnchor.constraint(equalToConstant: 80),
            
            statusIconLabel.centerXAnchor.constraint(equalTo: statusIconView.centerXAnchor),
            statusIconLabel.centerYAnchor.constraint(equalTo: statusIconView.centerYAnchor),
            
            statusTitleLabel.topAnchor.constraint(equalTo: statusBanner.topAnchor, constant: 32),
            statusTitleLabel.leadingAnchor.constraint(equalTo: statusIconView.trailingAnchor, constant: 24),
            statusTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusBanner.trailingAnchor, constant: -40),
            
            statusMessageLabel.topAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor, constant: 8),
            statusMessageLabel.leadingAnchor.constraint(equalTo: statusIconView.trailingAnchor, constant: 24),
            statusMessageLabel.trailingAnchor.constraint(equalTo: statusBanner.trailingAnchor, constant: -40),
            statusMessageLabel.bottomAnchor.constraint(lessThanOrEqualTo: statusBanner.bottomAnchor, constant: -32),
        ])
    }
    
    // MARK: - Display Result
    private func displayResult() {
        // 🔍 Full timestamp display
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy  HH:mm:ss"
        let fullTimeString = formatter.string(from: reading.timestamp)
        
        // Calculate time difference
        let timeAgo = getTimeAgoString(from: reading.timestamp)
        
        timeLabel.text = "\(fullTimeString)\n\(timeAgo)"
        
        // 🔍 Data source display
        let sourceEmoji: String
        let sourceText: String
        
        switch reading.source {
        case "bluetooth":
            sourceEmoji = "📱"
            sourceText = "Real Measurement"
        case "simulated":
            sourceEmoji = "🧪"
            sourceText = "Simulated Data"
        case "manual":
            sourceEmoji = "✍️"
            sourceText = "Manual Input"
        default:
            sourceEmoji = "❓"
            sourceText = "Unknown Source"
        }
        
        sourceLabel.text = "\(sourceEmoji) \(sourceText)"
        
        // ⚠️ If simulated data, show warning banner
        if reading.source == "simulated" {
            simulatedWarningBanner.isHidden = false
            print("\n⚠️⚠️⚠️ [ResultVC] WARNING: This is simulated data! ⚠️⚠️⚠️")
        } else {
            simulatedWarningBanner.isHidden = true
        }
        
        // 🔍 Print debug information
        print("\n📊 [ResultVC] ========== Displaying Measurement Result ==========")
        print("   ID: \(reading.id.uuidString.prefix(8))...")
        print("   Values: \(reading.systolic)/\(reading.diastolic) mmHg")
        print("   Pulse: \(reading.pulse) bpm")
        print("   Time: \(fullTimeString)")
        print("   Source: \(reading.source) (\(sourceText))")
        print("   Category: \(reading.category)")
        
        if reading.source == "simulated" {
            print("   ⚠️ Note: This is simulated data, not a real measurement!")
        }
        
        print("📊 [ResultVC] ========================================\n")
        
        // Update status banner based on category
        let category = reading.category
        statusTitleLabel.text = getCategoryTitle(category)
        statusMessageLabel.text = reading.recommendation
        
        // Set colors based on category
        let (backgroundColor, borderColor, iconColor, titleColor) = getCategoryColors(category)
        
        statusBanner.backgroundColor = backgroundColor
        statusBanner.layer.borderWidth = 2
        statusBanner.layer.borderColor = borderColor.cgColor
        
        statusIconView.backgroundColor = iconColor
        statusTitleLabel.textColor = titleColor
        
        // Add animation
        statusBanner.alpha = 0
        statusBanner.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
            self.statusBanner.alpha = 1
            self.statusBanner.transform = .identity
        }
    }
    
    private func getCategoryTitle(_ category: String) -> String {
        switch category {
        case "Normal", "正常":
            return "Within Normal Range"
        case "Slightly Elevated", "正常偏高":
            return "Slightly Elevated"
        case "Pre-Hypertension", "高血压前期":
            return "Pre-Hypertension"
        case "Hypertension Stage 1", "高血压1期":
            return "Hypertension Stage 1"
        case "Hypertension Stage 2", "高血压2期":
            return "Hypertension Stage 2"
        case "Hypertensive Crisis", "高血压危象":
            return "⚠️ Hypertensive Crisis"
        default:
            return category
        }
    }
    
    private func getCategoryColors(_ category: String) -> (UIColor, UIColor, UIColor, UIColor) {
        switch category {
        case "正常", "Normal":
            // Green - Normal
            return (
                UIColor(red: 0.91, green: 0.96, blue: 0.91, alpha: 1.0), // background
                UIColor(red: 0.51, green: 0.78, blue: 0.52, alpha: 1.0), // border
                UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0), // icon
                UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1.0)  // title
            )
        case "正常偏高", "Slightly Elevated", "高血压前期", "Pre-Hypertension":
            // Orange - Warning
            return (
                UIColor(red: 1.0, green: 0.95, blue: 0.88, alpha: 1.0),
                UIColor(red: 1.0, green: 0.72, blue: 0.30, alpha: 1.0),
                UIColor(red: 1.0, green: 0.60, blue: 0.00, alpha: 1.0),
                UIColor(red: 0.90, green: 0.32, blue: 0.00, alpha: 1.0)
            )
        default:
            // Red - Danger
            return (
                UIColor(red: 1.0, green: 0.92, blue: 0.93, alpha: 1.0),
                UIColor(red: 0.90, green: 0.45, blue: 0.45, alpha: 1.0),
                UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0),
                UIColor(red: 0.78, green: 0.16, blue: 0.16, alpha: 1.0)
            )
        }
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        dismiss(animated: true) { [weak self] in
            // Return to home
            self?.view.window?.rootViewController?.children.first?.tabBarController?.selectedIndex = 0
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // MARK: - Helper Methods
    private func getTimeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 0 {
            return "Just now" // Future time (clock out of sync)
        } else if timeInterval < 60 {
            return "Just now (< 1 minute)"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}
