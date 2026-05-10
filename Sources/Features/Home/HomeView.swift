import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var voiceControl: VoiceControlEngine
    @State private var showAccessibility: Bool = false
    @State private var presentedRoute: VoiceIntent?

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 16) {
                        HeaderView()

                        // Time-of-day greeting (mirrors Android HomeScreen)
                        GreetingBanner()
                            .padding(.horizontal, 16)

                        // Hero AI Companion card
                        NavigationLink {
                            AICompanionView()
                                .navigationTitle(loc.tr(.tile_ai_companion))
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HeroCompanionCard {} // tap handled by NavigationLink
                                .allowsHitTesting(false)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)

                        // EYES
                        SectionHeader(key: .section_eyes)
                        LazyVGrid(columns: columns, spacing: 14) {
                            BigActionTile(
                                titleKey: .tile_scan,
                                subtitleKey: .tile_scan_subtitle,
                                systemImage: "camera.viewfinder",
                                accent: Theme.accentBlue
                            ) { VisionScanView() }
                            BigActionTile(
                                titleKey: .tile_magnifier,
                                subtitleKey: .tile_magnifier_subtitle,
                                systemImage: "eye",
                                accent: Theme.accentSky
                            ) { MagnifierView() }
                            BigActionTile(
                                titleKey: .tile_currency,
                                subtitleKey: .tile_currency_subtitle,
                                systemImage: "banknote.fill",
                                accent: Theme.accentOrange
                            ) { CurrencyView() }
                            BigActionTile(
                                titleKey: .tile_scene,
                                subtitleKey: .tile_scene_subtitle,
                                systemImage: "rectangle.3.group.fill",
                                accent: Theme.accentPurple
                            ) { SceneUnderstandingView() }
                            BigActionTile(
                                titleKey: .tile_tools,
                                subtitleKey: .tile_tools_subtitle,
                                systemImage: "wrench.and.screwdriver.fill",
                                accent: Theme.accentEmerald
                            ) { ToolsView() }
                        }
                        .padding(.horizontal, 16)

                        // VOICE & HEARING
                        SectionHeader(key: .section_voice)
                        LazyVGrid(columns: columns, spacing: 14) {
                            BigActionTile(
                                titleKey: .tile_ai_companion,
                                subtitleKey: .tile_ai_companion_subtitle,
                                systemImage: "sparkles",
                                accent: Theme.brandRed
                            ) { AICompanionView() }
                            BigActionTile(
                                titleKey: .tile_cards,
                                subtitleKey: .tile_cards_subtitle,
                                systemImage: "hand.raised.fill",
                                accent: Theme.accentSky
                            ) { CardsView() }
                            BigActionTile(
                                titleKey: .tile_listen,
                                subtitleKey: .tile_listen_subtitle,
                                systemImage: "ear",
                                accent: Theme.accentOrange
                            ) { ListenView() }
                            BigActionTile(
                                titleKey: .tile_ask,
                                subtitleKey: .tile_ask_subtitle,
                                systemImage: "text.bubble.fill",
                                accent: Theme.accentPurple
                            ) { AskView() }
                        }
                        .padding(.horizontal, 16)

                        // MOVEMENT
                        SectionHeader(key: .section_movement)
                        LazyVGrid(columns: columns, spacing: 14) {
                            BigActionTile(
                                titleKey: .tile_locator,
                                subtitleKey: .tile_locator_subtitle,
                                systemImage: "location.viewfinder",
                                accent: Theme.accentPurple
                            ) { LocatorView() }
                            BigActionTile(
                                titleKey: .tile_walking,
                                subtitleKey: .tile_walking_subtitle,
                                systemImage: "figure.walk",
                                accent: Theme.accentGreen
                            ) { WalkingView() }
                            BigActionTile(
                                titleKey: .tile_navigation,
                                subtitleKey: .tile_navigation_subtitle,
                                systemImage: "map.fill",
                                accent: Theme.accentBlue
                            ) { NavigationFeatureView() }
                            BigActionTile(
                                titleKey: .tile_sos,
                                subtitleKey: .tile_sos_subtitle,
                                systemImage: "sos",
                                accent: Theme.accentRed
                            ) { EmergencyView() }
                        }
                        .padding(.horizontal, 16)

                        // LIFE
                        SectionHeader(key: .section_life)
                        LazyVGrid(columns: columns, spacing: 14) {
                            BigActionTile(
                                titleKey: .tile_health,
                                subtitleKey: .tile_health_subtitle,
                                systemImage: "heart.fill",
                                accent: Theme.accentRed
                            ) { HealthView() }
                            BigActionTile(
                                titleKey: .tile_learning,
                                subtitleKey: .tile_learning_subtitle,
                                systemImage: "book.fill",
                                accent: Theme.accentPurple
                            ) { LearningView() }
                            BigActionTile(
                                titleKey: .tile_whatsapp,
                                subtitleKey: .tile_whatsapp_subtitle,
                                systemImage: "phone.bubble.fill",
                                accent: Theme.accentEmerald
                            ) { WhatsAppView() }
                            BigActionTile(
                                titleKey: .tile_telegram,
                                subtitleKey: .tile_telegram_subtitle,
                                systemImage: "paperplane.fill",
                                accent: Theme.accentBlue
                            ) { TelegramView() }
                            BigActionTile(
                                titleKey: .tile_music,
                                subtitleKey: .tile_music_subtitle,
                                systemImage: "music.note",
                                accent: Theme.accentOrange
                            ) { MusicView() }
                            BigActionTile(
                                titleKey: .tile_diary,
                                subtitleKey: .tile_diary_subtitle,
                                systemImage: "text.book.closed.fill",
                                accent: Theme.accentGreen
                            ) { DiaryView() }
                            BigActionTile(
                                titleKey: .tile_banks,
                                subtitleKey: .tile_banks_subtitle,
                                systemImage: "creditcard.fill",
                                accent: Theme.accentRed
                            ) { BanksView() }
                        }
                        .padding(.horizontal, 16)

                        // SMART HOME / COMFORT
                        SectionHeader(key: .section_smart)
                        LazyVGrid(columns: columns, spacing: 14) {
                            BigActionTile(
                                titleKey: .tile_smart_home,
                                subtitleKey: .tile_smart_home_subtitle,
                                systemImage: "house.fill",
                                accent: Theme.accentBlue
                            ) { SmartHomeView() }
                            BigActionTile(
                                titleKey: .tile_eye_comfort,
                                subtitleKey: .tile_eye_comfort_subtitle,
                                systemImage: "sun.max.fill",
                                accent: Theme.accentYellow
                            ) { EyeComfortView() }
                            BigActionTile(
                                titleKey: .tile_accessibility,
                                subtitleKey: .tile_accessibility_subtitle,
                                systemImage: "accessibility",
                                accent: Theme.accentPurple
                            ) { AccessibilityCenterView() }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 110)
                    }
                }
                .scrollIndicators(.hidden)
                .background(Theme.background)

                BottomVoiceBar { showAccessibility = true }
            }
            .navigationDestination(item: $presentedRoute) { intent in
                destinationView(for: intent)
            }
            .sheet(isPresented: $showAccessibility) {
                NavigationStack {
                    AccessibilityCenterView()
                        .navigationTitle(loc.tr(.tile_accessibility))
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .onChange(of: voiceControl.lastIntent) { newValue in
            guard let v = newValue else { return }
            presentedRoute = v
        }
        .eyeComfortOverlay()
    }

    @ViewBuilder
    private func destinationView(for intent: VoiceIntent) -> some View {
        switch intent {
        case .openCompanion: AICompanionView()
        case .openVision: VisionScanView()
        case .openOCR: OCRReaderView()
        case .openMagnifier: MagnifierView()
        case .openNavigation: NavigationFeatureView()
        case .openLocator: LocatorView()
        case .openWalking: WalkingView()
        case .openSOS: EmergencyView()
        case .openHealth: HealthView()
        case .openLearning: LearningView()
        case .openWhatsApp: WhatsAppView()
        case .openTelegram: TelegramView()
        case .openMusic: MusicView()
        case .openDiary: DiaryView()
        case .openSmartHome: SmartHomeView()
        case .openEyeComfort: EyeComfortView()
        case .openScene: SceneUnderstandingView()
        case .openAccessibility: AccessibilityCenterView()
        case .openCards: CardsView()
        case .openListen: ListenView()
        case .openCurrency: CurrencyView()
        case .stopAll: AICompanionView()
        }
    }
}

extension VoiceIntent: Identifiable, Hashable {
    var id: String { rawValue }
}
