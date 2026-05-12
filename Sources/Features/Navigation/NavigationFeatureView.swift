import SwiftUI
import MapKit
import CoreLocation

struct NavigationFeatureView: View {

    @StateObject private var vm = NavigationFeatureViewModel()
    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        VStack(spacing: 12) {
            Map(position: $vm.cameraPosition) {
                UserAnnotation()
                if let dest = vm.destinationCoordinate {
                    Marker("", systemImage: "flag.fill", coordinate: dest)
                        .tint(Theme.brandRed)
                }
                if let route = vm.activeRoute {
                    MapPolyline(route.polyline)
                        .stroke(Theme.brandRed, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapPitchToggle()
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)

            HStack(spacing: 8) {
                quickButton(icon: "cross.case.fill", label: loc.tr(.nav_search_pharmacy), color: Theme.accentRed) {
                    Task { await vm.searchAndRoute(query: "аптека") }
                }
                quickButton(icon: "stethoscope", label: loc.tr(.nav_search_hospital), color: Theme.accentBlue) {
                    Task { await vm.searchAndRoute(query: "больница") }
                }
                quickButton(icon: "cart.fill", label: loc.tr(.nav_search_store), color: Theme.accentEmerald) {
                    Task { await vm.searchAndRoute(query: "магазин") }
                }
            }
            .padding(.horizontal)

            if let step = vm.currentInstruction {
                Text(step)
                    .font(.system(size: 22, weight: .heavy))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Theme.card))
                    .padding(.horizontal)
            }

            HStack {
                TextField(loc.tr(.nav_destination), text: $vm.searchQuery)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task { await vm.searchAndRoute(query: vm.searchQuery) }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .padding(10)
                        .background(Theme.brandRed)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)

            if let _ = vm.activeRoute {
                Button {
                    vm.start()
                } label: {
                    Label(loc.tr(.nav_start_route), systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.brandRed)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding(.top)
        .onAppear { vm.requestLocation() }
            .voiceGuide(.guide_navigation)
    }

    private func quickButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label).font(.system(size: 12, weight: .semibold)).lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
