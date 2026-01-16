//
//  CloudSyncService.swift
//  HealthPad
//
//  云端同步服务 - 利用 T-Mobile 5G 上传数据
//

import Foundation

class CloudSyncService {
    
    static let shared = CloudSyncService()
    
    // 配置 API 端点
    private let baseURL = "https://your-api-endpoint.com/api"
    private var apiKey: String? = nil
    
    private init() {
        // 从配置加载 API Key
        apiKey = UserDefaults.standard.string(forKey: "apiKey")
    }
    
    // MARK: - 上传血压数据
    func uploadReading(_ reading: BloodPressureReading, completion: ((Bool, String?) -> Void)? = nil) {
        guard let url = URL(string: "\(baseURL)/blood-pressure") else {
            completion?(false, "无效的 API 地址")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let apiKey = apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        // 编码数据
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(reading)
            request.httpBody = jsonData
            
            print("📤 [5G] 上传数据到云端...")
            let startTime = Date()
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let elapsed = Date().timeIntervalSince(startTime)
                
                if let error = error {
                    print("❌ 上传失败: \(error.localizedDescription)")
                    completion?(false, error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion?(false, "无效的响应")
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ [5G] 上传成功 (耗时: \(String(format: "%.2f", elapsed))秒)")
                    completion?(true, nil)
                } else {
                    let message = "服务器错误: \(httpResponse.statusCode)"
                    print("❌ \(message)")
                    completion?(false, message)
                }
            }
            
            task.resume()
            
        } catch {
            print("❌ 数据编码失败: \(error)")
            completion?(false, "数据编码失败")
        }
    }
    
    // MARK: - 批量上传
    func uploadReadings(_ readings: [BloodPressureReading], completion: ((Bool, String?) -> Void)? = nil) {
        guard let url = URL(string: "\(baseURL)/blood-pressure/batch") else {
            completion?(false, "无效的 API 地址")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let apiKey = apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(readings)
            request.httpBody = jsonData
            
            print("📤 [5G] 批量上传 \(readings.count) 条记录...")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ 批量上传失败: \(error.localizedDescription)")
                    completion?(false, error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion?(false, "无效的响应")
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ [5G] 批量上传成功")
                    completion?(true, nil)
                } else {
                    completion?(false, "服务器错误")
                }
            }
            
            task.resume()
            
        } catch {
            print("❌ 数据编码失败: \(error)")
            completion?(false, "数据编码失败")
        }
    }
    
    // MARK: - 获取云端数据
    func fetchReadings(completion: @escaping ([BloodPressureReading]?, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/blood-pressure") else {
            completion(nil, "无效的 API 地址")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let apiKey = apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        print("📥 [5G] 从云端获取数据...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 获取失败: \(error.localizedDescription)")
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let data = data else {
                completion(nil, "无数据")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let readings = try decoder.decode([BloodPressureReading].self, from: data)
                print("✅ [5G] 获取成功: \(readings.count) 条记录")
                completion(readings, nil)
            } catch {
                print("❌ 数据解析失败: \(error)")
                completion(nil, "数据解析失败")
            }
        }
        
        task.resume()
    }
    
    // MARK: - 配置 API Key
    func setAPIKey(_ key: String) {
        apiKey = key
        UserDefaults.standard.set(key, forKey: "apiKey")
        print("✅ API Key 已保存")
    }
    
    // MARK: - 同步所有本地数据
    func syncAllLocalData(completion: ((Bool, String?) -> Void)? = nil) {
        let localReadings = BloodPressureReading.load()
        
        guard !localReadings.isEmpty else {
            completion?(true, "无需同步")
            return
        }
        
        uploadReadings(localReadings) { success, error in
            if success {
                print("✅ 所有本地数据已同步到云端")
            }
            completion?(success, error)
        }
    }
    
    // MARK: - 网络状态检测
    func checkNetworkConnection(completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "\(baseURL)/health") else {
            completion(false, "无效的 API 地址")
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5.0)
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                completion(true, "网络连接正常")
            } else {
                completion(false, "服务器无响应")
            }
        }
        
        task.resume()
    }
}
