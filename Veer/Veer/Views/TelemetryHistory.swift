//
//  TelemetryHistoryView.swift
//  Veer
//
//  Created by Apple on 9/26/25.
//

import Charts
import SwiftUI

// MARK: - Driving Comments

enum DrivingComments {
    static let poor = [
        "Very Poor Driving – Needs Immediate Attention",
        "Unsafe Driving – Please Slow Down",
        "Critical Driving Issues – Improve Immediately",
    ]
    static let belowAverage = [
        "Below Average – Needs Improvement",
        "Be More Careful on Turns and Brakes",
        "Your driving can be safer – Focus on consistency",
    ]
    static let average = [
        "Average Driving, Be More Cautious",
        "Fair Driving, Some Improvements Needed",
        "Not Bad, But Room for Improvement",
    ]
    static let good = [
        "Good Driving, Needs Minor Improvement",
        "Nice Job – Keep an Eye on Speed",
        "Safe Driving – Almost Excellent",
    ]
    static let excellent = [
        "Excellent Driving Performance",
        "Outstanding Driving – Keep it Up!",
        "Very Safe and Responsible Driving",
    ]

    static func randomComment(for score: Double) -> String {
        switch score {
        case ..<4:
            return poor.randomElement() ?? "Needs major improvement"
        case 4..<6:
            return belowAverage.randomElement() ?? "Needs improvement"
        case 6..<8:
            return average.randomElement() ?? "Average performance"
        case 8..<9:
            return good.randomElement() ?? "Good job, minor improvements"
        default:
            return excellent.randomElement() ?? "Excellent performance"
        }
    }
}

struct TelemetryTrip: Identifiable {
    let id: String
    let startTime: Date
    let endTime: Date
    let drivingScore: Double
    let durationMinutes: Int
    let distanceCoveredKM: Double
    let startAddress: String
    let endAddress: String

    // Derived display values
    var dateString: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: startTime)
    }

    var timeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: startTime)
    }
}

// MARK: - Demo Data

// extension TelemetryTrip {
//    static let demoTrips: [TelemetryTrip] = {
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//
//        func safeDate(_ str: String) -> Date {
//            return formatter.date(from: str) ?? Date()
//        }
//
//        return [
//            TelemetryTrip(
//                id: "68b962562d5900ff5761f1cd",
//                startTime: safeDate("2025-09-04T09:56:37.702Z"),
//                endTime: safeDate("2025-09-04T09:57:12.273Z"),
//                drivingScore: 10,
//                durationMinutes: 1,
//                distanceCoveredKM: 0,
//                startAddress: "H8MH+CVM, Kurukunama 332105, Delta, Nigeria",
//                endAddress: "Sterling Towers, 20 Marina Rd, Lagos Island, Lagos 102273, Lagos, Nigeria"
//            ),
//            TelemetryTrip(
//                id: "68b81fa341456ac855baf8bc",
//                startTime: safeDate("2025-09-03T10:59:46.077Z"),
//                endTime: safeDate("2025-09-03T11:00:55.139Z"),
//                drivingScore: 0,
//                durationMinutes: 1,
//                distanceCoveredKM: 0.561269,
//                startAddress: "110 Magodo Dr, Lagos, Nigeria",
//                endAddress: "110 Magodo Dr, Lagos, Nigeria"
//            ),
//            TelemetryTrip(
//                id: "68b81e4141456ac855bad4e5",
//                startTime: safeDate("2025-09-03T10:53:52.388Z"),
//                endTime: safeDate("2025-09-03T10:56:59.837Z"),
//                drivingScore: 7,
//                durationMinutes: 3,
//                distanceCoveredKM: 3.032214,
//                startAddress: "110 Magodo Dr, Lagos, Nigeria",
//                endAddress: "110 Magodo Dr, Lagos, Nigeria"
//            ),
//        ]
//    }()
// }

// MARK: - TelemetryHistoryView

struct TelemetryHistoryView: View {
    @State private var trips: [TelemetryTrip] = []
    @State private var isLoading = false

    @EnvironmentObject var toast: ToastManager

    private var summary: (score: String, change: Double) {
        guard !trips.isEmpty else { return ("0.0", 0) }

        let avgScore = trips.map { $0.drivingScore }.reduce(0, +) / Double(trips.count)
        let latestChange = trips.count > 1 ? (trips.last!.drivingScore - trips[trips.count - 2].drivingScore) : 0
        return (String(format: "%.1f", avgScore), latestChange)
    }

    private func fetchHistory() {
        Task {
            isLoading = true
            do {
                let response = try await ApiRequest("/telematics/trips/history?limit=100000000")

                if let data = response["data"] as? [String: Any],
                   let tripDicts = data["trips"] as? [[String: Any]]
                {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                    let mappedTrips: [TelemetryTrip] = tripDicts.compactMap { trip in
                        guard
                            let id = trip["_id"] as? String,
                            let startTimeStr = trip["startTime"] as? String,
                            let endTimeStr = trip["endTime"] as? String,
                            let drivingScore = trip["drivingScore"] as? Double,
                            let durationMinutes = trip["durationMinutes"] as? Int,
                            let distanceCoveredKM = trip["distanceCoveredKM"] as? Double,
                            let startLocation = trip["startLocation"] as? [String: Any],
                            let endLocation = trip["endLocation"] as? [String: Any],
                            let startAddress = startLocation["address"] as? String,
                            let endAddress = endLocation["address"] as? String,
                            let startDate = formatter.date(from: startTimeStr),
                            let endDate = formatter.date(from: endTimeStr)
                        else {
                            return nil
                        }

                        return TelemetryTrip(
                            id: id,
                            startTime: startDate,
                            endTime: endDate,
                            drivingScore: drivingScore,
                            durationMinutes: durationMinutes,
                            distanceCoveredKM: distanceCoveredKM,
                            startAddress: startAddress,
                            endAddress: endAddress
                        )
                    }

                    await MainActor.run {
                        self.trips = mappedTrips
                    }
                } else {
                    print("⚠️ Could not parse trips")
                }
            } catch {
                print("🔥 Error fetching history:", error.localizedDescription)
            }
            isLoading = false
        }
    }

    var body: some View {
        MainLayout(
            title: "Telemetry History",
            leftIcon: { Image(systemName: "arrow.left") },
            rightIcon: { Image(systemName: "square.and.arrow.up") },

            onLeftPress: { print("Go back or to Home") },
            onRightPress: { print("Go to Profile screen") }
        ) {
            if isLoading {
                VStack(spacing: 10) {
                    ProgressView()
                    Text("Loading history...")
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    Spacer()
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)

                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Driving Score")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            HStack(spacing: 4) {
                                Text("\(summary.score) Point")
                                    .font(.headline)

                                Text("\(summary.change >= 0 ? "⬆" : "⬇") \(abs(summary.change))% from last trip")
                                    .font(.subheadline)
                                    .foregroundColor(
                                        summary.change >= 0
                                            ? Color(red: 0.176, green: 0.776, blue: 0.325) // #2DC653
                                            : Color(red: 0.941, green: 0.290, blue: 0.290) // #F04A4A
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Right icon in circle
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)

                            Image(systemName: "chevron.right") // ">"
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 5)

                    VStack(spacing: 20) {
                        // Score Summary
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Driving Score")
                                    .font(.headline)
                                Spacer()
                                Text("\(summary.score) Points")
                                    .font(.subheadline)
                                    .foregroundColor(summary.change >= 0 ? .green : .red)
                            }

                            // Use the `Chart(data:)` initializer and explicitly annotate the closure param
                            Chart(trips) { (trip: TelemetryTrip) in
                                LineMark(
                                    x: .value("Date", trip.startTime),
                                    y: .value("Score", trip.drivingScore)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                                PointMark(
                                    x: .value("Date", trip.startTime),
                                    y: .value("Score", trip.drivingScore)
                                )
                                .symbolSize(40)
                                .foregroundStyle(Color.red)
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)

                        // History list
                        VStack(alignment: .leading, spacing: 16) {
                            Text("History")
                                .font(.title3)
                                .fontWeight(.bold)

                            if trips.isEmpty {
                                Text("No history available")
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 30)
                                    .frame(maxWidth: .infinity)
                            } else {
                                ForEach(trips, id: \.id) { trip in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(trip.dateString)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                            Spacer()
                                            Text(trip.timeString)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }

                                        HStack(alignment: .center) {
                                            Circle()
                                                .strokeBorder(Utils.getScoreColor(for: trip.drivingScore), lineWidth: 4)
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Text(String(format: "%.1f", trip.drivingScore))
                                                        .font(.caption)
                                                        .foregroundColor(Utils.getScoreColor(for: trip.drivingScore))
                                                )

                                            VStack(alignment: .leading) {
                                                Text("Performance Review")
                                                    .font(.headline)
                                                Text(DrivingComments.randomComment(for: trip.drivingScore))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .padding(.bottom, 40)
            }
        }
        .overlay(alignment: .top) {
            ToastView(manager: toast)
        }
        .onAppear {
            Task {
                fetchHistory()
            }
        }
    }
}

#Preview {
    TelemetryHistoryView()
        .environmentObject(ToastManager())
}
