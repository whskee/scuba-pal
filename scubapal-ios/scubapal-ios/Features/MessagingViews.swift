import SwiftUI

struct ConversationsView: View {
    @EnvironmentObject private var session: AppSession
    @State private var conversations: Loadable<[Conversation]> = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BrandedScreenHeader(
                    title: "Messages",
                    eyebrow: "Buddy chat",
                    subtitle: "Private dive buddy chats, kept fast and focused.",
                    systemImage: "bubble.left.and.bubble.right.fill"
                ) {
                    IconCircleButton(systemImage: "arrow.clockwise", badge: session.unreadMessages) {
                        Task { await load() }
                    }
                }

                content
            }
            .padding(.top, 14)
            .padding(.bottom, 104)
        }
        .scrollIndicators(.hidden)
        .refreshable { await load() }
        .navigationDestination(for: Conversation.self) { conversation in
            ThreadView(conversation: conversation)
        }
        .task { await load() }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 12) {
            switch conversations {
            case .idle, .loading:
                ProgressView()
                    .tint(ScubaTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
            case let .failed(message):
                EmptyStateView(title: "Messages unavailable", message: message, systemImage: "wifi.exclamationmark")
            case let .loaded(items):
                if items.isEmpty {
                    EmptyStateView(title: "No conversations", message: "Open a diver profile to start a message thread.", systemImage: "bubble.left.and.bubble.right")
                } else {
                    ForEach(items) { conversation in
                        NavigationLink(value: conversation) {
                            ConversationRow(conversation: conversation)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 18)
    }

    private func load() async {
        conversations = .loading
        do {
            let items = try await session.api.conversations()
            withAnimation(.smooth(duration: 0.28)) { conversations = .loaded(items) }
            await session.refreshBadges()
        } catch {
            withAnimation(.smooth(duration: 0.2)) { conversations = .failed(error.localizedDescription) }
        }
    }
}

private struct ConversationRow: View {
    var conversation: Conversation

    var body: some View {
        HStack(spacing: 13) {
            AvatarView(user: conversation.participant, size: 56)
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text("@\(conversation.participant.username)")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(ScubaTheme.ink)
                        .lineLimit(1)
                    Spacer()
                    Text(conversation.updatedAt.relativeShort())
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(ScubaTheme.muted)
                }
                HStack(spacing: 10) {
                    Text(conversation.lastMessage)
                        .font(.system(size: 14, weight: conversation.unreadCount > 0 ? .heavy : .medium))
                        .foregroundStyle(conversation.unreadCount > 0 ? ScubaTheme.ink : ScubaTheme.muted)
                        .lineLimit(1)
                    Spacer()
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(ScubaTheme.darkText)
                            .frame(minWidth: 26, minHeight: 26)
                            .background(ScubaTheme.primary, in: Capsule())
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(ScubaTheme.muted)
                    }
                }
            }
        }
        .padding(14)
        .glassPanel(radius: 26, fill: conversation.unreadCount > 0 ? ScubaTheme.surface2.opacity(0.64) : ScubaTheme.surface.opacity(0.62), border: conversation.unreadCount > 0 ? ScubaTheme.primary.opacity(0.55) : ScubaTheme.border)
    }
}

struct ThreadView: View {
    @EnvironmentObject private var session: AppSession
    var conversation: Conversation
    @State private var messages: Loadable<[ChatMessage]> = .idle
    @State private var draft = ""
    @State private var isSending = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 11) {
                        switch messages {
                        case .idle, .loading:
                            ProgressView()
                                .tint(ScubaTheme.primary)
                                .padding(.top, 32)
                        case let .failed(message):
                            EmptyStateView(title: "Thread unavailable", message: message, systemImage: "wifi.exclamationmark")
                        case let .loaded(items):
                            if items.isEmpty {
                                EmptyStateView(title: "No messages", message: "Send the first dive note.", systemImage: "paperplane")
                            } else {
                                ForEach(items) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                        }
                    }
                    .padding(18)
                    .padding(.bottom, 10)
                }
                .scrollIndicators(.hidden)
                .onChange(of: messagesCount) { _, _ in
                    if let last = messages.value?.last {
                        withAnimation(.smooth(duration: 0.28)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            composer
        }
        .appBackground()
        .navigationTitle("@\(conversation.participant.username)")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private var messagesCount: Int {
        messages.value?.count ?? 0
    }

    private var composer: some View {
        HStack(spacing: 10) {
            FloatingTextField(title: "Message", text: $draft, systemImage: "bubble.left.fill")
            Button {
                send()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(draft.nilIfBlank == nil || isSending ? ScubaTheme.muted : ScubaTheme.primary)
            }
            .disabled(draft.nilIfBlank == nil || isSending)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(.ultraThinMaterial)
    }

    private func load() async {
        messages = .loading
        do {
            let items = try await session.api.messages(conversationID: conversation.id)
            withAnimation(.smooth(duration: 0.28)) { messages = .loaded(items.sorted { $0.createdAt < $1.createdAt }) }
            await session.refreshBadges()
        } catch {
            withAnimation(.smooth(duration: 0.2)) { messages = .failed(error.localizedDescription) }
        }
    }

    private func send() {
        guard let body = draft.nilIfBlank else { return }
        draft = ""
        isSending = true

        let optimistic = ChatMessage(
            id: Int(Date().timeIntervalSince1970 * 1000),
            senderId: session.currentUser?.id ?? 0,
            senderProfileImageUrl: nil,
            body: body,
            createdAt: Date(),
            sentByCurrentUser: true
        )

        if var current = messages.value {
            current.append(optimistic)
            withAnimation(.snappy(duration: 0.2)) { messages = .loaded(current) }
        }

        Task {
            do {
                try await session.api.sendMessage(conversationID: conversation.id, body: body)
                await load()
            } catch {
                session.showToast(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
            }
            isSending = false
        }
    }
}

private struct MessageBubble: View {
    var message: ChatMessage

    var body: some View {
        HStack {
            if message.sentByCurrentUser { Spacer(minLength: 42) }
            VStack(alignment: message.sentByCurrentUser ? .trailing : .leading, spacing: 5) {
                Text(message.body)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(message.sentByCurrentUser ? ScubaTheme.darkText : ScubaTheme.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(message.sentByCurrentUser ? ScubaTheme.primary : ScubaTheme.surface2.opacity(0.76), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(message.createdAt.relativeShort())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(ScubaTheme.muted)
                    .padding(.horizontal, 4)
            }
            if !message.sentByCurrentUser { Spacer(minLength: 42) }
        }
        .transition(.move(edge: message.sentByCurrentUser ? .trailing : .leading).combined(with: .opacity))
    }
}
