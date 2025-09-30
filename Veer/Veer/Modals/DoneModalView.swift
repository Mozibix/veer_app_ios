import SwiftUI

struct DoneModalView: View {
    @Binding var showModal: Bool
    var onLogin: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showModal = false }
                }

            VStack(spacing: 20) {
                VStack(spacing: 20) {
                    Image(Assets.doneIcon)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .scaleEffect(scale)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5)) { scale = 1 }
                            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                scale = 1.05
                            }
                            withAnimation(.easeIn(duration: 0.3)) { opacity = 1 }
                        }

                    Text("Done!")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)

                    Text("Your password has been reset successfully. Kindly proceed to login with your new password.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Button(action: {
                        withAnimation { showModal = false }
                        onLogin()
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(radius: 10)
                .opacity(opacity)
                .transition(.move(edge: .bottom))
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
