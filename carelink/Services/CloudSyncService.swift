//
//  CloudSyncService.swift
//  carelink
//
//  Uploads blood pressure to CareLink Clinician Dashboard API (Vercel).
//  API: POST /api/blood-pressure
//  Doc: patientId(必填), systolic(60-300), diastolic(40-200), pulse(可选), source(可选默认 patient-app), deviceId(可选), patientNote(可选)
//  成功: 201 { success: true, reading: { ... } }
//

import Foundation

class CloudSyncService {

    static let shared = CloudSyncService()

    /// API base URL (CareLink Clinician Dashboard)
    /// 默认: https://carelinkclinician-dashboard-main.vercel.app
    var baseURL: String {
        get {
            UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://carelinkclinician-dashboard-main.vercel.app"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "apiBaseURL")
        }
    }

    /// Patient ID（必填，用于接口 patientId；在 设置 → 患者 ID 中配置）
    var patientId: String {
        get {
            UserDefaults.standard.string(forKey: "patientId") ?? "P-2025-005"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "patientId")
        }
    }

    private init() {}

    // MARK: - Upload (single reading)

    /// POST /api/blood-pressure
    /// Content-Type: application/json
    /// Body: patientId, systolic, diastolic, pulse?, source?, deviceId?, patientNote?
    func uploadReading(_ reading: BloodPressureReading, patientNote: String? = nil, completion: ((Bool, String?) -> Void)? = nil) {
        let urlString = baseURL.hasSuffix("/") ? "\(baseURL)api/blood-pressure" : "\(baseURL)/api/blood-pressure"
        guard let url = URL(string: urlString) else {
            completion?(false, "Invalid API URL")
            return
        }

        // 始终传 patientNote 为字符串，避免后端写入 Firestore 时出现 undefined 导致 500
        var body: [String: Any] = [
            "patientId": patientId,
            "systolic": reading.systolic,
            "diastolic": reading.diastolic,
            "pulse": reading.pulse,
            "source": mapSource(reading.source),
            "deviceId": "ios-app",
            "patientNote": (patientNote?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? ""
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion?(false, "Encode failed")
            return
        }

        print("📤 [Cloud] POST \(urlString) patientId=\(patientId) \(reading.systolic)/\(reading.diastolic)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [Cloud] Upload failed: \(error.localizedDescription)")
                completion?(false, error.localizedDescription)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(false, "Invalid response")
                return
            }

            let rawBody = String(data: data ?? Data(), encoding: .utf8) ?? ""
            if (200...299).contains(httpResponse.statusCode) {
                // 只有 HTTP 2xx 且响应里 success == true 才视为真正成功（后端可能返回 200 但 success: false）
                if let json = (try? JSONSerialization.jsonObject(with: data ?? Data())) as? [String: Any],
                   let success = json["success"] as? Bool, !success {
                    let errMsg = (json["error"] as? String) ?? (json["message"] as? String) ?? rawBody
                    print("❌ [Cloud] API returned success: false — \(errMsg)")
                    completion?(false, errMsg)
                    return
                }
                print("✅ [Cloud] Upload success (\(httpResponse.statusCode)) → \(rawBody.prefix(200))")
                completion?(true, nil)
            } else {
                let message = rawBody.isEmpty ? "HTTP \(httpResponse.statusCode)" : rawBody
                let full = "Status \(httpResponse.statusCode). \(message)"
                print("❌ [Cloud] API error: \(full)")
                completion?(false, full)
            }
        }.resume()
    }

    /// Map app source to API source
    private func mapSource(_ source: String) -> String {
        switch source.lowercased() {
        case "vision", "claude-vision": return "patient-app"
        case "manual": return "manual"
        case "voice": return "patient-app"
        default: return "patient-app"
        }
    }

    // MARK: - Batch upload (sequential POSTs to /api/blood-pressure)
    func uploadReadings(_ readings: [BloodPressureReading], completion: ((Bool, String?) -> Void)? = nil) {
        guard !readings.isEmpty else {
            completion?(true, nil)
            return
        }
        var remaining = readings
        func next() {
            guard let r = remaining.first else {
                completion?(true, nil)
                return
            }
            remaining.removeFirst()
            uploadReading(r) { success, error in
                if success {
                    next()
                } else {
                    completion?(false, error)
                }
            }
        }
        next()
    }
}
