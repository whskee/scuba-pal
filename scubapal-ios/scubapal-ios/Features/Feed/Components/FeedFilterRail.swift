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
                            .foregroundStyle(activeFilter == filter ? ScubaTheme.darkText : ScubaTheme.ink)
                            .padding(.horizontal, 14)
                            .frame(height: 40)
                            .background(activeFilter == filter ? ScubaTheme.primary : ScubaTheme.surface.opacity(0.82), in: Capsule())
                            .overlay(Capsule().stroke(activeFilter == filter ? ScubaTheme.primary : ScubaTheme.border, lineWidth: 1))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 18)
        }
        .scrollIndicators(.hidden)
    }
}
