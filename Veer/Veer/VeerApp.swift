//
//  VeerApp.swift
//  Veer
//
//  Created by Apple on 9/17/25.
//

import SwiftUI

@main
struct VeerApp: App {
    @StateObject private var session = SessionManager.shared

    var body: some Scene {
        WindowGroup {
            if session.isLoggedOut || AuthStorage.shared.authToken == nil {
                LoginView()
            } else {
                HomeView()
            }
        }
    }
}
