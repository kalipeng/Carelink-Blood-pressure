//
//  SettingsViewController.swift
//  HealthPad
//
//  设置界面
//

import UIKit
import AVFoundation

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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 3 }
        if section == 1 { return 2 }  // API URL, Patient ID
        return 1  // About
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 { return "Firebase / API" }
        return nil
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
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "语音选择"
                cell.detailTextLabel?.text = VoiceService.shared.currentVoiceDisplayName
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = "设备连接"
                cell.detailTextLabel?.text = iHealthService.shared.isConnected ? "已连接" : "未连接"
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "API 地址"
                cell.detailTextLabel?.text = CloudSyncService.shared.baseURL
                cell.detailTextLabel?.numberOfLines = 2
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = "患者 ID"
                cell.detailTextLabel?.text = CloudSyncService.shared.patientId
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            cell.textLabel?.text = "关于"
            cell.detailTextLabel?.text = "版本 1.0"
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 1 {
            let vc = VoiceSelectionViewController()
            vc.onSelect = { [weak self] in self?.tableView.reloadData() }
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 0 {
            showEditAlert(title: "API 地址", message: "CareLink 临床看板后端地址", current: CloudSyncService.shared.baseURL, placeholder: "https://carelink-clinician-dashboard-hdld.vercel.app") { [weak self] newValue in
                if let v = newValue, !v.isEmpty { CloudSyncService.shared.baseURL = v.trimmingCharacters(in: .whitespacesAndNewlines) }
                self?.tableView.reloadData()
            }
        } else if indexPath.section == 1 && indexPath.row == 1 {
            showEditAlert(title: "患者 ID", message: "API 必填，例如 P-2025-001", current: CloudSyncService.shared.patientId, placeholder: "P-2025-001") { [weak self] newValue in
                if let v = newValue, !v.isEmpty { CloudSyncService.shared.patientId = v.trimmingCharacters(in: .whitespacesAndNewlines) }
                self?.tableView.reloadData()
            }
        }
    }
    
    private func showEditAlert(title: String, message: String, current: String, placeholder: String, onSave: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = current
            tf.placeholder = placeholder
            tf.autocapitalizationType = .none
            tf.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { _ in
            onSave(alert.textFields?.first?.text)
        })
        present(alert, animated: true)
    }
    
    @objc private func voiceToggled(_ sender: UISwitch) {
        VoiceService.shared.isEnabled = sender.isOn
    }
}

// MARK: - Voice Selection
class VoiceSelectionViewController: UIViewController {
    var onSelect: (() -> Void)?
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var voices: [AVSpeechSynthesisVoice] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "语音选择"
        view.backgroundColor = .systemGroupedBackground
        voices = VoiceService.availableVoices()
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension VoiceSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "v")
        let voice = voices[indexPath.row]
        cell.textLabel?.text = voice.name
        cell.detailTextLabel?.text = voice.language
        let isSelected = voice.identifier == VoiceService.shared.selectedVoiceIdentifier
        cell.accessoryType = isSelected ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let voice = voices[indexPath.row]
        VoiceService.shared.setVoice(identifier: voice.identifier)
        VoiceService.shared.speak("This is how I sound now.")
        tableView.reloadData()
        onSelect?()
    }
}
