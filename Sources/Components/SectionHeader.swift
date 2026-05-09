import SwiftUI

struct SectionHeader: View {
    let key: LocalKey
    @EnvironmentObject private var loc: LocalizationManager
    var body: some View {
        HStack {
            Text(loc.tr(key).uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(Theme.secondaryText)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
}
