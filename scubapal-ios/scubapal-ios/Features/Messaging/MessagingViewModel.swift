import Combine
import Foundation

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
            state = .loaded(items)
        } catch {
            state = .failed(error.localizedDescription)
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
            messages = .loaded(items.sorted { $0.createdAt < $1.createdAt })
        } catch {
            messages = .failed(error.localizedDescription)
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
        messages = .loaded(current)

        do {
            try await repository.sendMessage(conversationID: conversationID, body: body)
            await load()
            return nil
        } catch {
            if var rollback = messages.value {
                rollback.removeAll { $0.id == optimistic.id }
                messages = .loaded(rollback)
            }
            return error.localizedDescription
        }
    }
}
