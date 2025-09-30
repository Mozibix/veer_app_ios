import SwiftUI

struct TripDetailsView: View {
    var body: some View {
        MainLayout(
            title: "Trip Details",
            leftIcon: { Image(systemName: "arrow.left") },
            rightIcon: { Image(systemName: "square.and.arrow.up") },
            onLeftPress: { print("Go back or to Home") },
            onRightPress: { print("Share Trip Report") }
        ) {
            ScrollView {
                VStack(spacing: 16) {
                    // Performance Overview Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .strokeBorder(Utils.getScoreColor(for: 9), lineWidth: 4)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(format: "%.1f", 9))
                                        .font(.caption)
                                        .foregroundColor(Utils.getScoreColor(for: 9))
                                )
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Performance Overview")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("Fair Driving Performance!")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label("Admiralty Gate, Lekki-Epe Exp. Way", systemImage: "mappin.and.ellipse")
                                    .font(.subheadline)
                                Spacer()
                                Text("4:02PM")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Label("Ajah Motor Park", systemImage: "mappin.and.ellipse")
                                    .font(.subheadline)
                                Spacer()
                                Text("4:26PM")
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
                                    Text("7.5KM")
                                        .font(.headline)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Trip Duration")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("22 Minutes")
                                        .font(.headline)
                                }
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Average Speed")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("102 KM/H")
                                        .font(.headline)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Maximum Speed")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("120 KM/H")
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
                    
                    // Safety Events Section
                    VStack(spacing: 0) {
                        SafetyEventRow(icon: "exclamationmark.triangle.fill", color: .red, title: "Rapid Acceleration", count: 3)
                        Divider()
                        SafetyEventRow(icon: "exclamationmark.triangle.fill", color: .red, title: "Hard Braking", count: 2)
                        Divider()
                        SafetyEventRow(icon: "exclamationmark.triangle.fill", color: .orange, title: "Harsh Cornering", count: 2)
                        Divider()
                        SafetyEventRow(icon: "checkmark.circle.fill", color: .green, title: "Smooth Acceleration", count: 1)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // Driving Tip
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Driving Tip", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Fantastic job today! Keep maintaining smooth acceleration and gentle braking. You're on track for a perfect weekly score.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // Buttons
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
            }
            .background(Color.white) // << pure white background
        }
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
