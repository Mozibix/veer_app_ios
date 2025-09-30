import SwiftUI

struct SignupView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var goToHome: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sign Up")
                    .font(.largeTitle)
                    .bold()

                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Create Account") {
                    goToHome = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationDestination(isPresented: $goToHome) {
                HomeView()
            }
        }
    }
}

#Preview { SignupView() }

// Light mode
#Preview("Light Mode", traits: .sizeThatFitsLayout) {
    SignupView()
        .preferredColorScheme(.light)
}

// Dark mode
#Preview("Dark Mode", traits: .sizeThatFitsLayout) {
    SignupView()
        .preferredColorScheme(.dark)
}

// Accessibility dynamic type
#Preview("Large Text", traits: .sizeThatFitsLayout) {
    SignupView()
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

// Landscape layout
#Preview("Landscape", traits: .landscapeLeft) {
    SignupView()
}
