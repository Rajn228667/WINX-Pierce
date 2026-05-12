import SwiftUI
import AVFoundation
import CoreMotion

/// Full-room Locator — direct port of the Android Locator activity.
///
/// Pipeline:
///   • Live camera preview from `CameraManager`
///   • Each frame goes through `ObstacleAnalyzer` → `ObstacleSnapshot`
///   • The view-model decides which pre-recorded MP3 cue to play and updates
///     the on-screen HUD.
///
/// Voice cues (bundled MP3s, recorded by a human):
///   • `voice_stop_wall`    — "Остановитесь, впереди стена."  (CENTER + close)
///   • `voice_turn_left`    — "Поверните левее."              (RIGHT obstacle)
///   • `voice_turn_right`   — "Поверните правее."             (LEFT obstacle)
///   • `voice_idle_15s`     — idle nudge when 15 s silent
///
/// On top of the cues the view-model also fires a TTS "путь свободен"
/// heartbeat every 10 s when no obstacles are present so the user always
/// knows the system is alive.
struct LocatorView: View {

    @EnvironmentObject private var loc: LocalizationManager
    @StateObject private var vm = LocatorViewModel()

    var body: some View {
        ZStack {
            // ── 1. Camera preview ─────────────────────────────────────────
            CameraPreview(session: vm.camera.session)
                .ignoresSafeArea()
                .onAppear { vm.start() }
                .onDisappear { vm.stop() }

            // ── 2. Three-zone overlay ─────────────────────────────────────
            GeometryReader { proxy in
                ZStack {
                    HStack(spacing: 0) {
                        ZoneOverlay(color: vm.snapshot.zone == .left ? .red : .clear)
                        ZoneOverlay(color: vm.snapshot.zone == .center ? .red : .clear)
                        ZoneOverlay(color: vm.snapshot.zone == .right ? .red : .clear)
                    }
                    // Bounding-box indicator for the dominant obstacle.
                    if vm.snapshot.proximity > 0.1 {
                        Rectangle()
                            .stroke(Color.red.opacity(0.9), lineWidth: 4)
                            .frame(width: proxy.size.width * CGFloat(min(max(vm.snapshot.proximity, 0.15), 0.85)),
                                   height: proxy.size.height * CGFloat(min(max(vm.snapshot.proximity, 0.15), 0.85)))
                            .position(x: proxy.size.width * CGFloat(vm.snapshot.centroidX),
                                      y: proxy.size.height * 0.5)
                            .animation(.easeOut(duration: 0.2), value: vm.snapshot.centroidX)
                    }
                }
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()

            // ── 3. Top status banner ──────────────────────────────────────
            VStack(spacing: 0) {
                StatusBanner(state: vm.state, message: vm.message)
                    .padding(.top, 8)
                    .padding(.horizontal)
                Spacer()
                // ── 4. Bottom controls ────────────────────────────────────
                ControlBar(vm: vm, loc: loc)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
            }
        }
        .statusBarHidden(true)
        .voiceGuide(.guide_locator)
    }
}

// MARK: - Overlay primitives

private struct ZoneOverlay: View {
    let color: Color
    var body: some View {
        Rectangle()
            .fill(color.opacity(0.16))
            .overlay(
                Rectangle()
                    .stroke(color.opacity(0.4), lineWidth: 1)
            )
    }
}

private struct StatusBanner: View {
    let state: LocatorViewModel.State
    let message: String

    private var bg: Color {
        switch state {
        case .clear:   return Color.green
        case .warning: return Color.orange
        case .danger:  return Color.red
        case .dark:    return Color(white: 0.2)
        }
    }

    private var icon: String {
        switch state {
        case .clear:   return "checkmark.shield.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger:  return "octagon.fill"
        case .dark:    return "moon.fill"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .black))
            Text(message)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(bg.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
        .accessibilityLabel(Text(message))
    }
}

private struct ControlBar: View {
    @ObservedObject var vm: LocatorViewModel
    let loc: LocalizationManager

    var body: some View {
        HStack(spacing: 16) {
            circleButton(icon: vm.camera.torchOn ? "flashlight.on.fill" : "flashlight.off.fill",
                         color: .yellow, label: loc.tr(.acc_flashlight)) {
                vm.camera.torchOn.toggle()
                HapticManager.shared.tap()
            }

            circleButton(icon: "speaker.wave.2.fill", color: .blue, label: loc.tr(.guide_locator)) {
                vm.repeatLastCue()
            }

            circleButton(icon: vm.isRunning ? "pause.fill" : "play.fill",
                         color: vm.isRunning ? .red : .green,
                         label: vm.isRunning ? loc.tr(.action_stop) : loc.tr(.action_speak)) {
                vm.togglePause()
                HapticManager.shared.tap()
            }

            circleButton(icon: "phone.fill.connection", color: .pink, label: loc.tr(.tile_sos)) {
                vm.triggerSOS()
            }
        }
    }

    private func circleButton(icon: String, color: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(color))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
                    .lineLimit(1)
            }
        }
        .accessibilityLabel(Text(label))
    }
}
