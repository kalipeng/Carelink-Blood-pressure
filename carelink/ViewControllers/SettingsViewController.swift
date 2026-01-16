//
//  SettingsViewController.swift
//  HealthPad
//
//  设置界面
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "设置"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "语音提示"
                let toggle = UISwitch()
                toggle.isOn = UserDefaults.standard.bool(forKey: "voiceEnabled")
                toggle.addTarget(self, action: #selector(voiceToggled(_:)), for: .valueChanged)
                cell.accessoryView = toggle
            } else {
                cell.textLabel?.text = "设备连接"
                cell.detailTextLabel?.text = iHealthService.shared.isConnected ? "已连接" : "未连接"
            }
        } else {
            cell.textLabel?.text = "关于"
            cell.detailTextLabel?.text = "版本 1.0"
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    @objc private func voiceToggled(_ sender: UISwitch) {
        VoiceService.shared.isEnabled = sender.isOn
    }
}
