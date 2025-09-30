//
//  ToastManager.swift
//  Veer
//
//  Created by Apple on 9/26/25.
//

import SwiftUI

enum ToastType {
    case success, error, info, warning

    var colors: (bg: Color, darkBg: Color, text: Color) {
        switch self {
        case .success:
            return (Color(hex: "#08CF5A"), Color(hex: "#059647"), .white)
        case .error:
            return (Color(hex: "#EF4444"), Color(hex: "#991B1B"), .white)
        case .info:
            return (Color(hex: "#3B82F6"), Color(hex: "#1E3A8A"), .white)
        case .warning:
            return (Color(hex: "#FACC15"), Color(hex: "#854D0E"), .black)
        }
    }
}

struct ToastModel {
    let type: ToastType
    let title: String
    let message: String
}

class ToastManager: ObservableObject {
    @Published var toast: ToastModel?
    @Published var isVisible = false

    func show(type: ToastType, title: String, message: String) {
        toast = ToastModel(type: type, title: title, message: message)
        withAnimation(.spring()) {
            isVisible = true
        }

        // Auto-dismiss after 4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation {
                self.isVisible = false
            }
        }
    }
}

struct ToastView: View {
    @ObservedObject var manager: ToastManager
    @State private var progress: CGFloat = 1.0

    var body: some View {
        if let toast = manager.toast, manager.isVisible {
            HStack(spacing: 12) {
                // Leading circle (optional)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                        .shadow(radius: 3)

                    Text("x")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }

                // Title + Message
                VStack(alignment: .leading, spacing: 2) {
                    Text(toast.title)
                        .font(.headline)
                        .foregroundColor(toast.type.colors.text)
                    Text(toast.message)
                        .font(.caption)
                        .foregroundColor(toast.type.colors.text)
                }
                .padding(.leading, 4)

                Spacer()

                // Close button
                Button {
                    withAnimation {
                        manager.isVisible = false
                    }
                } label: {
                    Text("×")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(toast.type.colors.text)
                        .padding(8)
                        .background(toast.type.colors.darkBg)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .background(toast.type.colors.bg)
            .cornerRadius(12)
            .overlay(
                GeometryReader { geo in
                    Rectangle()
                        .fill(toast.type.colors.text.opacity(0.8))
                        .frame(width: geo.size.width * progress, height: 4)
                        .position(x: geo.size.width / 2, y: geo.size.height - 2)
                }
            )
            .padding(.horizontal, 40)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
                progress = 1.0
                withAnimation(.linear(duration: 4)) {
                    progress = 0.0
                }
            }
            .zIndex(99)
        }
    }
}
