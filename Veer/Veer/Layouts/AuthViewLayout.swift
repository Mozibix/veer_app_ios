import SwiftUI

struct AuthLayout<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top image with logo
                ZStack {
                    Image(Assets.truckImg)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 400)
                        .clipped()

                    Image(Assets.logoNormal)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.32,
                               height: UIScreen.main.bounds.height * 0.12)
                        .offset(y: UIScreen.main.bounds.height * -0.06)
                }
                .ignoresSafeArea()
                Spacer()
            }

            VStack {
                content
            }
            .padding(50)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .cornerRadius(65)
            .shadow(color: Color.black.opacity(0.2),
                    radius: 4, x: 0, y: 2)
            .offset(y: UIScreen.main.bounds.height * 0.3)

            VStack {
                Spacer()
                Image(Assets.logoTransparent)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.08)
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
}
