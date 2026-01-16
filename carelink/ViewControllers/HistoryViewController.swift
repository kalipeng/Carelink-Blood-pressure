//
//  HistoryViewController.swift
//  HealthPad
//
//  历史记录界面
//

import UIKit
import SwiftUI

class HistoryViewController: UIViewController {
    
    private var readings: [BloodPressureReading] = []
    
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
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Measurement History"
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(ModernHistoryCell.self, forCellReuseIdentifier: "ModernHistoryCell")
        table.rowHeight = 140
        return table
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No measurements yet\nStart your first measurement"
        label.font = .systemFont(ofSize: 24)
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
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupConstraints()
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            
            headerLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 60),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func loadData() {
        readings = BloodPressureReading.load()
        tableView.reloadData()
        
        emptyStateLabel.isHidden = !readings.isEmpty
        tableView.isHidden = readings.isEmpty
    }
    
    @objc private func backTapped() {
        tabBarController?.selectedIndex = 0
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernHistoryCell", for: indexPath) as! ModernHistoryCell
        cell.configure(with: readings[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show detail view
        let reading = readings[indexPath.row]
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
        label.font = .systemFont(ofSize: 42, weight: .bold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
        return label
    }()
    
    private let categoryBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
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
    
    func configure(with reading: BloodPressureReading) {
        valueLabel.text = reading.formattedValue
        valueLabel.textColor = reading.categoryColor
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = formatter.string(from: reading.timestamp)
        
        formatter.dateFormat = "hh:mm a"
        timeLabel.text = formatter.string(from: reading.timestamp)
        
        categoryLabel.text = getCategoryEnglish(reading.category)
        categoryBadge.backgroundColor = reading.categoryColor
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
#if DEBUG
struct HistoryViewController_Previews: PreviewProvider {
    static var previews: some View {
        HistoryViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct HistoryViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HistoryViewController {
        return HistoryViewController()
    }
    
    func updateUIViewController(_ uiViewController: HistoryViewController, context: Context) {
        // 更新视图控制器（如果需要）
    }
}
#endif
