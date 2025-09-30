import SwiftUI

struct ForgotPasswordLayout<Content: View>: View {
    let content: Content
    @Environment(\.presentationMode) var presentationMode

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // Margin from bottom so content won't overlap footer + logo
    private let bottomMargin: CGFloat = 120

    var body: some View {
        ZStack {
            // Top image with icons
            VStack(spacing: 0) {
                ZStack {
                    Image(Assets.truckImg)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 400)
                        .clipped()

                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(Assets.icon11)
                                .resizable()
                                .frame(width: 36, height: 36)
                        }

                        Spacer()

                        Image(Assets.logoFavicon)
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                    .padding(35)
                    .offset(y: -30)
                }
                Spacer()
            }
            .ignoresSafeArea()

            // White card content
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        content
                    }
                    .padding(25)
                    .padding(.bottom, bottomMargin) // ensures content won't touch footer
                }
                .background(Color.white)
                .cornerRadius(65)
                .shadow(color: Color.black.opacity(0.2),
                        radius: 4, x: 0, y: 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .offset(y: UIScreen.main.bounds.height * 0.3)

            // Bottom section: footer text + transparent logo
            VStack(spacing: 8) {
                Spacer()
                Text("Contact Support for Enquiries")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.grayMedium)
                Image(Assets.logoTransparent)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.08)
            }
            .padding(.bottom, 10)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
}
