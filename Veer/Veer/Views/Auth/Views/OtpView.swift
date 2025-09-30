import SwiftUI

struct OtpView: View {
    @State private var email: String
    @State private var otp: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State private var loading: Bool = false
    @State private var resendTimer: Int = 0
    @State private var resending: Bool = false
    
    @StateObject private var toastManager = ToastManager()
    
    init(email: String = "") {
        _email = State(initialValue: email)
    }
    
    private var isOtpValid: Bool {
        otp.allSatisfy { !$0.isEmpty }
    }
    
    var body: some View {
        NavigationStack {
            ForgotPasswordLayout {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text("Enter OTP")
                            .font(.system(size: 28, weight: .bold))
                        
                        // Subtitle
                        Text("Please provide the OTP shared with \(email.isEmpty ? "your email" : email)")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .lineSpacing(5)
                        
                        // OTP HStack
                        HStack(spacing: 12) {
                            ForEach(0 ..< 6, id: \.self) { index in
                                TextField("", text: $otp[index])
                                    .focused($focusedIndex, equals: index)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 20, weight: .semibold))
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(otp[index].isEmpty ? Color.gray.opacity(0.5) : Color.green, lineWidth: 2)
                                            .background(Color.white.cornerRadius(10))
                                    )
                                    .onChange(of: otp[index]) { _, newValue in
                                        if newValue.count > 1 { otp[index] = String(newValue.last!) }
                                        if !newValue.isEmpty && index < 5 {
                                            focusedIndex = index + 1
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        
                        // Resend OTP
                        HStack {
                            Text("Didn't get the code?")
                                .font(.system(size: 16))
                            Button(action: handleResendOtp) {
                                Text(resendTimer > 0 ? "Resend in \(resendTimer)s" : "Resend")
                                    .foregroundColor(resendTimer > 0 ? .gray : .blue)
                            }
                            .disabled(resendTimer > 0 || resending)
                        }
                        
                        // Change Email
                        Button(action: {
                            // navigate back
                        }) {
                            Text("Not sure of the address? Change Email Address")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                        
                        // Proceed Button
                        Button(action: handleSend) {
                            Text(loading ? "Verifying..." : "Proceed")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isOtpValid ? Color.primaryColor : Color.gray.opacity(0.5))
                                .cornerRadius(30)
                        }
                        .disabled(!isOtpValid || loading)
                        .padding(.top, 10)
                        
                        Spacer()
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
                        .zIndex(999)
                }
            )
            .navigationBarHidden(true)
            .onAppear { startResendTimer() }
        }
    }
    
    private func handleSend() {
        loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if otp.joined() == "123456" {
                toastManager.show(type: .success, title: "OTP Verified", message: "You may now reset your password.")
            } else {
                toastManager.show(type: .error, title: "Invalid OTP", message: "Please check the code and try again.")
            }
            loading = false
        }
    }
    
    private func handleResendOtp() {
        resending = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            toastManager.show(type: .success, title: "OTP Sent", message: "A new OTP has been sent to your email")
            resendTimer = 30
            startResendTimer()
            resending = false
        }
    }
    
    private func startResendTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if resendTimer > 0 {
                resendTimer -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    OtpView(email: "example@mail.com")
}
