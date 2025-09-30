//
//  ResetPasswordView.swift
//  Veer
//
//  Created by Apple on 9/26/25.
//

//
//  ResetPasswordView.swift
//  Veer
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var loading: Bool = false
    @State private var showModal: Bool = true

    @StateObject private var toastManager = ToastManager()

    let otp: String

    // MARK: - Validation

    private var validations: [String: Bool] {
        [
            "8 characters": password.count >= 8,
            "Uppercase": password.range(of: "[A-Z]", options: .regularExpression) != nil,
            "Lowercase": password.range(of: "[a-z]", options: .regularExpression) != nil,
            "Number": password.range(of: "\\d", options: .regularExpression) != nil,
            "Special char": password.range(of: "[\\W_#/@$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
        ]
    }

    private var allValid: Bool {
        validations.values.allSatisfy { $0 }
    }

    private var passwordsMatch: Bool {
        password == confirmPassword && !confirmPassword.isEmpty
    }

    var body: some View {
        NavigationStack {
            ForgotPasswordLayout {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reset Password")
                            .font(.system(size: 28, weight: .bold))

                        Text("Kindly create a new password easy for you to remember")
                            .font(.system(size: 14))
                            .lineSpacing(5)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Password Field
                        VStack(spacing: 15) {
                            HStack {
                                if showPassword {
                                    TextField("New Password", text: $password)
                                        .textInputAutocapitalization(.none)
                                } else {
                                    SecureField("New Password", text: $password)
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Text(showPassword ? "🙈" : "👁️")
                                        .font(.system(size: 18))
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1))

                            // Confirm Password Field
                            HStack {
                                if showConfirmPassword {
                                    TextField("Confirm Password", text: $confirmPassword)
                                        .textInputAutocapitalization(.none)
                                } else {
                                    SecureField("Confirm Password", text: $confirmPassword)
                                }
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Text(showConfirmPassword ? "🙈" : "👁️")
                                        .font(.system(size: 18))
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        }

                        // Validation badges
                        WrapView(items: validations.keys.sorted(), itemStatus: validations)
                            .padding(.top, 5)

                        // Password mismatch
                        if !passwordsMatch && !confirmPassword.isEmpty {
                            Text("Passwords do not match")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }

                        // Submit button
                        Button(action: handleSend) {
                            Text(loading ? "Creating..." : "Create New Password")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(allValid && passwordsMatch ? Color.blue : Color.gray.opacity(0.5))
                                .cornerRadius(30)
                        }
                        .disabled(!allValid || !passwordsMatch || loading)
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    ToastView(manager: toastManager)
                        .padding(.bottom, 20)
                }
            )
            .sheet(isPresented: $showModal) {
                DoneModalView(showModal: $showModal) {
                    // Navigate to Login
                }
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Actions

    private func handleSend() {
        loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Mock API call
            toastManager.show(type: .success, title: "Password Reset", message: "Your password has been updated successfully.")
            showModal = true
            loading = false
        }
    }
}

// MARK: - Badge WrapView

struct WrapView: View {
    let items: [String]
    let itemStatus: [String: Bool]

    var body: some View {
        FlexibleView(
            availableWidth: UIScreen.main.bounds.width - 48,
            data: items,
            spacing: 6,
            alignment: .leading
        ) { item in
            Text(item)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(itemStatus[item]! ? Color.green : Color.gray)
                .cornerRadius(6)
        }
    }
}

// MARK: - FlexibleView Helper for wrapping badges

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    @State private var elementsSize: [Data.Element: CGSize] = [:]

    var body: some View {
        let rows = computeRows()
        return VStack(alignment: alignment, spacing: spacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                            .fixedSize()
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            elementsSize[item] = geo.size
                                        }
                                }
                            )
                    }
                }
            }
        }
    }

    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentWidth: CGFloat = 0

        for item in data {
            let size = elementsSize[item, default: CGSize(width: 50, height: 20)]
            if currentWidth + size.width + spacing > availableWidth {
                rows.append([item])
                currentWidth = size.width + spacing
            } else {
                rows[rows.count - 1].append(item)
                currentWidth += size.width + spacing
            }
        }
        return rows
    }
}

#Preview {
    ResetPasswordView(otp: "123456")
}
