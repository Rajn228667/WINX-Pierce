import SwiftUI

/// Live foreign-exchange rates against the Kazakhstani tenge.
///
/// Data source: `open.er-api.com` — a free, key-less, CORS-enabled mirror of
/// the European Central Bank reference rates. Results are cached locally so
/// the screen stays useful when offline. Tap any currency to hear the rate
/// read aloud in the active language.
struct CurrencyView: View {

    @EnvironmentObject private var loc: LocalizationManager
    @StateObject private var vm = CurrencyRatesViewModel()

    var body: some View {
        List {
            Section {
                if vm.isLoading && vm.rates.isEmpty {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text(loc.tr(.common_loading))
                    }
                } else if let err = vm.error, vm.rates.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(err, systemImage: "wifi.exclamationmark")
                            .foregroundStyle(Theme.brandRed)
                        Button(loc.tr(.common_retry)) { Task { await vm.refresh() } }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    ForEach(vm.rates) { rate in
                        Button { vm.speak(rate, locale: loc.currentLocale) } label: {
                            HStack(spacing: 16) {
                                Text(rate.flag)
                                    .font(.system(size: 36))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(rate.code)
                                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                                        .foregroundStyle(Theme.primaryText)
                                    Text(rate.name(loc: loc))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(formatted(rate.kztPerUnit, locale: loc.currentLocale))
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                        .monospacedDigit()
                                        .foregroundStyle(Theme.primaryText)
                                    Text("за 1 \(rate.code)")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                Text(headerTitle)
                    .font(.system(size: 13, weight: .semibold))
            } footer: {
                if let updated = vm.updatedAt {
                    Text("Обновлено: \(updated.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 12))
                }
            }
        }
        .navigationTitle(Text(loc.tr(.tile_currency)))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await vm.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .bold))
                }
                .accessibilityLabel(Text(loc.tr(.common_retry)))
            }
        }
        .task { await vm.start() }
        .refreshable { await vm.refresh() }
            .voiceGuide(.guide_currency)
    }

    private var headerTitle: String {
        loc.tr(.tile_currency)
    }

    private func formatted(_ value: Double, locale: Locale) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        f.locale = locale
        return f.string(from: NSNumber(value: value)) ?? "—"
    }
}

// MARK: - View-Model

@MainActor
final class CurrencyRatesViewModel: ObservableObject {

    @Published private(set) var rates: [Rate] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var updatedAt: Date?

    struct Rate: Identifiable, Codable, Equatable {
        var id: String { code }
        let code: String
        let kztPerUnit: Double

        var flag: String {
            switch code {
            case "USD": return "🇺🇸"
            case "EUR": return "🇪🇺"
            case "RUB": return "🇷🇺"
            case "CNY": return "🇨🇳"
            case "GBP": return "🇬🇧"
            case "TRY": return "🇹🇷"
            case "AED": return "🇦🇪"
            case "JPY": return "🇯🇵"
            case "KRW": return "🇰🇷"
            default: return "🌐"
            }
        }

        func name(loc: LocalizationManager) -> String {
            let nf = Locale.current.localizedString(forCurrencyCode: code) ?? code
            return nf.capitalized
        }
    }

    private let cacheURL: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.appendingPathComponent("currency_rates.json")
    }()

    /// Currencies we care about, in display order.
    private let watchlist = ["USD", "EUR", "RUB", "CNY", "GBP", "TRY", "AED", "JPY", "KRW"]

    func start() async {
        if rates.isEmpty {
            loadCache()
            if rates.isEmpty || (updatedAt.map { Date().timeIntervalSince($0) > 60 * 60 } ?? true) {
                await refresh()
            }
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let url = URL(string: "https://open.er-api.com/v6/latest/KZT")!
            let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let decoded = try JSONDecoder().decode(OpenERResponse.self, from: data)
            // open.er-api gives KZT->other. We want other->KZT, so invert.
            let now = Date()
            var newRates: [Rate] = []
            for code in watchlist {
                guard let kztPerOther = decoded.rates[code], kztPerOther > 0 else { continue }
                let otherToKzt = 1.0 / kztPerOther
                newRates.append(Rate(code: code, kztPerUnit: otherToKzt))
            }
            self.rates = newRates
            self.updatedAt = now
            self.error = nil
            saveCache()
        } catch {
            self.error = LocalizationManager.shared.tr(.err_network)
        }
    }

    func speak(_ rate: Rate, locale: Locale) {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.locale = locale
        let value = f.string(from: NSNumber(value: rate.kztPerUnit)) ?? "\(rate.kztPerUnit)"
        let phrase: String
        switch locale.identifier {
        case let s where s.hasPrefix("kk"):
            phrase = "1 \(rate.code) — \(value) теңге"
        case let s where s.hasPrefix("en"):
            phrase = "1 \(rate.code) is \(value) tenge"
        default:
            phrase = "1 \(rate.code) — \(value) тенге"
        }
        VoiceSynthesizer.shared.speak(phrase)
        HapticManager.shared.tap()
    }

    // MARK: - Cache

    private struct CacheBlob: Codable {
        let rates: [Rate]
        let updatedAt: Date
    }

    private func saveCache() {
        guard let date = updatedAt else { return }
        let blob = CacheBlob(rates: rates, updatedAt: date)
        if let data = try? JSONEncoder().encode(blob) {
            try? data.write(to: cacheURL)
        }
    }

    private func loadCache() {
        guard let data = try? Data(contentsOf: cacheURL),
              let blob = try? JSONDecoder().decode(CacheBlob.self, from: data) else { return }
        self.rates = blob.rates
        self.updatedAt = blob.updatedAt
    }
}

// MARK: - DTO

private struct OpenERResponse: Decodable {
    let rates: [String: Double]
}
