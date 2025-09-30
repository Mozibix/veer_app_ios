import SwiftUI

struct Certification: Identifiable {
    let id: String
    let title: String
    let status: String
    let score: String
}

struct ProfileView: View {
    @StateObject private var driverManager = DriverManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var activeTab: String = "performance"
    @State private var slideOffset: CGFloat = 0
    
    @State private var updatedPassword = false
    @State private var updatePhoneNumber = false
    @State private var navigateToHome: Bool = false
    @State private var navigateToLogin: Bool = false
    
    let certifications: [Certification] = [
        Certification(
            id: "1",
            title: "Driving School Standardization Certification",
            status: "Passed",
            score: "80%"
        ),
        Certification(
            id: "2",
            title: "Emergency Driving Basics",
            status: "Passed",
            score: "87%"
        )
    ]
    
    var body: some View {
        NavigationStack {
            MainLayout(
                title: "Profile",
                leftIcon: { Image(systemName: "arrow.left") },
                rightIcon: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                },
                onLeftPress: {
                    navigateToHome = true
                },
                onRightPress: {
                    Task {
                        await driverManager.logout()
                        dismiss()
                    }
                    navigateToLogin = true
                }
            ) {
                VStack {
                    // Profile
                    VStack(spacing: 6) {
                        if let driver = driverManager.driver {
                            Utils.AvatarNameBadge(
                                name: "\(driver.firstName) \(driver.lastName)",
                                size: 80,
                                fontSize: 24
                            )
                            
                            if driverManager.isLoading {
                                ProgressView()
                            } else {
                                Text("\(driver.firstName) \(driver.lastName)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.blackColor)
                                Text(driver.emailAddress)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Utils.AvatarNameBadge(
                                name: "Guest",
                                size: 80,
                                fontSize: 24
                            )
                            
                            if driverManager.isLoading {
                                ProgressView()
                            } else {
                                Text("Guest User")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.blackColor)
                                Text("No email available")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Tabs
                    HStack(spacing: 0) {
                        Button(action: { switchTab("performance") }) {
                            Text("Performances")
                                .font(.system(size: 14, weight: activeTab == "performance" ? .bold : .regular))
                                .foregroundColor(activeTab == "performance" ? .blackColor : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    ZStack {
                                        if activeTab == "performance" {
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.white)
                                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                                        }
                                    }
                                )
                        }
                        
                        Button(action: { switchTab("settings") }) {
                            Text("Account Settings")
                                .font(.system(size: 14, weight: activeTab == "settings" ? .bold : .regular))
                                .foregroundColor(activeTab == "settings" ? .blackColor : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    ZStack {
                                        if activeTab == "settings" {
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.white)
                                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                                        }
                                    }
                                )
                        }
                    }
                    .padding(6)
                    .background(Color.tabBgColor)
                    .cornerRadius(24)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Content slider
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            // Performance Tab
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Certifications")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.blackColor)
                                    
                                    ForEach(certifications) { item in
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack(spacing: 10) {
                                                Circle()
                                                    .fill(Color.primaryColor.opacity(0.1))
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Image(systemName: "checkmark.seal.fill")
                                                            .foregroundColor(.primaryColor)
                                                    )
                                                Text(item.title)
                                                    .font(.system(size: 15, weight: .bold))
                                                    .foregroundColor(.blackColor)
                                                Spacer()
                                            }
                                            
                                            HStack {
                                                HStack(spacing: 10) {
                                                    Circle()
                                                        .fill(Color.greenColor)
                                                        .frame(width: 10, height: 10)
                                                    Text(item.status)
                                                        .foregroundColor(.greenColor)
                                                        .font(.system(size: 14, weight: .bold))
                                                    Text(item.score)
                                                        .foregroundColor(.blackColor.opacity(0.6))
                                                }
                                                
                                                Spacer()
                                                Button(action: {
                                                    print("Navigate to Performance Report")
                                                }) {
                                                    Text("View Performance")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.primaryColor)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color.whiteColor)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.blackColor.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                }
                                .padding()
                            }
                            .frame(width: geometry.size.width)
                            
                            // Settings Tab
                            ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                    settingsButton(title: "Update Password") {
                                        updatedPassword = true
                                    }
                                    settingsButton(title: "Update Phone Number") {
                                        updatePhoneNumber = true
                                    }
                                }
                                .padding(.top, 16)
                                .padding(.horizontal)
                            }
                            .frame(width: geometry.size.width)
                        }
                        .frame(width: geometry.size.width * 2, alignment: .leading)
                        .offset(x: slideOffset)
                        .animation(.easeInOut(duration: 0.3), value: slideOffset)
                    }
                }
                .sheet(isPresented: $updatedPassword) {
                    UpdatePasswordModal(isPresented: $updatedPassword)
                        .presentationDetents([.fraction(0.7)])
                        .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $updatePhoneNumber) {
                    UpdatePhoneNumberModal(isPresented: $updatePhoneNumber)
                        .presentationDetents([.fraction(0.7)])
                        .presentationDragIndicator(.visible)
                }
                .navigationDestination(isPresented: $navigateToLogin) {
                    LoginView()
                }
                .navigationDestination(isPresented: $navigateToHome) {
                    HomeView()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func switchTab(_ tab: String) {
        activeTab = tab
        slideOffset = tab == "performance" ? 0 : -UIScreen.main.bounds.width
    }
    
    private func settingsButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blackColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.whiteColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ProfileView()
}
