//
//  OpenAIService.swift
//  carelink
//
//  AI Service: Claude Opus (Anthropic) for chat + vision
//  Optional: OpenAI Whisper for speech-to-text (voice input)
//

import Foundation
import UIKit
import CoreImage

// MARK: - AI Service (Claude Opus + optional Whisper)
class OpenAIService {
    static let shared = OpenAIService()
    
    // Anthropic Claude API
    private let anthropicEndpoint = "https://api.anthropic.com/v1/messages"
    private let anthropicVersion = "2023-06-01"
    // Chat and general use (use current model IDs; older ones like claude-3-5-sonnet-20241022 may be deprecated)
    private let claudeModel = "claude-sonnet-4-6"
    /// Best vision/reasoning for BP monitor reading
    private let claudeVisionModel = "claude-opus-4-6"
    /// Faster, lower-latency model for behavior-based guidance (video/frame)
    private let claudeGuidanceModel = "claude-haiku-4-5-20251001"
    
    // Claude API key (primary - for chat + vision)
    private var anthropicApiKey: String {
        return UserDefaults.standard.string(forKey: "anthropic_api_key") ?? ""
    }
    
    // OpenAI key (optional - for Whisper voice input only)
    private var openaiApiKey: String {
        return UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
    
    private init() {}
    
    // MARK: - API Key Management
    func setAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "anthropic_api_key")
        print("✅ [Claude] API key saved")
    }
    
    /// Optional: set OpenAI key for voice input (Whisper). Claude key is used for chat and vision.
    func setOpenAIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "openai_api_key")
        print("✅ [Whisper] OpenAI key saved for voice input")
    }
    
    /// Get OpenAI key (for optional voice input). Used only to pre-fill settings UI.
    func getOpenAIKey() -> String {
        return openaiApiKey
    }
    
    /// Whether OpenAI key is set (voice input available).
    func hasOpenAIKey() -> Bool {
        return !openaiApiKey.isEmpty
    }
    
    func getAPIKey() -> String {
        return anthropicApiKey
    }
    
    func hasAPIKey() -> Bool {
        let key = anthropicApiKey
        return !key.isEmpty && key != "YOUR_API_KEY_HERE"
    }
    
    func clearAPIKey() {
        UserDefaults.standard.removeObject(forKey: "anthropic_api_key")
        UserDefaults.standard.removeObject(forKey: "openai_api_key")
        print("🗑️ [Claude] API key cleared")
    }
    
    // MARK: - Chat Completion (Claude Opus)
    func chatCompletion(
        userMessage: String,
        systemPrompt: String? = nil,
        recentReadings: [BloodPressureReading] = [],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard hasAPIKey() else {
            completion(.failure(NSError(domain: "Claude", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])))
            return
        }
        
        var fullSystemPrompt = systemPrompt ?? """
        You are a helpful health assistant for elderly users. You help them understand their blood pressure readings and provide gentle health guidance.
        
        Guidelines:
        - Keep responses SHORT and SIMPLE (1-2 sentences max)
        - Use everyday language, avoid medical jargon
        - Be warm, friendly, and encouraging
        - If readings are concerning, gently suggest seeing a doctor
        - Never diagnose or prescribe medication
        """
        
        if !recentReadings.isEmpty {
            let readingsContext = recentReadings.prefix(5).map { reading in
                "\(reading.systolic)/\(reading.diastolic) mmHg, Pulse: \(reading.pulse) bpm"
            }.joined(separator: ", ")
            fullSystemPrompt += "\n\nRecent blood pressure readings: \(readingsContext)"
        }
        
        // Claude Messages API format
        let requestBody: [String: Any] = [
            "model": claudeModel,
            "max_tokens": 256,
            "system": fullSystemPrompt,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]
        
        makeClaudeRequest(body: requestBody) { result in
            switch result {
            case .success(let data):
                if let response = self.parseClaudeResponse(data) {
                    completion(.success(response))
                } else {
                    completion(.failure(NSError(domain: "Claude", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Whisper API (Speech-to-Text) – requires OpenAI key (Anthropic does not provide speech-to-text)
    func transcribeAudio(
        audioURL: URL,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard !openaiApiKey.isEmpty else {
            completion(.failure(NSError(domain: "Whisper", code: 401, userInfo: [NSLocalizedDescriptionKey: "Voice input requires an OpenAI API key (Settings). Claude is used for chat and vision only."])))
            return
        }
        let key = openaiApiKey
        
        guard let audioData = try? Data(contentsOf: audioURL) else {
            completion(.failure(NSError(domain: "Whisper", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to read audio file"])))
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        body.append("en\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let whisperEndpoint = "https://api.openai.com/v1/audio/transcriptions"
        guard let url = URL(string: whisperEndpoint) else {
            completion(.failure(NSError(domain: "Whisper", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "Whisper", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let text = json["text"] as? String {
                    completion(.success(text))
                } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let err = json["error"] as? [String: Any],
                          let message = err["message"] as? String {
                    completion(.failure(NSError(domain: "Whisper", code: 500, userInfo: [NSLocalizedDescriptionKey: message])))
                } else {
                    completion(.failure(NSError(domain: "Whisper", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Vision (Claude) – behavior-based measurement guidance (low latency)
    /// Observes what the person is doing in the frame and returns ONE short guidance sentence.
    func analyzeMeasurementGuidance(
        image: UIImage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard hasAPIKey() else {
            completion(.failure(NSError(domain: "Claude", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])))
            return
        }
        
        let resized = resizeImageForVision(image, maxLength: 640)
        guard let imageData = resized.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "Claude", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }
        let base64Image = imageData.base64EncodedString()
        
        let systemPrompt = """
        You are a caring health coach watching someone measure their blood pressure.
        Look at what the PERSON is doing in the image: posture, cuff on arm, arm position, whether they are pressing the monitor, waiting, or showing the screen.
        Give ONE short, friendly sentence (max 8 words) that tells them the NEXT or MOST IMPORTANT thing to do based on what you see. Examples:
        - "Sit back and relax your arm."
        - "Put the cuff one inch above your elbow."
        - "Press the START button on the monitor."
        - "Keep still until the measurement finishes."
        - "Point the camera at the monitor screen."
        Reply with ONLY that one sentence, nothing else. Be warm and elderly-friendly.
        """
        
        let userContent: [[String: Any]] = [
            ["type": "text", "text": "What do you see the person doing? Reply with ONE short guidance sentence (max 8 words) for the next step."],
            [
                "type": "image",
                "source": [
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": base64Image
                ]
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": claudeGuidanceModel,
            "max_tokens": 56,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userContent]
            ]
        ]
        
        makeClaudeRequest(body: requestBody, timeout: 25) { result in
            switch result {
            case .success(let data):
                if let guidance = self.parseClaudeResponse(data) {
                    completion(.success(guidance))
                } else {
                    completion(.failure(NSError(domain: "Claude", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Vision (Claude) – read BP monitor numbers
    func analyzeBloodPressureImage(
        image: UIImage,
        completion: @escaping (Result<BloodPressureReading?, Error>) -> Void
    ) {
        guard hasAPIKey() else {
            completion(.failure(NSError(domain: "Claude", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])))
            return
        }
        
        // Larger image for digit clarity (1536); optional contrast boost for dim/glossy screens
        let resized = resizeImageForVision(image, maxLength: 1536)
        let enhanced = enhanceImageForBPReading(resized)
        guard let imageData = enhanced.jpegData(compressionQuality: 0.9) else {
            completion(.failure(NSError(domain: "Claude", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }
        let base64Image = imageData.base64EncodedString()
        
        let systemPrompt = """
        You are a medical device reader. Your ONLY job is to read the numbers on the BLOOD PRESSURE MONITOR's digital/LCD screen. Ignore everything else in the image (hands, table, room).

        WHERE TO LOOK: Find the small rectangular display or screen on the device. It shows 3 values:
        - SYS (systolic): usually the TOP or LARGEST number, range 90-200
        - DIA (diastolic): usually the MIDDLE number, range 50-120
        - PULSE (heart rate): usually BOTTOM or next to a heart symbol, range 40-120

        RULES:
        1. Read digit by digit. Easy to confuse: 1 and 7, 6 and 8, 3 and 5 and 8. Choose the value that fits normal BP ranges.
        2. Systolic must be greater than diastolic. If you read them reversed, swap.
        3. If the screen is partly visible, give your best estimate. If you cannot see any numbers, respond with the error JSON.
        4. Reply with ONLY valid JSON, no other text. Integers only.

        SUCCESS format: {"systolic": 120, "diastolic": 80, "pulse": 72}
        UNREADABLE: {"error": "Cannot read values"}
        """
        
        let userContent: [[String: Any]] = [
            ["type": "text", "text": "Read the three numbers on the blood pressure monitor display (systolic, diastolic, pulse). Reply with ONLY this JSON, nothing else: {\"systolic\": number, \"diastolic\": number, \"pulse\": number}"],
            [
                "type": "image",
                "source": [
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": base64Image
                ]
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": claudeVisionModel,
            "max_tokens": 120,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userContent]
            ]
        ]
        
        func performRequest(retryCount: Int) {
            makeClaudeRequest(body: requestBody, timeout: 50) { result in
                switch result {
                case .success(let data):
                    guard let jsonResponse = self.parseClaudeResponse(data) else {
                        if retryCount > 0 {
                            performRequest(retryCount: retryCount - 1)
                        } else {
                            completion(.failure(NSError(domain: "Claude", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                        }
                        return
                    }
                    if let reading = self.parseBloodPressureJSON(jsonResponse) {
                        completion(.success(reading))
                        return
                    }
                    let extracted = self.extractBPJSON(from: jsonResponse)
                    if let reading = extracted {
                        completion(.success(reading))
                        return
                    }
                    if retryCount > 0 {
                        print("⚠️ [Claude Vision] Parse failed, retrying... Raw: \(jsonResponse.prefix(200))")
                        performRequest(retryCount: retryCount - 1)
                    } else {
                        print("⚠️ [Claude Vision] Could not parse: \(jsonResponse)")
                        completion(.success(nil))
                    }
                case .failure(let error):
                    if retryCount > 0 {
                        print("⚠️ [Claude Vision] Request failed, retrying: \(error.localizedDescription)")
                        performRequest(retryCount: retryCount - 1)
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }
        performRequest(retryCount: 1)
    }
    
    /// Slight contrast/brightness boost to make LCD digits easier to read
    private func enhanceImageForBPReading(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(1.15, forKey: kCIInputContrastKey)
        filter?.setValue(0.05, forKey: kCIInputBrightnessKey)
        guard let output = filter?.outputImage else { return image }
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Claude HTTP Request
    private func makeClaudeRequest(
        body: [String: Any],
        timeout: TimeInterval = 60,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: anthropicEndpoint) else {
            completion(.failure(NSError(domain: "Claude", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anthropicApiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Claude", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "Claude", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            if httpResponse.statusCode == 200 {
                completion(.success(data))
            } else {
                var message = "Request failed (\(httpResponse.statusCode))"
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let err = json["error"] as? [String: Any],
                   let msg = err["message"] as? String {
                    message = msg
                }
                print("❌ [Claude] API error: \(httpResponse.statusCode) \(message)")
                completion(.failure(NSError(domain: "Claude", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    private func parseClaudeResponse(_ data: Data) -> String? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let content = json["content"] as? [[String: Any]],
                  let first = content.first,
                  let type = first["type"] as? String, type == "text",
                  let text = first["text"] as? String else {
                return nil
            }
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }
    
    private func resizeImageForVision(_ image: UIImage, maxLength: CGFloat) -> UIImage {
        let size = image.size
        guard size.width > maxLength || size.height > maxLength else { return image }
        let ratio = min(maxLength / size.width, maxLength / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized ?? image
    }
    
    private func parseBloodPressureJSON(_ jsonString: String) -> BloodPressureReading? {
        var cleaned = jsonString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleaned.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        if json["error"] != nil { return nil }
        guard let systolic = json["systolic"] as? Int,
              let diastolic = json["diastolic"] as? Int else {
            return nil
        }
        let pulse = (json["pulse"] as? Int) ?? 0
        return BloodPressureReading(
            systolic: systolic,
            diastolic: diastolic,
            pulse: pulse,
            source: "claude-vision"
        )
    }
    
    /// Extract BP JSON from response that may contain extra text (e.g. "Here is the reading: {...}")
    private func extractBPJSON(from text: String) -> BloodPressureReading? {
        if let reading = parseBloodPressureJSON(text) { return reading }
        let patterns = [
            #"\{\s*"systolic"\s*:\s*\d+\s*,\s*"diastolic"\s*:\s*\d+\s*,\s*"pulse"\s*:\s*\d+\s*\}"#,
            #"\{\s*"systolic"\s*:\s*\d+\s*,\s*"diastolic"\s*:\s*\d+\s*\}"#
        ]
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range, in: text) else { continue }
            if let reading = parseBloodPressureJSON(String(text[range])) { return reading }
        }
        return nil
    }
}

// MARK: - API Key Configuration View Controller
class APIKeyViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "⚙️ API Configuration"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your Claude (Anthropic) API key to enable AI features"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let apiKeyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "sk-ant-..."
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 18)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save API Key", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor(red: 0.89, green: 0, blue: 0.45, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = """
        How to get your Claude API key:
        1. Go to console.anthropic.com
        2. Sign in or create an account
        3. Go to API Keys
        4. Create a new key
        5. Copy and paste it here
        """
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if OpenAIService.shared.hasAPIKey() {
            apiKeyTextField.text = OpenAIService.shared.getAPIKey()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(apiKeyTextField)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        view.addSubview(instructionsLabel)
        
        [titleLabel, subtitleLabel, apiKeyTextField, saveButton, cancelButton, instructionsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            apiKeyTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            apiKeyTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            apiKeyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            apiKeyTextField.heightAnchor.constraint(equalToConstant: 50),
            saveButton.topAnchor.constraint(equalTo: apiKeyTextField.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionsLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 40),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    @objc private func saveTapped() {
        guard let apiKey = apiKeyTextField.text, !apiKey.isEmpty else {
            showAlert(title: "Error", message: "Please enter an API key")
            return
        }
        OpenAIService.shared.setAPIKey(apiKey)
        showAlert(title: "Success", message: "API key saved successfully!") {
            self.dismiss(animated: true)
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
}
