//
//  SettingsViewController.swift
//  HealthPad
//
//  Settings screen
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
        title = "Settings"
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
                cell.textLabel?.text = "Voice guidance"
                let toggle = UISwitch()
                toggle.isOn = UserDefaults.standard.bool(forKey: "voiceEnabled")
                toggle.addTarget(self, action: #selector(voiceToggled(_:)), for: .valueChanged)
                cell.accessoryView = toggle
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Voice"
                cell.detailTextLabel?.text = VoiceService.shared.currentVoiceDisplayName
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = "Device"
                cell.detailTextLabel?.text = iHealthService.shared.isConnected ? "Connected" : "Not connected"
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "API URL"
                cell.detailTextLabel?.text = CloudSyncService.shared.baseURL
                cell.detailTextLabel?.numberOfLines = 2
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = "Patient ID"
                cell.detailTextLabel?.text = CloudSyncService.shared.patientId
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            cell.textLabel?.text = "About"
            cell.detailTextLabel?.text = "Version 1.0"
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
            showEditAlert(title: "API URL", message: "CareLink clinician dashboard backend URL", current: CloudSyncService.shared.baseURL, placeholder: "https://carelinkclinician-dashboard-main.vercel.app") { [weak self] newValue in
                if let v = newValue, !v.isEmpty { CloudSyncService.shared.baseURL = v.trimmingCharacters(in: .whitespacesAndNewlines) }
                self?.tableView.reloadData()
            }
        } else if indexPath.section == 1 && indexPath.row == 1 {
            showEditAlert(title: "Patient ID", message: "Required for API, e.g. P-2025-005", current: CloudSyncService.shared.patientId, placeholder: "P-2025-005") { [weak self] newValue in
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
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
        title = "Voice"
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
