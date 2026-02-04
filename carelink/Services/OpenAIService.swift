//
//  OpenAIService.swift
//  HealthPad
//
//  OpenAI API Integration Service
//  - GPT-4 for conversational AI
//  - GPT-4 Vision for blood pressure monitor screen analysis
//

import Foundation
import UIKit

// MARK: - OpenAI Service
class OpenAIService {
    static let shared = OpenAIService()
    
    private let chatEndpoint = "https://api.openai.com/v1/chat/completions"
    private var apiKey: String {
        // Try to get from UserDefaults first, fallback to hardcoded key
        return UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
    
    private init() {}
    
    // MARK: - API Key Management
    func setAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "openai_api_key")
        print("✅ [OpenAI] API key saved")
    }
    
    func getAPIKey() -> String {
        return apiKey
    }
    
    func hasAPIKey() -> Bool {
        return !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE"
    }
    
    func clearAPIKey() {
        UserDefaults.standard.removeObject(forKey: "openai_api_key")
        print("🗑️ [OpenAI] API key cleared")
    }
    
    // MARK: - Chat Completion (GPT-4)
    func chatCompletion(
        userMessage: String,
        systemPrompt: String? = nil,
        recentReadings: [BloodPressureReading] = [],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard hasAPIKey() else {
            completion(.failure(NSError(domain: "OpenAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])))
            return
        }
        
        // Build system prompt with context
        var fullSystemPrompt = systemPrompt ?? """
        You are a helpful health assistant for elderly users. You help them understand their blood pressure readings and provide gentle health guidance.
        
        Guidelines:
        - Keep responses SHORT and SIMPLE (1-2 sentences max)
        - Use everyday language, avoid medical jargon
        - Be warm, friendly, and encouraging
        - If readings are concerning, gently suggest seeing a doctor
        - Never diagnose or prescribe medication
        """
        
        // Add recent readings context
        if !recentReadings.isEmpty {
            let readingsContext = recentReadings.prefix(5).map { reading in
                "\(reading.systolic)/\(reading.diastolic) mmHg, Pulse: \(reading.pulse) bpm"
            }.joined(separator: ", ")
            fullSystemPrompt += "\n\nRecent blood pressure readings: \(readingsContext)"
        }
        
        // Build request
        let messages: [[String: String]] = [
            ["role": "system", "content": fullSystemPrompt],
            ["role": "user", "content": userMessage]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 150
        ]
        
        makeRequest(endpoint: chatEndpoint, body: requestBody) { result in
            switch result {
            case .success(let data):
                if let response = self.parseChatResponse(data) {
                    completion(.success(response))
                } else {
                    completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Whisper API (Speech-to-Text)
    func transcribeAudio(
        audioURL: URL,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard hasAPIKey() else {
            completion(.failure(NSError(domain: "OpenAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])))
            return
        }
        
        // Read audio file
        guard let audioData = try? Data(contentsOf: audioURL) else {
            completion(.failure(NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to read audio file"])))
            return
        }
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add model parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        
        // Add language parameter (English)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        body.append("en\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Create request
        let whisperEndpoint = "https://api.openai.com/v1/audio/transcriptions"
        guard let url = URL(string: whisperEndpoint) else {
            completion(.failure(NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = 30
        
        print("🎤 [OpenAI] Sending audio to Whisper API...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [OpenAI] Whisper request failed: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Parse response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let text = json["text"] as? String {
                    print("✅ [OpenAI] Whisper transcription: \(text)")
                    completion(.success(text))
                } else {
                    // Try to get error message
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        print("❌ [OpenAI] Whisper API error: \(message)")
                        completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: message])))
                    } else {
                        completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                    }
                }
            } catch {
                print("❌ [OpenAI] Failed to parse Whisper response: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Vision API (GPT-4 Vision)
    
    /// AI Coach: Analyze posture and cuff placement, provide real-time guidance
    func analyzeMeasurementGuidance(
        image: UIImage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard hasAPIKey() else {
            completion(.failure(NSError(domain: "OpenAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])))
            return
        }
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            completion(.failure(NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }
        let base64Image = imageData.base64EncodedString()
        
        // Build guidance request
        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": """
You are a caring health coach helping elderly people measure their blood pressure correctly.

Your job is to:
1. Check if they are sitting properly (back straight, feet flat on floor)
2. Check if the blood pressure cuff is on the correct arm position (upper arm, 1 inch above elbow)
3. Check if their arm is at heart level and resting on a surface
4. Check if they look relaxed (not talking, not moving)

Respond with ONE short, friendly sentence (max 10 words) with the MOST IMPORTANT guidance:
- If posture is wrong: "Sit up straight with feet flat on floor."
- If cuff position is wrong: "Place cuff on upper arm, one inch above elbow."
- If arm is too high/low: "Rest your arm at heart level."
- If they're moving: "Stay still and relax for accurate reading."
- If everything looks good: "Perfect! Keep this position and stay relaxed."

Be warm, encouraging, and elderly-friendly. Keep it SIMPLE.
"""
            ],
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": "Am I measuring my blood pressure correctly? Give me ONE tip."
                    ],
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64Image)"
                        ]
                    ]
                ]
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_tokens": 50,
            "temperature": 0.7
        ]
        
        makeRequest(endpoint: chatEndpoint, body: requestBody) { result in
            switch result {
            case .success(let data):
                if let guidance = self.parseChatResponse(data) {
                    completion(.success(guidance))
                } else {
                    completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Read numbers from blood pressure monitor screen
    func analyzeBloodPressureImage(
        image: UIImage,
        completion: @escaping (Result<BloodPressureReading?, Error>) -> Void
    ) {
        guard hasAPIKey() else {
            completion(.failure(NSError(domain: "OpenAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])))
            return
        }
        
        // Convert image to base64 with high quality
        guard let imageData = image.jpegData(compressionQuality: 0.95) else {
            completion(.failure(NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }
        let base64Image = imageData.base64EncodedString()
        
        // Build vision request with high-accuracy prompt
        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": """
                You are a precise medical device reader. Your ONLY task is to read the EXACT numbers displayed on a blood pressure monitor screen.

                CRITICAL ACCURACY RULES:
                1. Read EACH DIGIT individually and carefully: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
                2. Pay attention to similar-looking digits: 1 vs 7, 6 vs 8, 3 vs 8, 5 vs 6
                3. On 7-segment displays: 1 is two vertical lines on the right, 7 has a top bar
                4. Double-check each number before responding
                5. If a digit is unclear, look at the segment pattern carefully

                DISPLAY LAYOUT (most monitors):
                - TOP/LARGEST number = Systolic (SYS) - typically 90-180
                - MIDDLE number = Diastolic (DIA) - typically 60-110
                - BOTTOM/SMALLEST number with heart ♥ icon = Pulse - typically 50-100

                VALIDATION:
                - Systolic MUST be greater than Diastolic
                - If systolic < diastolic, you've swapped them - fix it
                - Typical readings: 120/80 pulse 72, 135/85 pulse 68, etc.

                OUTPUT FORMAT (JSON only, no other text):
                {"systolic": NUMBER, "diastolic": NUMBER, "pulse": NUMBER}
                
                If truly unreadable: {"error": "Cannot read values"}
                """
            ],
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": "Read the EXACT numbers on this blood pressure monitor. Check each digit carefully - accuracy is critical. What are the systolic, diastolic, and pulse values shown?"
                    ],
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64Image)",
                            "detail": "high"
                        ]
                    ]
                ]
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_tokens": 150,
            "temperature": 0.0  // Zero temperature for maximum accuracy/consistency
        ]
        
        makeRequest(endpoint: chatEndpoint, body: requestBody) { result in
            switch result {
            case .success(let data):
                if let jsonResponse = self.parseChatResponse(data) {
                    // Try to parse JSON response
                    if let reading = self.parseBloodPressureJSON(jsonResponse) {
                        completion(.success(reading))
                    } else {
                        print("⚠️ [OpenAI Vision] Could not parse values from response: \(jsonResponse)")
                        completion(.success(nil)) // Return nil if cannot parse
                    }
                } else {
                    completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - HTTP Request
    private func makeRequest(
        endpoint: String,
        body: [String: Any],
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        print("🌐 [OpenAI] Making request to \(endpoint)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [OpenAI] Request error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Log response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 [OpenAI] Response (\(httpResponse.statusCode)): \(responseString.prefix(200))...")
            }
            
            if httpResponse.statusCode == 200 {
                completion(.success(data))
            } else {
                // Try to parse error message
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = json["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    completion(.failure(NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])))
                } else {
                    completion(.failure(NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed"])))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Response Parsing
    private func parseChatResponse(_ data: Data) -> String? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("❌ [OpenAI] Parse error: \(error)")
        }
        return nil
    }
    
    private func parseBloodPressureJSON(_ jsonString: String) -> BloodPressureReading? {
        // Clean up the string - remove markdown code blocks if present
        var cleanedString = jsonString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedString.data(using: .utf8) else { return nil }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // Check for error response
                if json["error"] != nil {
                    return nil
                }
                
                // Extract values
                guard let systolic = json["systolic"] as? Int,
                      let diastolic = json["diastolic"] as? Int,
                      let pulse = json["pulse"] as? Int else {
                    return nil
                }
                
                return BloodPressureReading(
                    systolic: systolic,
                    diastolic: diastolic,
                    pulse: pulse,
                    source: "gpt4-vision"
                )
            }
        } catch {
            print("❌ [OpenAI] JSON parse error: \(error)")
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
        label.text = "Enter your OpenAI API key to enable AI features"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let apiKeyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "sk-..."
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
        How to get your API key:
        1. Go to platform.openai.com
        2. Sign in or create an account
        3. Go to API Keys section
        4. Create a new secret key
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
        
        // Load existing key if present
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
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        apiKeyTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
