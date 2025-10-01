//
//  MainLayout.swift
//  Veer
//
//  Created by Apple on 9/23/25.
//

import SwiftUI

// MARK: - Header

struct Header<LeftIcon: View, RightIcon: View>: View {
    var title: String
    var leftIcon: (() -> LeftIcon)?
    var rightIcon: (() -> RightIcon)?
    var onLeftPress: (() -> Void)?
    var onRightPress: (() -> Void)?

    var body: some View {
        HStack {
            // Left icon
            if let leftIcon = leftIcon {
                Button(action: { onLeftPress?() }) {
                    leftIcon()
                        .frame(width: 24, height: 24)
                }
            } else {
                Spacer().frame(width: 24)
            }

            Spacer()

            NavigationLink(destination: HomeView()) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            // Right icon
            if let rightIcon = rightIcon {
                Button(action: { onRightPress?() }) {
                    rightIcon()
                        .frame(width: 24, height: 24)
                }
            } else {
                Spacer().frame(width: 24)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 2)
    }
}

// MARK: - MainLayout

struct MainLayout<Content: View, LeftIcon: View, RightIcon: View>: View {
    var title: String
    var leftIcon: (() -> LeftIcon)?
    var rightIcon: (() -> RightIcon)?
    var onLeftPress: (() -> Void)?
    var onRightPress: (() -> Void)?
    var content: Content

    init(
        title: String,
        leftIcon: (() -> LeftIcon)? = nil,
        rightIcon: (() -> RightIcon)? = nil,
        onLeftPress: (() -> Void)? = nil,
        onRightPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.onLeftPress = onLeftPress
        self.onRightPress = onRightPress
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            Header(
                title: title,
                leftIcon: leftIcon,
                rightIcon: rightIcon,
                onLeftPress: onLeftPress,
                onRightPress: onRightPress
            )
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
