import SwiftUI
import UIKit

/// Kaspi.kz / Halyk Bank launcher — mirrors Android BanksScreen.
/// Opens installed banking apps via deep-link, falls back to Safari.
struct BanksView: View {

    @EnvironmentObject private var loc: LocalizationManager

    struct Bank: Identifiable {
        let id: String
        let name: String
        let icon: String
        let color: Color
        let description: String
        let appScheme: String
        let webURL: String
    }

    private let banks: [Bank] = [
        Bank(id: "kaspi",
             name: "Kaspi.kz",
             icon: "creditcard.fill",
             color: Color(red: 0.95, green: 0.27, blue: 0.21),
             description: "Оплата по QR · переводы · баланс",
             appScheme: "kaspi://",
             webURL: "https://kaspi.kz/"),
        Bank(id: "halyk",
             name: "Halyk Bank",
             icon: "banknote.fill",
             color: Color(red: 0.0, green: 0.69, blue: 0.31),
             description: "Homebank · переводы · оплата услуг",
             appScheme: "homebank://",
             webURL: "https://homebank.kz/")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(loc.tr(.banks_intro))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)

                ForEach(banks) { bank in
                    Button {
                        openBank(bank)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: bank.icon)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 64, height: 64)
                                .background(RoundedRectangle(cornerRadius: 16).fill(bank.color))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(bank.name)
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Theme.primaryText)
                                Text(bank.description)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 20))
                                .foregroundStyle(bank.color)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
                                .stroke(bank.color.opacity(0.30), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibleHitTarget(72)
                    .accessibilityLabel(Text("\(bank.name). \(bank.description)"))
                }

                Text(loc.tr(.banks_hint))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
        }
        .navigationTitle(loc.tr(.tile_banks))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            VoiceSynthesizer.shared.speak(loc.tr(.banks_intro))
        }
            .voiceGuide(.guide_banks)
    }

    private func openBank(_ bank: Bank) {
        HapticManager.shared.tap()
        VoiceSynthesizer.shared.speak("\(loc.tr(.banks_opening)) \(bank.name)")
        if let url = URL(string: bank.appScheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let web = URL(string: bank.webURL) {
            UIApplication.shared.open(web)
        }
    }
}
