import SwiftUI
import AVFoundation
import UIKit

/// Quick-access tools hub — mirrors the Android ToolsScreen.
/// Camera-based tools: scene, color, money, light, face.
/// Instant tools: time, battery.
struct ToolsView: View {

    @EnvironmentObject private var loc: LocalizationManager
    @StateObject private var camera = CameraManager()
    @State private var busy = false
    @State private var result: String = ""
    @State private var error: String = ""
    @State private var activeToolId: String?

    struct CameraTool: Identifiable, Equatable {
        let id: String
        let title: String
        let hint: String
        let icon: String
        let color: Color
        let prompt: String
        static func == (lhs: CameraTool, rhs: CameraTool) -> Bool { lhs.id == rhs.id }
    }

    private var cameraTools: [CameraTool] {
        [
            CameraTool(id: "scene",
                       title: loc.tr(.tools_scene),
                       hint: loc.tr(.tools_scene_hint),
                       icon: "eye.fill",
                       color: Theme.accentBlue,
                       prompt: prompt(for: "scene")),
            CameraTool(id: "color",
                       title: loc.tr(.tools_color),
                       hint: loc.tr(.tools_color_hint),
                       icon: "paintpalette.fill",
                       color: Theme.accentPurple,
                       prompt: prompt(for: "color")),
            CameraTool(id: "money",
                       title: loc.tr(.tools_money),
                       hint: loc.tr(.tools_money_hint),
                       icon: "banknote.fill",
                       color: Theme.accentOrange,
                       prompt: prompt(for: "money")),
            CameraTool(id: "light",
                       title: loc.tr(.tools_light),
                       hint: loc.tr(.tools_light_hint),
                       icon: "sun.max.fill",
                       color: Theme.accentYellow,
                       prompt: prompt(for: "light")),
            CameraTool(id: "face",
                       title: loc.tr(.tools_face),
                       hint: loc.tr(.tools_face_hint),
                       icon: "person.fill",
                       color: Theme.brandPink,
                       prompt: prompt(for: "face")),
            CameraTool(id: "sign",
                       title: loc.tr(.tools_sign),
                       hint: loc.tr(.tools_sign_hint),
                       icon: "signpost.right.fill",
                       color: Theme.brandRed,
                       prompt: prompt(for: "sign")),
            CameraTool(id: "document",
                       title: loc.tr(.tools_document),
                       hint: loc.tr(.tools_document_hint),
                       icon: "doc.text.fill",
                       color: Theme.accentBlue,
                       prompt: prompt(for: "document")),
            CameraTool(id: "finder",
                       title: loc.tr(.tools_finder),
                       hint: loc.tr(.tools_finder_hint),
                       icon: "magnifyingglass.circle.fill",
                       color: Theme.accentEmerald,
                       prompt: prompt(for: "finder"))
        ]
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Hidden camera preview so the session is alive but doesn't take real estate.
            CameraPreview(session: camera.session)
                .opacity(0.001)
                .frame(height: 1)
                .accessibilityHidden(true)

            ScrollView {
                VStack(spacing: 14) {
                    Text(loc.tr(.tools_intro))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)

                    ForEach(cameraTools) { tool in
                        Button {
                            captureAndAnalyze(tool)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: tool.icon)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Circle().fill(tool.color))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(tool.title)
                                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                                        .foregroundStyle(Theme.primaryText)
                                    Text(tool.hint)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundStyle(Theme.secondaryText)
                                        .lineLimit(2)
                                }
                                Spacer()
                                if busy && activeToolId == tool.id {
                                    ProgressView()
                                } else {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Theme.tertiaryText)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
                                    .stroke(tool.color.opacity(0.30), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibleHitTarget()
                        .accessibilityLabel(Text("\(tool.title). \(tool.hint)"))
                        .disabled(busy)
                    }

                    Divider().padding(.vertical, 4)

                    HStack(spacing: 14) {
                        instantToolButton(icon: "clock.fill",
                                          title: loc.tr(.tools_time),
                                          color: Theme.accentSky,
                                          action: tellTime)
                        instantToolButton(icon: "battery.100percent",
                                          title: loc.tr(.tools_battery),
                                          color: Theme.accentGreen,
                                          action: tellBattery)
                    }

                    if !result.isEmpty {
                        Text(result)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.radiusMedium)
                                    .fill(Theme.elevatedBackground)
                            )
                            .accessibilityLabel(Text(result))
                    }
                    if !error.isEmpty {
                        Text(error)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.accentRed)
                            .padding()
                    }
                }
                .padding()
            }
        }
        .navigationTitle(loc.tr(.tile_tools))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            camera.configure()
            camera.start()
            VoiceSynthesizer.shared.speak(loc.tr(.tools_intro))
        }
        .onDisappear {
            camera.stop()
            VoiceSynthesizer.shared.stop()
        }
            .voiceGuide(.guide_tools)
    }

    private func instantToolButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusMedium).fill(color)
            )
        }
        .buttonStyle(.plain)
        .accessibleHitTarget(72)
    }

    // MARK: - Instant tools

    private func tellTime() {
        let f = DateFormatter()
        f.locale = Locale(identifier: loc.currentLanguage.speechLocale)
        f.dateStyle = .full
        f.timeStyle = .short
        let str = f.string(from: Date())
        result = str
        VoiceSynthesizer.shared.speak(str)
        HapticManager.shared.tap()
    }

    private func tellBattery() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        let pct: String
        if level >= 0 {
            pct = "\(Int(level * 100))%"
        } else {
            pct = "—"
        }
        let stateWord: String
        switch UIDevice.current.batteryState {
        case .charging: stateWord = chargingWord()
        case .full: stateWord = fullWord()
        default: stateWord = ""
        }
        let msg = batteryPhrase(percent: pct, state: stateWord)
        result = msg
        VoiceSynthesizer.shared.speak(msg)
        HapticManager.shared.tap()
    }

    // MARK: - Camera analysis

    private func captureAndAnalyze(_ tool: CameraTool) {
        guard !busy else { return }
        busy = true
        activeToolId = tool.id
        result = ""
        error = ""
        HapticManager.shared.tap()
        VoiceSynthesizer.shared.speak(loc.tr(.tools_capturing))

        Task {
            // Give the camera a moment to deliver a fresh frame.
            try? await Task.sleep(nanoseconds: 700_000_000)

            guard let jpeg = camera.currentSnapshotJPEG(quality: 0.7) else {
                let msg = loc.tr(.tools_no_snapshot)
                error = msg
                VoiceSynthesizer.shared.speak(msg)
                busy = false
                activeToolId = nil
                return
            }

            VoiceSynthesizer.shared.speak(loc.tr(.tools_processing))
            let base64 = jpeg.base64EncodedString()

            do {
                let reply = try await OllamaClient.shared.chatWithVision(
                    model: Config.visionModel,
                    prompt: tool.prompt,
                    imageBase64: base64
                )
                let trimmed = reply.trimmingCharacters(in: .whitespacesAndNewlines)
                result = trimmed
                VoiceSynthesizer.shared.speak(trimmed)
                HapticManager.shared.success()
            } catch {
                let fallback = loc.tr(.err_ollama_offline)
                self.error = fallback
                VoiceSynthesizer.shared.speak(fallback)
            }
            busy = false
            activeToolId = nil
        }
    }

    // MARK: - Localised prompt builder

    private func prompt(for kind: String) -> String {
        let lang = loc.currentLanguage
        switch (kind, lang) {
        case ("scene", .ru), ("scene", .system):
            return "Опиши коротко, что видно на фото. Только важное. До трёх предложений."
        case ("scene", .kk):
            return "Фотода не көрінетінін қысқаша сипатта. Тек маңызды нәрсе. Үш сөйлемге дейін."
        case ("scene", .en):
            return "Briefly describe what's in this photo. Only important things. Up to three sentences."

        case ("color", .ru), ("color", .system):
            return "Назови основные цвета предмета на фото. Одно короткое предложение."
        case ("color", .kk):
            return "Фотодағы заттың негізгі түстерін айтыңыз. Бір қысқа сөйлем."
        case ("color", .en):
            return "Name the main colours of the object in the photo. One short sentence."

        case ("money", .ru), ("money", .system):
            return "Распознай купюру на фото. Назови валюту и номинал. Если не видно — скажи коротко."
        case ("money", .kk):
            return "Фотодағы купюраны таны. Валюта мен номиналды айт. Көрінбесе — қысқа айт."
        case ("money", .en):
            return "Recognise the banknote in the photo. Say the currency and the value. If unclear, say so briefly."

        case ("light", .ru), ("light", .system):
            return "Светло на фото или темно? Ответь одним коротким предложением."
        case ("light", .kk):
            return "Фотода жарық па, әлде қараңғы ма? Бір қысқа сөйлеммен жауап бер."
        case ("light", .en):
            return "Is it bright or dark in the photo? Answer in one short sentence."

        case ("face", .ru), ("face", .system):
            return "Опиши человека на фото: пол, примерный возраст, выражение лица. Если лица нет — скажи."
        case ("face", .kk):
            return "Фотодағы адамды сипатта: жынысы, шамамен жасы, бет әлпеті. Адам жоқ болса — айт."
        case ("face", .en):
            return "Describe the person in the photo: gender, approximate age, expression. If there's no face — say so."

        case ("sign", .ru), ("sign", .system):
            return "Прочитай и кратко объясни табличку, дорожный знак или вывеску на фото. Если знак понятен — скажи его смысл в одну фразу."
        case ("sign", .kk):
            return "Фотодағы көрсеткішті, жол белгісін немесе жазуды оқып, қысқаша түсіндір. Бір сөйлеммен жауап бер."
        case ("sign", .en):
            return "Read and briefly explain the road sign, plaque, or signage in the photo. One short sentence."

        case ("document", .ru), ("document", .system):
            return "На фото — документ или чек. Распознай и перескажи самое важное: тип документа, суммы, даты, имена. До трёх предложений."
        case ("document", .kk):
            return "Фотода құжат немесе чек бар. Маңыздыны қысқаша айт: түрі, сомалар, күндер, атаулар. Үш сөйлемге дейін."
        case ("document", .en):
            return "The photo shows a document or receipt. Recognise and summarise the essentials: type, amounts, dates, names. Up to three sentences."

        case ("finder", .ru), ("finder", .system):
            return "Помоги слабовидящему найти на этом фото обычные предметы (ключи, телефон, пульт, очки, кошелёк, чашку, бутылку). Перечисли, что видишь и где оно расположено — слева, справа, в центре, на столе. До трёх предложений."
        case ("finder", .kk):
            return "Әлсіз көретін адамға фотодан жиі қажет заттарды (кілт, телефон, пульт, көзілдірік, әмиян, кесе, бөтелке) табуға көмектес. Не көріп тұрғаныңды және қайда екенін айт. Үш сөйлемге дейін."
        case ("finder", .en):
            return "Help a visually impaired user find common objects in this photo (keys, phone, remote, glasses, wallet, cup, bottle). List what you see and where it is — left, right, center, on the table. Up to three sentences."

        default:
            return "Опиши, что на фото."
        }
    }

    private func batteryPhrase(percent: String, state: String) -> String {
        let language = loc.currentLanguage
        switch language {
        case .ru, .system:
            return state.isEmpty ? "Батарея \(percent)" : "Батарея \(percent), \(state)"
        case .kk:
            return state.isEmpty ? "Батарея \(percent)" : "Батарея \(percent), \(state)"
        case .en:
            return state.isEmpty ? "Battery \(percent)" : "Battery \(percent), \(state)"
        }
    }

    private func chargingWord() -> String {
        switch loc.currentLanguage {
        case .ru, .system: return "заряжается"
        case .kk: return "зарядталып жатыр"
        case .en: return "charging"
        }
    }

    private func fullWord() -> String {
        switch loc.currentLanguage {
        case .ru, .system: return "заряжена полностью"
        case .kk: return "толық зарядталған"
        case .en: return "fully charged"
        }
    }
}
