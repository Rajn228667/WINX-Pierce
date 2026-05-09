import SwiftUI
import MediaPlayer

/// Talks to the user's local Apple Music library + system MPMusicPlayerController.
/// Provides voice-friendly "Назови трек / следующий / тише" controls.
struct MusicView: View {
    @StateObject private var vm = MusicViewModel()

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if let art = vm.artwork {
                    Image(uiImage: art).resizable().scaledToFill()
                } else {
                    LinearGradient(colors: [Theme.accentOrange, Theme.brandPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            }
            .frame(width: 220, height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(.top)

            VStack(spacing: 4) {
                Text(vm.title).font(.title2.bold())
                Text(vm.artist).foregroundStyle(.secondary)
            }

            HStack(spacing: 28) {
                bigButton("backward.fill") { vm.previous() }
                bigButton(vm.isPlaying ? "pause.fill" : "play.fill") { vm.togglePlay() }
                bigButton("forward.fill") { vm.next() }
            }

            HStack {
                Image(systemName: "speaker.fill")
                Slider(value: $vm.volume, in: 0...1)
                Image(systemName: "speaker.wave.3.fill")
            }
            .padding(.horizontal)

            Button {
                vm.tellWhatIsPlaying()
            } label: {
                Label("Что играет?", systemImage: "speaker.wave.2.fill")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.accentOrange.opacity(0.18))
                    .foregroundStyle(Theme.accentOrange)
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
            Spacer()
        }
        .onAppear { vm.refresh() }
    }

    private func bigButton(_ system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 30, weight: .bold))
                .frame(width: 72, height: 72)
                .background(Circle().fill(Theme.card))
        }
    }
}

@MainActor
final class MusicViewModel: ObservableObject {
    @Published var title: String = "Тишина"
    @Published var artist: String = "—"
    @Published var artwork: UIImage?
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 0.5

    private let player = MPMusicPlayerController.systemMusicPlayer

    init() {
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: player, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        player.beginGeneratingPlaybackNotifications()
    }

    func refresh() {
        if let item = player.nowPlayingItem {
            title = item.title ?? "Без названия"
            artist = item.artist ?? "Неизвестный исполнитель"
            artwork = item.artwork?.image(at: CGSize(width: 600, height: 600))
        } else {
            title = "Тишина"; artist = "—"; artwork = nil
        }
        isPlaying = player.playbackState == .playing
    }

    func togglePlay() {
        if player.playbackState == .playing { player.pause() } else { player.play() }
    }
    func next() { player.skipToNextItem() }
    func previous() { player.skipToPreviousItem() }

    func tellWhatIsPlaying() {
        VoiceSynthesizer.shared.speak("Сейчас играет: \(title), \(artist).")
    }
}
