import SwiftUI
import AVFoundation

struct MagnifierView: View {

    @StateObject private var camera = CameraManager()
    @State private var zoom: CGFloat = 2.0
    @State private var torch: Bool = false
    @State private var invert: Bool = false
    @State private var contrast: Double = 1.0

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
                .colorInvert(invert)
                .contrast(contrast)
                .onAppear {
                    camera.configure()
                    camera.start()
                    camera.zoom = zoom
                }
                .onDisappear { camera.stop() }

            VStack {
                Spacer()
                VStack(spacing: 14) {
                    HStack {
                        Image(systemName: "minus.magnifyingglass")
                        Slider(value: Binding(get: { Double(zoom) },
                                              set: { v in zoom = CGFloat(v); camera.zoom = zoom }),
                               in: 1...Double(min(camera.maxZoom, 6)))
                        Image(systemName: "plus.magnifyingglass")
                    }
                    HStack {
                        Image(systemName: "circle.lefthalf.filled")
                        Slider(value: $contrast, in: 0.5...2.0)
                    }
                    HStack(spacing: 12) {
                        Button {
                            torch.toggle()
                            camera.torchOn = torch
                        } label: {
                            Label(torch ? "Фонарик" : "Свет", systemImage: "bolt.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(torch ? Theme.brandRed : Theme.elevatedBackground)
                                .foregroundStyle(torch ? .white : Theme.primaryText)
                                .clipShape(Capsule())
                        }
                        Button {
                            invert.toggle()
                        } label: {
                            Label(invert ? "Инверсия" : "Норма", systemImage: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(invert ? Theme.brandRed : Theme.elevatedBackground)
                                .foregroundStyle(invert ? .white : Theme.primaryText)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding()
            }
        }
            .voiceGuide(.guide_magnifier)
    }
}

private extension View {
    @ViewBuilder
    func colorInvert(_ on: Bool) -> some View {
        if on { self.colorInvert() } else { self }
    }
}
