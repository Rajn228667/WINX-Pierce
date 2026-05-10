import SwiftUI

/// Sound Detection — runs the on-device SoundAnalysis classifier so users
/// who can't hear (or are visually busy) get a big visual + spoken alert
/// when something important happens around them: alarms, doorbells, glass
/// breaking, sirens, dogs barking, babies crying, running water, speech.
struct SoundDetectorView: View {

    @StateObject private var engine = SoundDetectorEngine()
    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var settings: SettingsStore
    @State private var flashing: Bool = false

    private let categories: [SoundDetectorEngine.DetectedSound] = [
        .alarm, .doorbell, .glass, .siren, .baby, .dog, .speech, .water
    ]

    var body: some View {
        ZStack {
            (flashing ? Theme.brandRed : Color.black).ignoresSafeArea()
                .animation(.easeOut(duration: 0.4), value: flashing)

            VStack(spacing: 22) {

                // Status block — listening / paused
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 8)
                            .frame(width: 88, height: 88)
                        Image(systemName: engine.isListening ? "waveform.circle.fill" : "waveform.slash")
                            .font(.system(size: 44, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(engine.isListening ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(), value: engine.isListening)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(engine.isListening ? loc.tr(.sound_listening) : loc.tr(.sound_paused))
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text(loc.tr(.sound_intro))
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(3)
                    }
                    Spacer()
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.ultraThinMaterial))
                .padding(.horizontal, 16)

                // Last detected — huge readout for low-vision
                if let last = engine.lastDetected {
                    VStack(spacing: 10) {
                        Image(systemName: last.systemImage)
                            .font(.system(size: 80, weight: .heavy))
                            .foregroundStyle(.white)
                        Text(loc.tr(last.localKey))
                            .font(.system(size: 32 * settings.textScale, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.6)
                            .padding(.horizontal, 18)
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.brandRed))
                    .padding(.horizontal, 16)
                }

                // Categories grid — what the engine can recognise
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                          spacing: 12) {
                    ForEach(categories, id: \.self) { cat in
                        VStack(spacing: 6) {
                            Image(systemName: cat.systemImage)
                                .font(.system(size: 26, weight: .heavy))
                                .foregroundStyle(.white)
                            Text(loc.tr(cat.localKey).components(separatedBy: " ").prefix(2).joined(separator: " "))
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, minHeight: 70)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                // History — last 5 detections
                if !engine.history.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("История")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                        ForEach(Array(engine.history.prefix(5).enumerated()), id: \.offset) { item in
                            HStack(spacing: 12) {
                                Image(systemName: item.element.sound.systemImage)
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundStyle(.white)
                                    .frame(width: 28)
                                Text(loc.tr(item.element.sound.localKey))
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(item.element.date, style: .time)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                        }
                    }
                }

                Button {
                    if engine.isListening {
                        engine.stop()
                    } else {
                        try? engine.start()
                    }
                    HapticManager.shared.tap()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: engine.isListening ? "stop.fill" : "ear.fill")
                            .font(.system(size: 22, weight: .black))
                        Text(engine.isListening ? loc.tr(.listen_stop) : loc.tr(.listen_start))
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, minHeight: 84)
                    .foregroundStyle(.white)
                    .background(Capsule().fill(engine.isListening ? Theme.brandRed : Theme.accentEmerald))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .padding(.top, 16)
        }
        .navigationTitle(Text(loc.tr(.tile_sound_detect)))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: engine.lastDetectionDate) { _, _ in
            withAnimation(.easeInOut(duration: 0.4)) { flashing = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation { flashing = false }
            }
        }
        .onDisappear { engine.stop() }
    }
}
