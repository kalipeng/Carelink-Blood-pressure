//
//  VoiceAIAssistantService.swift
//  HealthPad
//
//  AI Voice Assistant Service
//

import Foundation
import AVFoundation

// MARK: - Assistant State
enum AssistantState {
    case idle
    case listening
    case processing
    case speaking
}

// MARK: - Voice AI Assistant Service
class VoiceAIAssistantService: NSObject {
    static let shared = VoiceAIAssistantService()
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private(set) var currentState: AssistantState = .idle
    
    // Callbacks
    var onStateChange: ((AssistantState) -> Void)?
    var onTranscriptReceived: ((String) -> Void)?
    var onResponseReceived: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ [VoiceAI] Audio session setup failed: \(error)")
        }
    }
    
    // MARK: - Start Listening
    func startListening() {
        guard currentState == .idle else { return }
        
        updateState(.listening)
        
        // Setup recording
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentsPath.appendingPathComponent("voice_\(Date().timeIntervalSince1970).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            print("🎤 [VoiceAI] Started recording")
            
            // Auto-stop after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                if self?.currentState == .listening {
                    self?.stopListening()
                }
            }
        } catch {
            print("❌ [VoiceAI] Recording failed: \(error)")
            onError?("Failed to start recording")
            updateState(.idle)
        }
    }
    
    // MARK: - Stop Listening
    func stopListening() {
        guard currentState == .listening else { return }
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        updateState(.processing)
        
        // Process the recording
        if let url = recordingURL {
            processRecording(url: url)
        } else {
            onError?("No recording found")
            updateState(.idle)
        }
    }
    
    // MARK: - Process Recording (with OpenAI)
    private func processRecording(url: URL) {
        print("🎤 [VoiceAI] Processing recording...")
        
        // Check if OpenAI API key is configured
        guard OpenAIService.shared.hasAPIKey() else {
            print("⚠️ [VoiceAI] No API key configured, using simulated response")
            processRecordingSimulated(url: url)
            return
        }
        
        // Call OpenAI Whisper API for transcription
        print("🎤 [VoiceAI] Calling Whisper API for transcription...")
        
        OpenAIService.shared.transcribeAudio(audioURL: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transcript):
                    print("✅ [VoiceAI] Transcription: \(transcript)")
                    self?.onTranscriptReceived?(transcript)
                    
                    // Get AI response using GPT-4
                    self?.getAIResponse(for: transcript)
                    
                case .failure(let error):
                    print("❌ [VoiceAI] Transcription failed: \(error.localizedDescription)")
                    self?.onError?("Sorry, I couldn't hear you clearly. Please try again.")
                    self?.updateState(.idle)
                }
            }
        }
    }
    
    // MARK: - Get AI Response
    private func getAIResponse(for userMessage: String) {
        let recentReadings = getRecentReadings()
        
        OpenAIService.shared.chatCompletion(
            userMessage: userMessage,
            recentReadings: recentReadings
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ [VoiceAI] Got AI response: \(response)")
                    self?.updateState(.speaking)
                    self?.onResponseReceived?(response)
                    
                    // Speak the response
                    VoiceService.shared.speak(response)
                    
                    // Return to idle after speaking
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.updateState(.idle)
                    }
                    
                case .failure(let error):
                    print("❌ [VoiceAI] API error: \(error.localizedDescription)")
                    self?.onError?("Sorry, I couldn't connect to my AI brain. Please check your API key.")
                    self?.updateState(.idle)
                }
            }
        }
    }
    
    // MARK: - Fallback Simulated Response
    private func processRecordingSimulated(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Simulate API delay
            Thread.sleep(forTimeInterval: 1.5)
            
            DispatchQueue.main.async {
                // Simulated transcript
                let transcript = "Hello, how can I help you?"
                self?.onTranscriptReceived?(transcript)
                
                // Get recent readings for context
                let recentReadings = self?.getRecentReadings() ?? []
                let context = recentReadings.prefix(5).map { 
                    "\($0.systolic)/\($0.diastolic) mmHg, Pulse: \($0.pulse) bpm" 
                }.joined(separator: ", ")
                
                // Simulated AI response
                let response = context.isEmpty ? 
                    "Hello! I'm your health assistant. You haven't taken any blood pressure readings yet. Would you like to measure now?" :
                    "Your recent blood pressure readings are: \(context). Your blood pressure looks good!"
                
                self?.updateState(.speaking)
                self?.onResponseReceived?(response)
                
                // Speak the response
                VoiceService.shared.speak(response)
                
                // Return to idle after speaking
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.updateState(.idle)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func updateState(_ state: AssistantState) {
        currentState = state
        onStateChange?(state)
    }
    
    private func getRecentReadings() -> [BloodPressureReading] {
        guard let data = UserDefaults.standard.array(forKey: "bloodPressureReadings") as? [[String: Any]] else {
            return []
        }
        
        return data.compactMap { dict -> BloodPressureReading? in
            guard let systolic = dict["systolic"] as? Int,
                  let diastolic = dict["diastolic"] as? Int,
                  let pulse = dict["pulse"] as? Int,
                  let timestamp = dict["timestamp"] as? Date,
                  let source = dict["source"] as? String else {
                return nil
            }
            
            return BloodPressureReading(
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                timestamp: timestamp,
                source: source
            )
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension VoiceAIAssistantService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("🎤 [VoiceAI] Recording finished: \(flag ? "success" : "failed")")
    }
}
