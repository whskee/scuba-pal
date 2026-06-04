import Combine
import SwiftUI

@MainActor
final class ConversationsViewModel: ObservableObject {
    @Published private(set) var state: Loadable<[Conversation]> = .idle

    private let repository: MessagingRepository

    init(repository: MessagingRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let items = try await repository.conversations()
            withAnimation(.smooth(duration: 0.28)) { state = .loaded(items) }
        } catch {
            withAnimation(.smooth(duration: 0.2)) { state = .failed(error.localizedDescription) }
        }
    }
}

@MainActor
final class ThreadViewModel: ObservableObject {
    @Published private(set) var messages: Loadable<[ChatMessage]> = .idle
    @Published private(set) var isSending = false

    private let conversationID: Int
    private let repository: MessagingRepository
    private var nextOptimisticID = -1

    init(conversationID: Int, repository: MessagingRepository) {
        self.conversationID = conversationID
        self.repository = repository
    }

    func load() async {
        messages = .loading
        do {
            let items = try await repository.messages(conversationID: conversationID)
            withAnimation(.smooth(duration: 0.28)) {
                messages = .loaded(items.sorted { $0.createdAt < $1.createdAt })
            }
        } catch {
            withAnimation(.smooth(duration: 0.2)) { messages = .failed(error.localizedDescription) }
        }
    }

    func send(body: String, senderID: Int?) async -> String? {
        isSending = true
        defer { isSending = false }

        let optimistic = ChatMessage(
            id: nextOptimisticID,
            senderId: senderID ?? 0,
            senderProfileImageUrl: nil,
            body: body,
            createdAt: Date(),
            sentByCurrentUser: true
        )
        nextOptimisticID -= 1

        var current = messages.value ?? []
        current.append(optimistic)
        withAnimation(.snappy(duration: 0.2)) { messages = .loaded(current) }

        do {
            try await repository.sendMessage(conversationID: conversationID, body: body)
            await load()
            return nil
        } catch {
            if var rollback = messages.value {
                rollback.removeAll { $0.id == optimistic.id }
                withAnimation(.snappy(duration: 0.2)) { messages = .loaded(rollback) }
            }
            return error.localizedDescription
        }
    }
}
