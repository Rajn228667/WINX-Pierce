import SwiftUI
import AVFoundation

/// "Walking" — runs the camera + ObjectDetector continuously, announces obstacles,
/// vibrates on imminent danger, and keeps the screen alive.
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
                }
                .onDisappear {
                    vm.stop()
                    UIApplication.shared.isIdleTimerDisabled = false
                }

            // Center crosshair "obstacle gauge"
            VStack {
                Spacer()
                ObstacleHUD(detections: vm.detections)
                Spacer()
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        running.toggle()
                        if running { vm.start() } else { vm.stop() }
                    } label: {
                        Image(systemName: running ? "pause.fill" : "play.fill")
                            .font(.title)
                            .padding(14)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

private struct ObstacleHUD: View {
    let detections: [ObjectDetector.Detection]
    var dangerScore: Double {
        let center = CGRect(x: 0.30, y: 0.30, width: 0.40, height: 0.40)
        let bigCentered = detections
            .filter { $0.box.intersects(center) }
            .map { Double($0.box.width * $0.box.height) }
            .reduce(0, +)
        return min(1.0, bigCentered * 4)
    }
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.20))
                .frame(width: 220, height: 220)
            Circle()
                .trim(from: 0, to: dangerScore)
                .stroke(
                    LinearGradient(colors: [Theme.accentEmerald, Theme.accentRed],
                                   startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 220, height: 220)
                .animation(.easeInOut(duration: 0.3), value: dangerScore)
            Text(dangerScore > 0.4 ? "СТОП" : "ИДУ")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(dangerScore > 0.4 ? Theme.accentRed : Theme.accentEmerald)
        }
    }
}
