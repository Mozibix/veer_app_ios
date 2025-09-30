import Combine
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isLoggedIn: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private init() {
        isLoggedIn = AuthStorage.shared.authToken != nil
    }

    func login(authToken: String, refreshToken: String, userId: String? = nil) {
        AuthStorage.shared.authToken = authToken
        AuthStorage.shared.refreshToken = refreshToken
        AuthStorage.shared.userId = userId
        isLoggedIn = true
    }

    func logout() {
        AuthStorage.shared.clear()
        isLoggedIn = false
    }
}
