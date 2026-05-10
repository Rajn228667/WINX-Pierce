import SwiftUI
import AVFoundation
import UIKit

/// "Walking" — runs the camera + ObjectDetector continuously, plays HUMAN voice
/// cues when an obstacle is detected (Stop / Turn left / Turn right), and
/// optionally narrates the scene every 6 seconds via Ollama.
struct WalkingView: View {

    @StateObject private var vm = VisionScanViewModel()
    @State private var running: Bool = false
    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        ZStack {
            CameraPreview(session: vm.camera.session)
                .ignoresSafeArea()
                .onAppear {
                    vm.start()
                    running = true
                    UIApplication.shared.isIdleTimerDisabled = true
                    VoiceSynthesizer.shared.speak(loc.tr(.walking_intro))
                }
                .onDisappear {
                    vm.stop()
                    UIApplication.shared.isIdleTimerDisabled = false
                }

            // Live HUD — readable from far away in a glance.
            VStack(spacing: 12) {
                Spacer()
                ObstacleHUD(detections: vm.detections, dangerLevel: vm.dangerLevel)
                Spacer().frame(height: 24)
                if !vm.lastSpokenSummary.isEmpty {
                    Text(vm.lastSpokenSummary)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial.opacity(0.9), in: RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal)
                        .accessibilityLabel(Text(vm.lastSpokenSummary))
                }
            }
            .padding(.bottom, 24)

            // Top right: pause + flash + auto-narrate toggle.
            VStack {
                HStack(spacing: 12) {
                    Spacer()
                    pillButton(systemImage: vm.camera.torchOn ? "bolt.fill" : "bolt.slash.fill",
                               on: vm.camera.torchOn,
                               accent: Theme.accentYellow,
                               accLabel: "Фонарик") {
                        vm.camera.torchOn.toggle()
                    }
                    pillButton(systemImage: vm.isAutoNarrating ? "ear.fill" : "ear",
                               on: vm.isAutoNarrating,
                               accent: Theme.accentBlue,
                               accLabel: "Постоянное описание") {
                        vm.toggleAutoNarration()
                    }
                    pillButton(systemImage: running ? "pause.fill" : "play.fill",
                               on: false,
                               accent: Theme.brandRed,
                               accLabel: running ? "Пауза" : "Старт") {
                        running.toggle()
                        if running { vm.start() } else { vm.stop() }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                Spacer()
            }
        }
        .navigationTitle(loc.tr(.tile_walking))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func pillButton(systemImage: String, on: Bool, accent: Color,
                            accLabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(on ? Color.white : Theme.primaryText)
                .frame(width: 56, height: 56)
                .background(
                    ZStack {
                        if on {
                            Circle().fill(accent)
                        } else {
                            Circle().fill(.ultraThinMaterial.opacity(0.92))
                        }
                    }
                )
                .overlay(Circle().stroke(accent.opacity(on ? 0 : 0.45), lineWidth: 1))
        }
        .accessibleHitTarget(72)
        .accessibilityLabel(Text(accLabel))
    }
}

private struct ObstacleHUD: View {
    let detections: [ObjectDetector.Detection]
    let dangerLevel: Double

    var body: some View {
        let danger = dangerLevel
        let label: (text: String, colour: Color) = {
            switch danger {
            case 0..<0.25:  return ("ИДУ", Theme.accentEmerald)
            case 0.25..<0.55: return ("ВНИМАНИЕ", Theme.accentYellow)
            default:        return ("СТОП", Theme.accentRed)
            }
        }()
        ZStack {
            // Halo
            Circle()
                .fill(label.colour.opacity(0.18))
                .frame(width: 250, height: 250)
                .blur(radius: 12)
            // Background ring
            Circle()
                .fill(Color.black.opacity(0.30))
                .frame(width: 220, height: 220)
            // Progress arc
            Circle()
                .trim(from: 0, to: max(0.05, danger))
                .stroke(
                    AngularGradient(colors: [Theme.accentEmerald, Theme.accentYellow, Theme.accentRed],
                                    center: .center),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 220, height: 220)
                .animation(.easeInOut(duration: 0.3), value: danger)
            VStack(spacing: 2) {
                Text(label.text)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(label.colour)
                Text("\(detections.count) \(declension(for: detections.count))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(label.text))
        .accessibilityValue(Text("\(detections.count)"))
    }

    private func declension(for count: Int) -> String {
        let n = count % 100
        if (11...14).contains(n) { return "объектов" }
        switch n % 10 {
        case 1: return "объект"
        case 2,3,4: return "объекта"
        default: return "объектов"
        }
    }
}
