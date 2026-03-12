//
//  HistoryViewController.swift
//  HealthPad
//
//  History screen
//

import UIKit
import SwiftUI

class HistoryViewController: UIViewController {
    
    private var readings: [BloodPressureReading] = []
    /// Grouped by calendar day (newest first). Each element: (startOfDay, readings for that day)
    private var sections: [(date: Date, readings: [BloodPressureReading])] = []
    
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
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Measurement History"
        // 📱 Adaptive font size: 28pt (small) -> 36pt (regular) -> 40pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 28, regular: 36, large: 40), weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(ModernHistoryCell.self, forCellReuseIdentifier: "ModernHistoryCell")
        // 📱 Adaptive row height: 110pt (small) -> 140pt (regular) -> 160pt (large)
        table.rowHeight = UIScreen.adaptiveSpacing(small: 110, regular: 140, large: 160)
        return table
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.text = "We recommend up to 5 readings per day for better tracking."
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 14, regular: 16, large: 18))
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        label.numberOfLines = 0
        return label
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No measurements yet\nStart your first measurement"
        // 📱 Adaptive font size: 18pt (small) -> 24pt (regular) -> 26pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 18, regular: 24, large: 26))
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        view.addSubview(backButton)
        view.addSubview(headerLabel)
        view.addSubview(tipLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderTopPadding = 8
        
        setupConstraints()
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            
            headerLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 60),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            
            tipLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            tipLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tipLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            tableView.topAnchor.constraint(equalTo: tipLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func loadData() {
        print("📖 [HistoryVC] Loading history...")
        readings = BloodPressureReading.load()
        print("📊 [HistoryVC] Loaded \(readings.count) readings")
        
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: readings) { calendar.startOfDay(for: $0.timestamp) }
        sections = grouped.sorted { $0.key > $1.key }.map { (date: $0.key, readings: $0.value.sorted { $0.timestamp > $1.timestamp }) }
        
        tableView.reloadData()
        
        emptyStateLabel.isHidden = !readings.isEmpty
        tableView.isHidden = readings.isEmpty
        tipLabel.isHidden = readings.isEmpty
    }
    
    @objc private func backTapped() {
        tabBarController?.selectedIndex = 0
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dayReadings = sections[section].readings
        let hasAvg = dayReadings.count >= 2
        return dayReadings.count + (hasAvg ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let label = UILabel()
        label.text = "  \(formatter.string(from: sections[section].date))"
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 16, regular: 18, large: 20), weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernHistoryCell", for: indexPath) as! ModernHistoryCell
        let dayReadings = sections[indexPath.section].readings
        let hasAvg = dayReadings.count >= 2
        if hasAvg && indexPath.row == dayReadings.count {
            let avgSys = dayReadings.map(\.systolic).reduce(0, +) / dayReadings.count
            let avgDia = dayReadings.map(\.diastolic).reduce(0, +) / dayReadings.count
            let avgPul = dayReadings.map(\.pulse).reduce(0, +) / dayReadings.count
            cell.configureAsDailyAverage(systolic: avgSys, diastolic: avgDia, pulse: avgPul, count: dayReadings.count)
        } else {
            cell.configure(with: dayReadings[indexPath.row], showTime: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dayReadings = sections[indexPath.section].readings
        let hasAvg = dayReadings.count >= 2
        if hasAvg && indexPath.row == dayReadings.count { return }
        let reading = dayReadings[indexPath.row]
        let resultVC = ResultViewController(reading: reading)
        resultVC.modalPresentationStyle = .fullScreen
        present(resultVC, animated: true)
    }
}

// MARK: - Modern History Cell
class ModernHistoryCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        // 📱 Adaptive font size: 32pt (small) -> 42pt (regular) -> 48pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 32, regular: 42, large: 48), weight: .bold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        // 📱 Adaptive font size: 15pt (small) -> 18pt (regular) -> 20pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 15, regular: 18, large: 20))
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        // 📱 Adaptive font size: 15pt (small) -> 18pt (regular) -> 20pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 15, regular: 18, large: 20))
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        return label
    }()
    
    private let categoryBadge: UIView = {
        let view = UIView()
        // 📱 Adaptive corner radius: 10pt (small) -> 12pt (regular) -> 14pt (large)
        view.layer.cornerRadius = UIScreen.adaptiveSpacing(small: 10, regular: 12, large: 14)
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        // 📱 Adaptive font size: 14pt (small) -> 16pt (regular) -> 18pt (large)
        label.font = .systemFont(ofSize: UIScreen.adaptiveFont(small: 14, regular: 16, large: 18), weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(categoryBadge)
        categoryBadge.addSubview(categoryLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryBadge.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            categoryBadge.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 12),
            categoryBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            categoryBadge.heightAnchor.constraint(equalToConstant: 32),
            categoryBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            categoryLabel.centerXAnchor.constraint(equalTo: categoryBadge.centerXAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: categoryBadge.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryBadge.leadingAnchor, constant: 12),
            categoryLabel.trailingAnchor.constraint(equalTo: categoryBadge.trailingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
        ])
    }
    
    func configure(with reading: BloodPressureReading, showTime: Bool = false) {
        valueLabel.text = reading.formattedValue
        valueLabel.textColor = reading.categoryColor
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let timeString = formatter.string(from: reading.timestamp)
        
        let sourceEmoji: String
        switch reading.source {
        case "bluetooth": sourceEmoji = "📱"
        case "simulated": sourceEmoji = "🧪"
        case "manual": sourceEmoji = "✍️"
        default: sourceEmoji = "❓"
        }
        
        if showTime {
            dateLabel.text = ""
            timeLabel.text = "\(sourceEmoji) \(timeString)"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
            dateLabel.text = formatter.string(from: reading.timestamp)
            timeLabel.text = "\(sourceEmoji) \(timeString)"
        }
        
        categoryLabel.text = getCategoryEnglish(reading.category)
        categoryBadge.backgroundColor = reading.categoryColor
    }
    
    func configureAsDailyAverage(systolic: Int, diastolic: Int, pulse: Int, count: Int) {
        valueLabel.text = "\(systolic)/\(diastolic)"
        valueLabel.textColor = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
        dateLabel.text = ""
        timeLabel.text = "Daily avg (\(count) readings)"
        categoryLabel.text = "Avg"
        categoryBadge.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
    }
    
    private func getCategoryEnglish(_ category: String) -> String {
        switch category {
        case "正常":
            return "Normal"
        case "正常偏高":
            return "Elevated"
        case "高血压前期":
            return "Pre-Hypertension"
        case "高血压1期":
            return "Stage 1"
        case "高血压2期":
            return "Stage 2"
        case "高血压危象":
            return "Crisis"
        default:
            return category
        }
    }
}

// MARK: - SwiftUI Preview
// Preview only in simulator to avoid "Failed to install preview host" on device.
// Run the app with ⌘R for device testing.
#if DEBUG && targetEnvironment(simulator)
struct HistoryViewController_Previews: PreviewProvider {
    static var previews: some View {
        HistoryViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (M5)"))
    }
}

struct HistoryViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HistoryViewController {
        return HistoryViewController()
    }
    
    func updateUIViewController(_ uiViewController: HistoryViewController, context: Context) {
        // Update view controller if needed
    }
}
#endif
