import SwiftUI

struct FeedFilterRail: View {
    let filters: [String]
    @Binding var activeFilter: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation(.snappy(duration: 0.22)) {
                            activeFilter = filter
                        }
                    } label: {
                        Text(filter)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(activeFilter == filter ? ScubaTheme.darkText : ScubaTheme.muted)
                            .padding(.horizontal, 15)
                            .frame(height: 38)
                            .background(activeFilter == filter ? ScubaTheme.reefGradient : LinearGradient(colors: [ScubaTheme.surface.opacity(0.76), ScubaTheme.background2.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing), in: Capsule())
                            .overlay(Capsule().stroke(activeFilter == filter ? ScubaTheme.reef.opacity(0.6) : ScubaTheme.border, lineWidth: 1))
                            .shadow(color: activeFilter == filter ? ScubaTheme.primary.opacity(0.22) : .clear, radius: 12, x: 0, y: 7)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 18)
        }
        .scrollIndicators(.hidden)
    }
}
