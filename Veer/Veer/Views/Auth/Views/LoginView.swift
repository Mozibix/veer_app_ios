//
//  LoginView.swift
//  Veer
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = "emaye@mailinator.com"
    @State private var password: String = "Emaye11@@"
    @State private var showPassword: Bool = false
    @State private var loading: Bool = false
    @State private var navigateHome: Bool = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case ..<12: return "Good Morning 👋"
        case ..<17: return "Good Afternoon ☀️"
        case ..<21: return "Good Evening 🌆"
        default: return "Good Night 🌙"
        }
    }

    private func handleLogin() {
        Task {
            guard !email.isEmpty else {
                print("❌ Missing Email")
                return
            }
            guard !password.isEmpty else {
                print("❌ Missing Password")
                return
            }

            loading = true
            do {
                let response = try await ApiRequest(
                    "/driver/login",
                    "POST",
                    [
                        "emailAddress": email,
                        "password": password
                    ]
                )

                if let data = response["data"] as? [String: Any],
                   let authToken = data["authToken"] as? String,
                   let refreshToken = data["refreshToken"] as? String
                {
                    Logger.log("Full Process Data", data)
                    AuthStorage.shared.authToken = authToken
                    AuthStorage.shared.refreshToken = refreshToken

                    print("✅ Login Success")
                    navigateHome = true
                } else {
                    print("❌ Invalid login response")
                }

            } catch {
                print("🔥 Login Error:", error.localizedDescription)
            }
            loading = false
        }
    }

    var body: some View {
        NavigationStack {
            AuthLayout {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Greeting
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)

                            Text("Login to your veer account")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 20)

                        // Email field
                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.6)))
                            .font(.system(size: 16))

                        // Password field
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                                    .font(.system(size: 16))
                            } else {
                                SecureField("Password", text: $password)
                                    .font(.system(size: 16))
                            }

                            Button {
                                showPassword.toggle()
                            } label: {
                                Text(showPassword ? "🙈" : "👁️")
                                    .font(.system(size: 18))
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.6)))

                        // Forgot password

                        HStack {
                            Spacer()
                            NavigationLink(destination: ForgotPasswordView()) {
                                Text("Forgot password?")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.top, 15)

                        // Login button
                        Button {
                            handleLogin()
                        } label: {
                            Text(loading ? "Logging in..." : "Login")
                                .foregroundColor(.whiteColor)
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primaryColor)
                                .cornerRadius(30)
                        }
                        .disabled(loading)
                        .opacity(loading ? 0.6 : 1.0)

                        // Footer
                        Text("Contact Support for Enquiries")
                            .foregroundColor(Color(red: 0.56, green: 0.60, blue: 0.60))
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 30)
                    }
                    .padding(.horizontal, 5)
                }
            }
            .navigationDestination(isPresented: $navigateHome) {
                HomeView()
            }
        }
    }
}

#Preview { LoginView() }
