//
//  CloudSyncService.swift
//  carelink
//
//  Uploads blood pressure to Next.js API → Firebase (Vercel)
//  API: POST /api/blood-pressure with patientId, systolic, diastolic, pulse, source, deviceId
//

import Foundation

class CloudSyncService {

    static let shared = CloudSyncService()

    /// Next.js API base URL (CareLink Clinician Dashboard)
    var baseURL: String {
        get {
            UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://carelink-clinician-dashboard-hdld.vercel.app"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "apiBaseURL")
        }
    }

    /// Patient ID for uploads (required by API, e.g. P-2025-001)
    var patientId: String {
        get {
            UserDefaults.standard.string(forKey: "patientId") ?? "P-2025-001"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "patientId")
        }
    }

    private init() {}

    // MARK: - Upload (single reading → Firebase via your API)

    /// POST to your Next.js API: /api/blood-pressure
    /// API writes to Firestore; Dashboard gets real-time updates via onSnapshot.
    func uploadReading(_ reading: BloodPressureReading, completion: ((Bool, String?) -> Void)? = nil) {
        let urlString = baseURL.hasSuffix("/") ? "\(baseURL)api/blood-pressure" : "\(baseURL)/api/blood-pressure"
        guard let url = URL(string: urlString) else {
            completion?(false, "Invalid API URL")
            return
        }

        // Request body per your API spec
        var body: [String: Any] = [
            "patientId": patientId,
            "systolic": reading.systolic,
            "diastolic": reading.diastolic,
            "pulse": reading.pulse,
            "source": mapSource(reading.source),
            "deviceId": "ios_app"
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

            if (200...299).contains(httpResponse.statusCode) {
                print("✅ [Cloud] Upload success (\(httpResponse.statusCode))")
                completion?(true, nil)
            } else {
                let raw = String(data: data ?? Data(), encoding: .utf8) ?? ""
                let message = raw.isEmpty ? "HTTP \(httpResponse.statusCode)" : raw
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
