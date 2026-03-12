//
//  AudioRecorderService.swift
//  carelink
//
//  Audio Recording for Whisper API
//

import Foundation
import AVFoundation

class AudioRecorderService: NSObject {
    
    static let shared = AudioRecorderService()
    
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession?
    private var recordingURL: URL?
    
    private var recordingCompletion: ((URL?) -> Void)?
    private var silenceCheckTimer: Timer?
    private var silenceStartTime: Date?
    private static let silenceThresholdDB: Float = -40
    private static let silenceDurationToStop: TimeInterval = 2.0
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Setup
    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession?.setActive(true)
            print("✅ [Audio] Session configured")
        } catch {
            print("❌ [Audio] Failed to setup session: \(error)")
        }
    }
    
    // MARK: - Recording
    
    /// Start recording audio
    /// - Parameter completion: Called when recording stops, with the audio file URL
    func startRecording(completion: @escaping (URL?) -> Void) {
        recordingCompletion = completion
        
        // Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.beginRecording()
                } else {
                    print("❌ [Audio] Microphone permission denied")
                    completion(nil)
                }
            }
        }
    }
    
    private func beginRecording() {
        // Create temp file URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("voice_recording_\(Date().timeIntervalSince1970).m4a")
        recordingURL = audioFilename
        
        // Recording settings optimized for Whisper
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,  // Whisper works well with 16kHz
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            silenceStartTime = nil
            startSilenceCheckTimer()
            print("🎙️ [Audio] Recording started: \(audioFilename.lastPathComponent)")
        } catch {
            print("❌ [Audio] Failed to start recording: \(error)")
            recordingCompletion?(nil)
        }
    }
    
    /// Stop recording and get the audio file URL
    func stopRecording() {
        stopSilenceCheckTimer()
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            print("⏹️ [Audio] Recording stopped")
        }
    }
    
    private func startSilenceCheckTimer() {
        stopSilenceCheckTimer()
        silenceStartTime = nil
        silenceCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkSilence()
        }
        RunLoop.main.add(silenceCheckTimer!, forMode: .common)
    }
    
    private func stopSilenceCheckTimer() {
        silenceCheckTimer?.invalidate()
        silenceCheckTimer = nil
    }
    
    private func checkSilence() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        if power < Self.silenceThresholdDB {
            if silenceStartTime == nil {
                silenceStartTime = Date()
            } else if Date().timeIntervalSince(silenceStartTime!) >= Self.silenceDurationToStop {
                stopRecording()
            }
        } else {
            silenceStartTime = nil
        }
    }
    
    /// Record for a specific duration
    func recordForDuration(_ seconds: TimeInterval, completion: @escaping (URL?) -> Void) {
        startRecording { url in
            // Will be called when recording finishes
            completion(url)
        }
        
        // Auto-stop after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            self?.stopRecording()
        }
    }
    
    // MARK: - Cleanup
    func deleteRecording(at url: URL) {
        try? FileManager.default.removeItem(at: url)
        print("🗑️ [Audio] Deleted recording: \(url.lastPathComponent)")
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorderService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("✅ [Audio] Recording saved successfully")
            recordingCompletion?(recordingURL)
        } else {
            print("❌ [Audio] Recording failed")
            recordingCompletion?(nil)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("❌ [Audio] Encoding error: \(error?.localizedDescription ?? "Unknown")")
        recordingCompletion?(nil)
    }
}
