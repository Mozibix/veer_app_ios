//import MapKit
//import SwiftUI
//
//// MARK: - Trip Model
//
//struct Trip: Identifiable, Codable {
//    let id: String
//    let startLocation: Location
//    let endLocation: Location
//    let distanceCoveredKM: Double
//    let durationMinutes: Int
//    let startTime: String
//    let drivingScore: Double
//}
//
//struct Location: Codable {
//    let coords: Coordinates
//    let address: String
//}
//
//struct Coordinates: Codable {
//    let lat: Double
//    let lon: Double
//}
//
//// MARK: - Annotation Helper
//
//struct AnnotationPoint: Identifiable {
//    let id = UUID()
//    let coordinate: CLLocationCoordinate2D
//    let title: String
//    let color: Color
//}
//
//// MARK: - ViewModel
//
//class MapCompsViewModel: ObservableObject {
//    @Published var trips: [Trip] = []
//    @Published var selectedTrip: Trip?
//    @Published var isLoading: Bool = false
//    @Published var cameraPosition: MapCameraPosition = .region(
//        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 6.5244, longitude: 3.3792),
//                           span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
//    )
//
//    var annotationPoints: [AnnotationPoint] {
//        trips.flatMap { trip in
//            [
//                AnnotationPoint(coordinate: CLLocationCoordinate2D(latitude: trip.startLocation.coords.lat,
//                                                                   longitude: trip.startLocation.coords.lon),
//                                title: "Start", color: .green),
//                AnnotationPoint(coordinate: CLLocationCoordinate2D(latitude: trip.endLocation.coords.lat,
//                                                                   longitude: trip.endLocation.coords.lon),
//                                title: "End", color: .red)
//            ]
//        }
//    }
//
//    func fetchTrips() async {
//        await MainActor.run { isLoading = true }
//        // Simulate API call
//        try? await Task.sleep(nanoseconds: 1_000_000_000)
//
//        await MainActor.run {
//            trips = [
//                Trip(
//                    id: "68b962562d5900ff5761f1cd",
//                    startLocation: Location(coords: Coordinates(lat: 6.451, lon: 3.401),
//                                            address: "H8MH+CVM, Kurukunama 332105, Delta, Nigeria"),
//                    endLocation: Location(coords: Coordinates(lat: 6.455, lon: 3.403),
//                                          address: "Sterling Towers, 20 Marina Rd, Lagos Island, Lagos 102273, Lagos, Nigeria"),
//                    distanceCoveredKM: 0,
//                    durationMinutes: 1,
//                    startTime: "2025-09-04T09:56:37.702Z",
//                    drivingScore: 10
//                )
//            ]
//            isLoading = false
//        }
//    }
//
//    func zoomToTrip(_ trip: Trip) {
//        let center = CLLocationCoordinate2D(
//            latitude: (trip.startLocation.coords.lat + trip.endLocation.coords.lat)/2,
//            longitude: (trip.startLocation.coords.lon + trip.endLocation.coords.lon)/2
//        )
//        cameraPosition = .region(
//            MKCoordinateRegion(center: center,
//                               span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//        )
//    }
//}
//
//// MARK: - Trip Map
//
//struct TripMap: View {
//    @ObservedObject var viewModel: MapCompsViewModel
//
//    var body: some View {
//        Map(position: $viewModel.cameraPosition) {
//            ForEach(viewModel.annotationPoints) { point in
//                Annotation(point.title, coordinate: point.coordinate) {
//                    VStack {
//                        Image(systemName: "mappin.circle.fill")
//                            .foregroundColor(point.color)
//                        Text(point.title)
//                            .font(.caption2)
//                            .foregroundColor(.black)
//                            .padding(4)
//                            .background(Color.white.opacity(0.8))
//                            .cornerRadius(4)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - MapComps with bottom trip cards
//
//struct MapComps: View {
//    @StateObject private var viewModel = MapCompsViewModel()
//
//    var body: some View {
//        ZStack {
//            TripMap(viewModel: viewModel)
//                .ignoresSafeArea()
//
//            if viewModel.isLoading {
//                ProgressView("Loading trips...")
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(12)
//                    .foregroundColor(.white)
//            }
//
//            VStack {
//                Spacer()
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(viewModel.trips) { trip in
//                            Button {
//                                viewModel.selectedTrip = trip
//                                viewModel.zoomToTrip(trip)
//                            } label: {
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text("Trip \(trip.id.prefix(5))…")
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                    Text("\(String(format: "%.1f", trip.distanceCoveredKM)) km")
//                                        .foregroundColor(.gray)
//                                    Text("\(trip.durationMinutes) mins")
//                                        .foregroundColor(.gray)
//                                    Text(formatDate(trip.startTime))
//                                        .font(.caption2)
//                                        .foregroundColor(.gray)
//                                }
//                                .padding()
//                                .frame(width: 140)
//                                .background(Color.black.opacity(0.8))
//                                .cornerRadius(10)
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .padding(.bottom, 20) // ensures spacing from bottom safe area
//                .frame(height: 120)
//            }
//        }
//        .task { await viewModel.fetchTrips() }
//    }
//
//    private func formatDate(_ dateString: String) -> String {
//        let formatter = ISO8601DateFormatter()
//        if let date = formatter.date(from: dateString) {
//            let displayFormatter = DateFormatter()
//            displayFormatter.dateFormat = "MMM d, h:mm a"
//            return displayFormatter.string(from: date)
//        }
//        return "N/A"
//    }
//}
//
//// MARK: - TripReport Screen
//
//struct TripReport: View {
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Header
//                Text("Trip Report")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.black)
//                    .foregroundColor(.white)
//
//                // Map with trip cards
//                MapComps()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//            .ignoresSafeArea(edges: .bottom)
//        }
//    }
//}
//
//#Preview {
//    TripReport()
//}
