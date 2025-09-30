import MapKit
import SwiftUI

// MARK: - Coordinates struct

struct Coordinates: Codable {
    let lat: Double
    let lon: Double
}

// MARK: - Location struct

struct Location: Codable {
    let coords: Coordinates
}

// MARK: - Trip model

struct Trip: Identifiable, Codable {
    let id: Int
    let startLocation: Location
    let endLocation: Location
    let distanceCoveredKM: Double
    let durationMinutes: Int
    let startTime: String
}

// MARK: - Annotation helper

struct AnnotationPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let color: Color
}

// MARK: - ViewModel

class MapCompsViewModel: ObservableObject {
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    @Published var trips: [Trip] = []
    @Published var selectedTrip: Trip?
    @Published var isLoading = false

    var annotationPoints: [AnnotationPoint] {
        trips.flatMap { trip in
            [
                AnnotationPoint(
                    coordinate: CLLocationCoordinate2D(
                        latitude: trip.startLocation.coords.lat,
                        longitude: trip.startLocation.coords.lon
                    ),
                    title: "Start",
                    color: .green
                ),
                AnnotationPoint(
                    coordinate: CLLocationCoordinate2D(
                        latitude: trip.endLocation.coords.lat,
                        longitude: trip.endLocation.coords.lon
                    ),
                    title: "End",
                    color: .red
                )
            ]
        }
    }

    func fetchTrips() async {
        await MainActor.run { isLoading = true }

        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulated delay

        await MainActor.run {
            trips = [
                Trip(
                    id: 1,
                    startLocation: Location(coords: Coordinates(lat: 37.7749, lon: -122.4194)),
                    endLocation: Location(coords: Coordinates(lat: 37.7849, lon: -122.4094)),
                    distanceCoveredKM: 5.2,
                    durationMinutes: 15,
                    startTime: "2024-01-15T10:30:00Z"
                )
            ]
            isLoading = false
        }
    }

    func zoomToTrip(_ trip: Trip) {
        let center = CLLocationCoordinate2D(
            latitude: (trip.startLocation.coords.lat + trip.endLocation.coords.lat) / 2,
            longitude: (trip.startLocation.coords.lon + trip.endLocation.coords.lon) / 2
        )

        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: center,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        }
    }
}

// MARK: - Polyline (placeholder)

struct MapPolyline: View {
    let start: Coordinates
    let end: Coordinates

    var body: some View {
        EmptyView() // TODO: Replace with MKPolyline renderer if needed
    }
}

// MARK: - TripMap

struct TripMap: View {
    @ObservedObject var viewModel: MapCompsViewModel

    var body: some View {
        Map(position: $viewModel.cameraPosition) {
            ForEach(viewModel.annotationPoints) { point in
                Annotation(point.title, coordinate: point.coordinate) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(point.color)
                            .font(.title2)
                        Text(point.title)
                            .font(.caption2)
                            .foregroundColor(.black)
                            .padding(4)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .overlay {
            if let trip = viewModel.selectedTrip {
                MapPolyline(start: trip.startLocation.coords, end: trip.endLocation.coords)
            }
        }
    }
}

// MARK: - Main View

struct MapComps: View {
    @StateObject private var viewModel = MapCompsViewModel()

    var body: some View {
        ZStack {
            TripMap(viewModel: viewModel)
//                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading trips...")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }

            // Horizontal trip list
            VStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.trips) { trip in
                            Button {
                                viewModel.selectedTrip = trip
                                viewModel.zoomToTrip(trip)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Trip \(trip.id)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("\(String(format: "%.1f", trip.distanceCoveredKM)) km")
                                        .foregroundColor(.gray)
                                    Text("\(trip.durationMinutes) mins")
                                        .foregroundColor(.gray)
                                    Text(formatDate(trip.startTime))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(width: 140)
                                .background(Color.black)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                .frame(height: 120)
            }
        }
        .task {
            await viewModel.fetchTrips()
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, h:mm a"
            return displayFormatter.string(from: date)
        }
        return "N/A"
    }
}

#Preview { MapComps() }
