//
//  ApiService.swift
//  Veer
//

import Foundation
import SwiftUI

let API_BASE_URL = "https://veer-niq4.onrender.com/api/v1"

class AuthStorage {
    static let shared = AuthStorage()
    private init() {}

    private let authTokenKey = "authToken"
    private let refreshTokenKey = "refreshToken"
    private let userIdKey = "userId"

    var authToken: String? {
        get { UserDefaults.standard.string(forKey: authTokenKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: authTokenKey) }
    }

    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshTokenKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: refreshTokenKey) }
    }

    var userId: String? {
        get { UserDefaults.standard.string(forKey: userIdKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: userIdKey) }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: authTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}

// MARK: - Global Logout Notifier

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    @Published var isLoggedOut: Bool = false

    func logout() {
        DispatchQueue.main.async {
            AuthStorage.shared.clear()
            self.isLoggedOut = true
        }
    }
}

// MARK: - Generic API Request

@discardableResult
func ApiRequest(
    _ endpoint: String,
    _ method: String = "GET",
    _ body: [String: Any]? = nil
) async throws -> [String: Any] {
    guard let url = URL(string: API_BASE_URL + endpoint) else {
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // ✅ Automatically attach token if available
    if let token = AuthStorage.shared.authToken {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    // Encode body
    if let body = body {
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    }

    print("➡️ API Request: \(method) \(url.absoluteString)")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }

    // ❌ Unauthorized → clear session + notify app
    if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
        SessionManager.shared.logout()
        throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
            NSLocalizedDescriptionKey: "Session Expired. Please login again."
        ])
    }

    if !(200 ... 299).contains(httpResponse.statusCode) {
        let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        let message = errorJson?["message"] as? String ?? "Request failed"
        throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
            NSLocalizedDescriptionKey: message
        ])
    }

    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    return json ?? [:]
}

func ApiRequestDecodable<T: Decodable>(
    _ endpoint: String,
    _ method: String = "GET",
    _ body: [String: Any]? = nil,
    as type: T.Type
) async throws -> T {
    let raw = try await ApiRequest(endpoint, method, body)
    let data = try JSONSerialization.data(withJSONObject: raw, options: [])
    return try JSONDecoder().decode(T.self, from: data)
}
