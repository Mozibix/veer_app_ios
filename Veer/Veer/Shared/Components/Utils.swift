//
//  Utils.swift
//  Veer
//
//  Created by Apple on 9/23/25.
//

import SwiftUI

enum Utils {
    struct AvatarNameBadge: View {
        var name: String
        var size: CGFloat = 40
        var fontSize: CGFloat = 16

        private var initials: String {
            let parts = name.split(separator: " ")
            let first = parts.first?.prefix(1) ?? ""
            let last = parts.dropFirst().first?.prefix(1) ?? ""
            return "\(first)\(last)".uppercased()
        }

        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: size, height: size)
                Text(initials)
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }

    struct RoundedCorner: Shape {
        var radius: CGFloat = .infinity
        var corners: UIRectCorner = .allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }

    static func getScoreColor(for score: Double) -> Color {
        if score >= 9 {
            return Color(red: 0.176, green: 0.776, blue: 0.325) // #2DC653
        } else if score >= 7 {
            return Color(red: 0.957, green: 0.639, blue: 0.0) // #F4A300
        } else {
            return Color(red: 0.941, green: 0.290, blue: 0.290) // #F04A4A
        }
    }
}

extension Color {
    func darker(by percentage: Double = 30.0) -> Color {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        return Color(
            red: max(r - CGFloat(percentage/100), 0.0),
            green: max(g - CGFloat(percentage/100), 0.0),
            blue: max(b - CGFloat(percentage/100), 0.0)
        )
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(Utils.RoundedCorner(radius: radius, corners: corners))
    }
}
