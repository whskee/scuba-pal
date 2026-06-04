import Foundation

struct DiscoverRepository: Sendable {
    let apiClient: APIClient
    let mapper: DiscoveryMapper

    func locations(query: String) async throws -> [DiveLocation] {
        let endpoint = Endpoint(
            path: "/api/locations",
            query: ["city": query, "page": "0", "size": "80"]
        )
        let response: PageResponseDTO<DiveLocationDTO> = try await apiClient.request(endpoint)
        return try (response.content ?? []).map(mapper.map)
    }

    func shops(query: String) async throws -> [DiveShop] {
        let endpoint = Endpoint(
            path: "/api/shops",
            query: ["q": query, "page": "0", "size": "80"]
        )
        let response: PageResponseDTO<DiveShopDTO> = try await apiClient.request(endpoint)
        return try (response.content ?? []).map(mapper.map)
    }

    func learnArticles() async throws -> [LearnArticle] {
        let response: [LearnArticleDTO] = try await apiClient.request(
            Endpoint(path: "/api/learn/articles")
        )
        return try response.map(mapper.map)
    }
}
