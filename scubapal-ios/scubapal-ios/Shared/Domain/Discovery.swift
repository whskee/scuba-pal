import Foundation

struct DiveLocation: Identifiable, Hashable {
    var id: Int
    var name: String
    var description: String?
    var imageUrl: URL?
    var city: String?
    var state: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    // TODO: Type this when the backend exposes a fixed difficulty enum.
    var difficultyLevel: String?
    var popularityScore: Double?
}

struct DiveShop: Identifiable, Hashable {
    var id: Int
    var name: String
    var description: String?
    var imageUrl: URL?
    var phoneNumber: String?
    var email: String?
    var websiteUrl: String?
    var streetAddress: String?
    var city: String?
    var state: String?
    var country: String?
    var locationName: String?
}

struct LearnArticle: Identifiable, Hashable {
    var id: Int
    var slug: String
    var title: String
    var summary: String
    var content: String
    var category: String
    // TODO: Type this when the backend exposes a fixed difficulty enum.
    var difficultyLevel: String
    var estimatedMinutes: Int
    var updatedAt: Date
}
