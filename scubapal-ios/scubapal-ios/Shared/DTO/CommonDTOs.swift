import Foundation

struct PageMetaDTO: Codable {
    var page: Int?
    var size: Int?
    var totalElements: Int?
    var totalPages: Int?
    var hasNext: Bool?
}

struct PageResponseDTO<Content: Codable>: Codable {
    var content: [Content]?
    var meta: PageMetaDTO?
}

struct APIErrorBody: Codable {
    var message: String?
    var error: String?
    var detail: String?
    var status: Int?
}
