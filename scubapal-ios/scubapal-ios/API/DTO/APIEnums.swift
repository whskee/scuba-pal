enum VisibilityStatus: String, Codable, Hashable, Sendable {
    case publicStatus = "PUBLIC"
    case privateStatus = "PRIVATE"
}

enum UserRole: String, Codable, Hashable, Sendable {
    case admin = "ADMIN"
    case moderator = "MODERATOR"
    case shopOwner = "SHOP_OWNER"
    case user = "USER"
}
