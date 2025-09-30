import SwiftUI

struct UpdatePasswordModal: View {
    @Binding var isPresented: Bool
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Update Account Password")
                    .font(.title3.bold())
                    .padding(.top, 10)
                
                SecureField("Current Password", text: $currentPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: updatePassword) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Update Password")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(isLoading)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("Close") {
                isPresented = false // ✅ will now dismiss
            })
        }
    }
    
    private func updatePassword() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            isPresented = false
        }
    }
}
