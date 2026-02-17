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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 1
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
            vc.onSelect = { [weak self] in
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
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
