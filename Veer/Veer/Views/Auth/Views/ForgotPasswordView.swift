//
//  ForgotPasswordView.swift
//  Veer
//
//  Created by Apple on 9/26/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = "@"
    @State private var showModal: Bool = false
    @State private var loading: Bool = false

    @StateObject private var toastManager = ToastManager()

    var isEmailValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && email.contains("@")
    }

    var body: some View {
        NavigationStack {
            ForgotPasswordLayout {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Forgot Password?")
                            .font(.system(size: 30, weight: .bold))

                        Text("Please provide the email address associated with your account below to receive OTP for password reset.")
                            .font(.system(size: 16))
                            .lineSpacing(6)

                        // Email input
                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )

                        // Proceed button
                        Button(action: handleSend) {
                            HStack {
                                if loading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(loading ? "Sending..." : "Proceed")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isEmailValid ? Color.primaryColor : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .opacity(!isEmailValid || loading ? 0.6 : 1)
                        }
                        .disabled(!isEmailValid || loading)
                    }
                }
                .padding(20)
            }

            .overlay(
                VStack {
                    Spacer()
                    ToastView(manager: toastManager)
                        .padding(.bottom, 20)
                }
            )
            .sheet(isPresented: $showModal) {
                EmailNotFoundModal(showModal: $showModal)
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func handleSend() {
        loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if email == "found@mail.com" {
                toastManager.show(
                    type: .success,
                    title: "OTP Sent",
                    message: "We’ve sent an OTP to \(email)"
                )
            } else {
                showModal = true
                toastManager.show(
                    type: .error,
                    title: "Email Not Found",
                    message: "No account is linked to \(email)"
                )
            }
            loading = false
        }
    }
}

#Preview {
    ForgotPasswordView()
}
