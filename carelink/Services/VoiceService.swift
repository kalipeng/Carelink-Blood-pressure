//
//  VoiceService.swift
//  carelink
//
//  Voice Service - Provides voice guidance for elderly users
//

import Foundation
import AVFoundation

@MainActor
final class VoiceService: NSObject {
    
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
        
        // Load from settings
        _isEnabled = UserDefaults.standard.bool(forKey: "voiceEnabled")
        if UserDefaults.standard.object(forKey: "voiceEnabled") == nil {
            _isEnabled = true
        }
    }
    
    // MARK: - Voice Selection
    /// Available English voices for TTS (Claude / guidance)
    static func availableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted { ($0.name) < ($1.name) }
    }
    
    /// Currently selected voice identifier (saved in UserDefaults)
    var selectedVoiceIdentifier: String? {
        get { UserDefaults.standard.string(forKey: "selectedVoiceIdentifier") }
        set { UserDefaults.standard.set(newValue, forKey: "selectedVoiceIdentifier") }
    }
    
    /// Current voice to use for speech
    private var currentVoice: AVSpeechSynthesisVoice? {
        if let id = selectedVoiceIdentifier,
           let voice = AVSpeechSynthesisVoice(identifier: id) {
            return voice
        }
        return AVSpeechSynthesisVoice(language: "en-US")
    }
    
    func setVoice(identifier: String) {
        selectedVoiceIdentifier = identifier
    }
    
    /// Display name for current voice (e.g. "Samantha")
    var currentVoiceDisplayName: String {
        return currentVoice?.name ?? "Default"
    }
    
    // MARK: - Text to Speech
    func speak(_ text: String, rate: Float = 0.45) {
        guard _isEnabled else { return }
        
        // Stop current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let cleanText = Self.stripEmoji(text)
        let utterance = AVSpeechUtterance(string: cleanText)
        utterance.voice = currentVoice ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = rate  // 0.4-0.5 is slow, good for elderly
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
        print("🔊 Voice: \(cleanText)")
    }
    
    /// Remove emoji and other symbols so TTS doesn't read them aloud
    private static func stripEmoji(_ string: String) -> String {
        func isEmojiScalar(_ scalar: Unicode.Scalar) -> Bool {
            switch scalar.value {
            case 0x1F300...0x1F9FF: return true
            case 0x2600...0x26FF: return true
            case 0x2700...0x27BF: return true
            case 0xFE00...0xFE0F: return true
            case 0x1F000...0x1F02F: return true
            case 0x1F600...0x1F64F: return true
            case 0x1F680...0x1F6FF: return true
            case 0x2300...0x23FF: return true
            case 0x2B50, 0x2728, 0x274C, 0x274E: return true
            default: return false
            }
        }
        return string.filter { char in
            !char.unicodeScalars.contains(where: isEmojiScalar)
        }
        .replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        .trimmingCharacters(in: .whitespaces)
    }
    
    // MARK: - Quick Voice Prompts
    func speakWelcome() {
        speak("Welcome to the health monitoring system")
    }
    
    func speakDeviceConnected() {
        speak("Device connected")
    }
    
    func speakDeviceDisconnected() {
        speak("Device disconnected. Please check your blood pressure monitor")
    }
    
    func speakMeasurementStart() {
        speak("Starting measurement. Please stay still and relax")
    }
    
    func speakMeasurementResult(_ reading: BloodPressureReading) {
        let text = """
        Measurement complete.
        Systolic \(reading.systolic),
        Diastolic \(reading.diastolic),
        Pulse \(reading.pulse).
        Blood pressure is \(reading.category).
        """
        speak(text)
    }
    
    func speakError(_ message: String) {
        speak("Error: \(message)")
    }
    
    func speakConnectionRequired() {
        speak("Please connect your blood pressure monitor first")
    }
    
    // MARK: - Settings
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
    
    // MARK: - Stop
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
// Delegate callbacks are invoked from a background thread; use nonisolated to satisfy the protocol.
extension VoiceService: AVSpeechSynthesizerDelegate {
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("🔊 Speech started")
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("✅ Speech finished")
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("⏹️ Speech cancelled")
    }
}
