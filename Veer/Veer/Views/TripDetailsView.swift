import SwiftUI

struct TripDetailsModel: Identifiable {
    let id: String
    let drivingScore: Double
    let startAddress: String
    let endAddress: String
    let startTime: Date
    let endTime: Date
    let distanceKM: Double
    let durationMinutes: Int
    let averageSpeed: Double
    let maxSpeed: Double
    let safetyEvents: [[String: Any]]
}

struct TripDetailsView: View {
    @State private var loading: Bool = false
    @State private var trip: TripDetailsModel?

    private func fetchTripDetails() {
        Task {
            loading = true
            do {
                let response = try await ApiRequest("/telematics/trips")

                if let data = response["data"] as? [String: Any],
                   let id = data["_id"] as? String,
                   let score = data["drivingScore"] as? Double,
                   let start = data["startLocation"] as? [String: Any],
                   let end = data["endLocation"] as? [String: Any],
                   let startAddr = start["address"] as? String,
                   let endAddr = end["address"] as? String,
                   let startTimeStr = data["startTime"] as? String,
                   let endTimeStr = data["endTime"] as? String,
                   let distance = data["distanceCoveredKM"] as? Double,
                   let duration = data["durationMinutes"] as? Int,
                   let avgSpeed = data["averageSpeedKPH"] as? Double,
                   let maxSpeed = data["maxSpeedKPH"] as? Double,
                   let safetyEvents = data["safetyEvents"] as? [[String: Any]]
                {
                    let formatter = ISO8601DateFormatter()
                    let startDate = formatter.date(from: startTimeStr) ?? Date()
                    let endDate = formatter.date(from: endTimeStr) ?? Date()

                    self.trip = TripDetailsModel(
                        id: id,
                        drivingScore: score,
                        startAddress: startAddr,
                        endAddress: endAddr,
                        startTime: startDate,
                        endTime: endDate,
                        distanceKM: distance,
                        durationMinutes: duration,
                        averageSpeed: avgSpeed,
                        maxSpeed: maxSpeed,
                        safetyEvents: safetyEvents
                    )
                }
            } catch {
                print("🔥 Error fetching trip details:", error.localizedDescription)
            }
            loading = false
        }
    }

    var body: some View {
        MainLayout(
            title: "Trip Details",
            leftIcon: { Image(systemName: "arrow.left") },
            rightIcon: { Image(systemName: "square.and.arrow.up") },
            onLeftPress: { print("Go back") },
            onRightPress: { print("Share Trip Report") }
        ) {
            ScrollView {
                if let trip = trip {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Circle()
                                    .strokeBorder(Utils.getScoreColor(for: trip.drivingScore), lineWidth: 4)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text(String(format: "%.1f", trip.drivingScore))
                                            .font(.caption)
                                            .foregroundColor(Utils.getScoreColor(for: trip.drivingScore))
                                    )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Performance Overview")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(trip.drivingScore >= 8 ? "Excellent Driving!" : "Fair Driving Performance!")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Label(trip.startAddress, systemImage: "mappin.and.ellipse")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(formatTime(trip.startTime))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                HStack {
                                    Label(trip.endAddress, systemImage: "mappin.and.ellipse")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(formatTime(trip.endTime))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }

                            Divider()

                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Distance Covered")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("\(trip.distanceKM, specifier: "%.1f") KM")
                                            .font(.headline)
                                    }
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        Text("Trip Duration")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("\(trip.durationMinutes) Minutes")
                                            .font(.headline)
                                    }
                                }

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Average Speed")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("\(trip.averageSpeed, specifier: "%.0f") KM/H")
                                            .font(.headline)
                                    }
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        Text("Maximum Speed")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("\(trip.maxSpeed, specifier: "%.0f") KM/H")
                                            .font(.headline)
                                    }
                                }
                            }
                            .padding(.top, 16)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)

                        if !trip.safetyEvents.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(trip.safetyEvents.indices, id: \.self) { i in
                                    let event = trip.safetyEvents[i]
                                    SafetyEventRow(
                                        icon: "exclamationmark.triangle.fill",
                                        color: .red,
                                        title: event["type"] as? String ?? "Unknown Event",
                                        count: event["count"] as? Int ?? 0
                                    )
                                    if i != trip.safetyEvents.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Driving Tip", systemImage: "lightbulb.fill")
                                .font(.headline)
                                .foregroundColor(.blue)

                            Text(trip.drivingScore >= 8
                                ? "Fantastic job today! Keep maintaining smooth acceleration and gentle braking."
                                : "Work on smoother acceleration and braking to improve your score.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)

                        VStack(spacing: 12) {
                            Button(action: {}) {
                                Text("See All History")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(25)
                            }

                            Button(action: {}) {
                                Text("Share Report")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.red, lineWidth: 1.5)
                                    )
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                } else if loading {
                    Color.white.opacity(0.8)
                        .ignoresSafeArea()

                    ProgressView("Loading Trip Details...")
                        .font(.headline)
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else {
                    Text("No Trip Data Available")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .background(Color.white)
            .onAppear { fetchTripDetails() }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter.string(from: date)
    }
}

struct SafetyEventRow: View {
    var icon: String
    var color: Color
    var title: String
    var count: Int

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                Text("\(count) Events")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("See Details")
                .font(.caption)
                .foregroundColor(.gray)
            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}

#Preview {
    TripDetailsView()
}
