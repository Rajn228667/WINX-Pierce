import SwiftUI
import AVFoundation
import Vision

struct VisionScanView: View {

    @StateObject private var vm = VisionScanViewModel()
    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        ZStack {
            CameraPreview(session: vm.camera.session)
                .ignoresSafeArea()
                .onAppear { vm.start() }
                .onDisappear { vm.stop() }

            // Overlay: detected boxes
            GeometryReader { geo in
                ForEach(vm.detections) { d in
                    let rect = vm.viewRect(for: d.box, in: geo.size)
                    Rectangle()
                        .stroke(boxColor(for: d.label), lineWidth: 3)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                        .overlay(
                            Text(d.label + (d.extra.map { ": \($0)" } ?? ""))
                                .font(.caption.bold())
                                .padding(4)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .position(x: rect.midX, y: rect.minY + 14)
                        )
                }
            }

            // Bottom controls
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    if !vm.lastSpokenSummary.isEmpty {
                        Text(vm.lastSpokenSummary)
                            .font(.system(size: 16, weight: .heavy))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    HStack(spacing: 16) {
                        controlButton("bolt.fill", on: vm.camera.torchOn) {
                            vm.camera.torchOn.toggle()
                        }
                        controlButton("plus.magnifyingglass", on: false) {
                            vm.camera.zoom = min(vm.camera.maxZoom, vm.camera.zoom * 1.5)
                        }
                        controlButton("minus.magnifyingglass", on: false) {
                            vm.camera.zoom = max(vm.camera.minZoom, vm.camera.zoom / 1.5)
                        }
                        Button {
                            Task { await vm.describeNow() }
                        } label: {
                            Label(loc.tr(.vision_describe_now), systemImage: "sparkles")
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(Theme.brandRed)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
            .voiceGuide(.guide_scan)
    }

    private func boxColor(for label: String) -> Color {
        switch label {
        case "Человек", "Лицо": return Theme.accentEmerald
        case "Текст": return Theme.accentBlue
        case "Прямоугольник": return Theme.accentPurple
        default: return Theme.brandRed
        }
    }

    private func controlButton(_ system: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 22, weight: .bold))
                .frame(width: 56, height: 56)
                .background(
                    ZStack {
                        if on {
                            Circle().fill(Theme.brandRed)
                        } else {
                            Circle().fill(.ultraThinMaterial)
                        }
                    }
                )
                .foregroundStyle(on ? Color.white : Theme.primaryText)
        }
    }
}
