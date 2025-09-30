import Foundation
import SwiftUI

// MARK: - Driver Model

struct Driver: Codable, Identifiable {
    var id: String
    var _id: String
    var firstName: String
    var lastName: String
    var emailAddress: String
    var corporateId: String
    var companyName: String
    var role: String
    var department: String
    var certification: String
    var status: String
    var companyLogo: String?
}

// MARK: - Global Driver Manager

@MainActor
class DriverManager: ObservableObject {
    static let shared = DriverManager() // Singleton

    @Published var driver: Driver? = nil
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false

    private init() {
        Task {
            await loadDriverFromCache()
        }
    }

    // MARK: - Fetch Driver Details (Always fetches from API)

    func fetchDriver() async {
        isLoading = true
        do {
            let response = try await ApiRequestDecodable("/driver/details", "GET", as: DriverResponse.self)
            driver = response.data
            isAuthenticated = true
            try await saveDriverToCache(response.data)
            print("✅ Driver fetched successfully: \(response.data.firstName) \(response.data.lastName)")
        } catch {
            print("❌ Failed to fetch driver: \(error)")
            await logout()
        }
        isLoading = false
    }

    // MARK: - Logout & Clear

    func logout() async {
        driver = nil
        isAuthenticated = false
        await TokenStorage.shared.clear()
        await clearDriverFromCache()
        print("🔓 Driver logged out and cache cleared")
    }
}

// MARK: - API Response Shape

struct DriverResponse: Codable {
    var code: Int
    var status: String
    var data: Driver
}

// MARK: - Storage Helpers

extension DriverManager {
    private func saveDriverToCache(_ driver: Driver) async throws {
        let data = try JSONEncoder().encode(driver)
        UserDefaults.standard.set(data, forKey: "driverData")
    }

    private func loadDriverFromCache() async {
        if let data = UserDefaults.standard.data(forKey: "driverData") {
            if let decoded = try? JSONDecoder().decode(Driver.self, from: data) {
                driver = decoded
                isAuthenticated = true
                print("📦 Driver loaded from cache: \(decoded.firstName) \(decoded.lastName)")
            }
        }
    }

    private func clearDriverFromCache() async {
        UserDefaults.standard.removeObject(forKey: "driverData")
    }
}

// MARK: - Token Storage

actor TokenStorage {
    static let shared = TokenStorage()

    func clear() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
    }
}
