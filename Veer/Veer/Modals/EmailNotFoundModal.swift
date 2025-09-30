//
//  EmailNotFoundModal.swift
//  Veer
//
//  Created by Apple on 9/26/25.
//

import SwiftUI

struct EmailNotFoundModal: View {
    @Binding var showModal: Bool
    @State private var scale: CGFloat = 0.5
    @State private var animate: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Image(Assets.closeIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5)) {
                        scale = 1
                    }
                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        scale = 1.05
                    }
                }

            Text("Email not found!")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.black)

            Text("We couldn't find any associated account to the email provided")
                .font(.system(size: 16))
                .foregroundColor(Color.grayMedium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                showModal = false
            }) {
                Text("Try again")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryColor)
                    .cornerRadius(24)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
