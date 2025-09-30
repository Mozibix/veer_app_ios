//
//  Colors.swift
//  Veer
//
//  Created by Apple on 9/23/25.
//

import SwiftUI

extension Color {
    static let primaryColor = Color(hex: "#E21C37")
    static let whiteColor = Color(hex: "#FFFFFF")
    static let blackColor = Color(hex: "#000000")
    static let greenColor = Color(hex: "#23CE6B")

    static let grayDark = Color(hex: "#505959")
    static let grayMedium = Color(hex: "#8E9A9A")
    static let grayText = Color(hex: "#404040")
    static let grayBorder = Color(hex: "#DDDDDD")

    static let backgroundLight = Color(hex: "#F8EDF0")
    static let backgroundBadge = Color(hex: "#FBF0F2")
    static let greenTransparent = Color(hex: "#23CE6B").opacity(0.1)

    static let tabBgColor = Color(red: 0.973, green: 0.929, blue: 0.941) // #F8EDF0
    static let passedBgColor = Color(red: 0.137, green: 0.808, blue: 0.42, opacity: 0.1)
}

// Helper for hex strings
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: .whitespacesAndNewlines))
        if hex.hasPrefix("#") { scanner.currentIndex = scanner.string.index(after: scanner.currentIndex) }

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
