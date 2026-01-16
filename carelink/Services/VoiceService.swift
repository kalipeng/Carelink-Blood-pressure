//
//  VoiceService.swift
//  HealthPad
//
//  语音提示服务 - 为老年人提供语音指导
//

import Foundation
import AVFoundation

class VoiceService: NSObject {
    
    static let shared = VoiceService()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    var isEnabled: Bool {
        get {
            return _isEnabled
        }
        set {
            setEnabled(newValue)
        }
    }
    
    private var _isEnabled = true
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        
        // 从设置加载
        _isEnabled = UserDefaults.standard.bool(forKey: "voiceEnabled")
        if UserDefaults.standard.object(forKey: "voiceEnabled") == nil {
            _isEnabled = true
        }
    }
    
    // MARK: - 语音播报
    func speak(_ text: String, rate: Float = 0.45) {
        guard _isEnabled else { return }
        
        // 停止当前播报
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = rate  // 0.4-0.5 为慢速，适合老年人
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
        print("🔊 语音: \(text)")
    }
    
    // MARK: - 快捷语音
    func speakWelcome() {
        speak("欢迎使用健康监测系统")
    }
    
    func speakDeviceConnected() {
        speak("设备已连接")
    }
    
    func speakDeviceDisconnected() {
        speak("设备已断开连接，请检查血压计")
    }
    
    func speakMeasurementStart() {
        speak("开始测量，请保持安静，放松身体")
    }
    
    func speakMeasurementResult(_ reading: BloodPressureReading) {
        let text = """
        测量完成。
        收缩压 \(reading.systolic)，
        舒张压 \(reading.diastolic)，
        心率 \(reading.pulse)。
        血压\(reading.category)。
        \(reading.recommendation)
        """
        speak(text)
    }
    
    func speakError(_ message: String) {
        speak("出现错误：\(message)")
    }
    
    func speakConnectionRequired() {
        speak("请先连接血压计设备")
    }
    
    // MARK: - 设置
    private func setEnabled(_ enabled: Bool) {
        _isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "voiceEnabled")
        
        if enabled {
            speak("Voice guidance enabled")
        }
    }
    
    func toggle() {
        setEnabled(!_isEnabled)
    }
    
    // MARK: - 停止
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension VoiceService: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("🔊 开始播报")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("✅ 播报完成")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("⏹️ 播报取消")
    }
}
