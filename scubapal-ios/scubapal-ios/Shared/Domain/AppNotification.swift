import Foundation

struct AppNotification: Identifiable, Hashable {
    var id: Int
    var title: String
    var body: String
    var read: Bool
    var createdAt: Date
    var type: String?
}
