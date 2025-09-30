import SwiftUI

struct HomeView: View {
    @State private var isTripActive: Bool = false
    @State private var drivingScore: Int = 0
    @State private var distanceCovered: Double = 0.0
    @State private var avgSpeed: Double = 0.0
    @State private var currentSpeed: Double = 0.0
    @State private var acceleration: Double = 0.0
    @State private var loading: Bool = false
    @State private var navigateToProfile: Bool = false
    @StateObject private var driverManager = DriverManager.shared
    
    private func fetchOverview() {
        Task {
            loading = true
            do {
                let response = try await ApiRequest("/telematics/overview")
                
                if let data = response["data"] as? [String: Any] {
                    drivingScore = data["currentScore"] as? Int ?? 0
                    distanceCovered = data["distanceCovered"] as? Double ?? 0.0
                    avgSpeed = data["averageSpeed"] as? Double ?? 0.0
                    currentSpeed = data["currentSpeed"] as? Double ?? 0.0
                    acceleration = data["currentAcceleration"] as? Double ?? 0.0
                    
                    if let status = data["status"] as? String {
                        isTripActive = (status == "active" || status == "in_progress")
                    } else {
                        isTripActive = false
                    }
                } else {
                    drivingScore = 0
                    distanceCovered = 0.0
                    avgSpeed = 0.0
                    currentSpeed = 0.0
                    acceleration = 0.0
                    isTripActive = false
                }
                
            } catch {
                print("🔥 Error fetching overview:", error.localizedDescription)
                
                drivingScore = 0
                distanceCovered = 0.0
                avgSpeed = 0.0
                currentSpeed = 0.0
                acceleration = 0.0
                isTripActive = false
            }
            loading = false
        }
    }
    
    var body: some View {
        NavigationStack {
            MainLayout(
                title: "Driver Performance",
                leftIcon: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title3)
                        .foregroundColor(.primary)
                },
                rightIcon: {
                    if let driver = driverManager.driver {
                        Utils.AvatarNameBadge(
                            name: "\(driver.lastName) \(driver.firstName)",
                            size: 40,
                            fontSize: 16
                        )
                    } else {
                        Utils.AvatarNameBadge(
                            name: "Guest",
                            size: 40,
                            fontSize: 16
                        )
                    }
                },
                onLeftPress: { print("Go back or to Home") },
                onRightPress: {
                    print("Hehh hey ye hey")
                    navigateToProfile = true
                }
            ) {
                ZStack {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            Spacer().frame(height: 10)
                            
                            HStack {
                                Image(systemName: "figure.walk")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(isTripActive ? .green : .gray)
                                
                                Text("Motion State: \(isTripActive ? "Driving" : "Idle")")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(isTripActive ? Color.green.darker() : .gray)
                            }
                            .padding(10)
                            .background((isTripActive ? Color.green : Color.gray).opacity(0.2))
                            .cornerRadius(30)
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Trip Status
                            if isTripActive {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Trip Active")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.top, 10)
                            }
                            
                            VStack {
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                                    Circle()
                                        .trim(from: 0, to: CGFloat(min(Double(drivingScore) / 100.0, 1.0)))
                                        .stroke(Color.green, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                        .rotationEffect(.degrees(-135))
                                        .animation(.easeInOut, value: drivingScore)
                                    
                                    VStack {
                                        Text("Driving Score")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("\(drivingScore)")
                                            .font(.system(size: 36, weight: .bold))
                                        Text("Distance Covered")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.gray)
                                        Text("\(distanceCovered, specifier: "%.1f") KM")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }
                                .frame(width: 220, height: 220)
                            }
                            .padding(.vertical, 20)
                            
                            // Speed & Acceleration
                            HStack(spacing: 40) {
                                VStack {
                                    Image(systemName: "speedometer")
                                        .font(.title)
                                    Text("Speedometer")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(currentSpeed, specifier: "%.1f")")
                                        .font(.system(size: 32, weight: .bold))
                                    Text("KM/H")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack {
                                    Image(systemName: "arrow.up.right.circle")
                                        .font(.title)
                                    Text("Acceleration")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(acceleration, specifier: "%.1f")")
                                        .font(.system(size: 32, weight: .bold))
                                    Text("KPH/s")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 10)
                            
                            Spacer(minLength: 200)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Bottom Sheet
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Average Score")
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                            Text("Today")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(drivingScore)")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Avg. Driving Score")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            VStack {
                                Text("\(avgSpeed, specifier: "%.1f") KM/H")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Average Speed")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            VStack {
                                Text("\(distanceCovered, specifier: "%.1f") KM")
                                    .font(.system(size: 22, weight: .bold))
                                Text("Avg. Distance")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button(action: {
                            print("Navigate to Trip Report")
                        }) {
                            Text("View Trip Report")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(12)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .shadow(radius: 10)
                    .ignoresSafeArea(edges: .bottom)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .onAppear {
                    Task {
                        await driverManager.fetchDriver()
                        fetchOverview()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                ProfileView()
            }
        }
    }
}

#Preview {
    HomeView()
}
