import Foundation

struct DiveLocationDTO: Codable, Hashable {
    var locationId: Int?
    var locationName: String?
    var description: String?
    var imageUrl: String?
    var city: String?
    var state: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    // TODO: Type this when the backend exposes a fixed difficulty enum.
    var difficultyLevel: String?
    var popularityScore: Double?
}

struct DiveShopDTO: Codable, Hashable {
    var shopId: Int?
    var shopName: String?
    var description: String?
    var phoneNumber: String?
    var email: String?
    var websiteUrl: String?
    var imageUrl: String?
    var streetAddress: String?
    var city: String?
    var state: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    var locationId: Int?
    var locationName: String?
}

struct LearnArticleDTO: Codable, Hashable {
    var articleId: Int?
    var slug: String?
    var title: String?
    var summary: String?
    var content: String?
    var category: String?
    // TODO: Type this when the backend exposes a fixed difficulty enum.
    var difficultyLevel: String?
    var estimatedMinutes: Int?
    var updatedAt: String?
}
