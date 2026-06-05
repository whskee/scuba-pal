import SwiftUI

struct LoadableCollectionView<Item, Content: View, EmptyContent: View>: View {
    let state: Loadable<[Item]>
    let loadingTopPadding: CGFloat
    let errorTitle: String
    let errorSystemImage: String
    @ViewBuilder let emptyContent: () -> EmptyContent
    @ViewBuilder let content: ([Item]) -> Content

    init(
        state: Loadable<[Item]>,
        loadingTopPadding: CGFloat = 32,
        errorTitle: String,
        errorSystemImage: String = "wifi.exclamationmark",
        @ViewBuilder emptyContent: @escaping () -> EmptyContent,
        @ViewBuilder content: @escaping ([Item]) -> Content
    ) {
        self.state = state
        self.loadingTopPadding = loadingTopPadding
        self.errorTitle = errorTitle
        self.errorSystemImage = errorSystemImage
        self.emptyContent = emptyContent
        self.content = content
    }

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .tint(ScubaTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, loadingTopPadding)
        case let .failed(message):
            EmptyStateView(title: errorTitle, message: message, systemImage: errorSystemImage)
        case let .loaded(items):
            if items.isEmpty {
                emptyContent()
            } else {
                content(items)
            }
        }
    }
}

struct LoadableValueView<Value, Content: View>: View {
    let state: Loadable<Value>
    let loadingTopPadding: CGFloat
    let errorTitle: String
    let errorSystemImage: String
    @ViewBuilder let content: (Value) -> Content

    init(
        state: Loadable<Value>,
        loadingTopPadding: CGFloat = 32,
        errorTitle: String,
        errorSystemImage: String,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.state = state
        self.loadingTopPadding = loadingTopPadding
        self.errorTitle = errorTitle
        self.errorSystemImage = errorSystemImage
        self.content = content
    }

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .tint(ScubaTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, loadingTopPadding)
        case let .failed(message):
            EmptyStateView(title: errorTitle, message: message, systemImage: errorSystemImage)
        case let .loaded(value):
            content(value)
        }
    }
}
