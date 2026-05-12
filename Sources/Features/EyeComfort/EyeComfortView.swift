import SwiftUI

struct EyeComfortView: View {
    @EnvironmentObject private var settings: SettingsStore
    @StateObject private var engine: EyeComfortEngine = .shared

    var body: some View {
        Form {
            Section("Тёплый свет") {
                Slider(value: $settings.blueLightFilter, in: 0...0.6, step: 0.05) {
                    Text("Сила фильтра")
                }
                Text("Уменьшает синий свет — глаза устают меньше, особенно вечером.")
                    .foregroundStyle(.secondary)
            }
            Section("Контраст") {
                Toggle("Авто-контраст по освещению", isOn: $engine.adaptiveAuto)
                Toggle("Высокий контраст", isOn: $settings.highContrast)
            }
            Section("Просмотр") {
                ZStack {
                    LinearGradient(colors: [.blue, .green, .yellow, .red], startPoint: .leading, endPoint: .trailing)
                    Text("Образец текста для проверки")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(.white)
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .eyeComfortOverlay()
            }
        }
        .navigationTitle("Комфорт глаз")
        .onAppear {
            engine.applySaved()
        }
            .voiceGuide(.guide_eye_comfort)
    }
}
