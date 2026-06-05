import Foundation

struct DiscoverRepository: Sendable {
    let apiClient: APIClient
    let mapper: DiscoveryMapper

    func locations(query: String) async throws -> [DiveLocation] {
        let endpoint = Endpoint(
            path: APIPath.locations,
            query: PageRequest(size: 80).queryParameters(adding: ["city": query])
        )
        let response: PageResponseDTO<DiveLocationDTO> = try await apiClient.request(endpoint)
        return try (response.content ?? []).map(mapper.map)
    }

    func shops(query: String) async throws -> [DiveShop] {
        let endpoint = Endpoint(
            path: APIPath.shops,
            query: PageRequest(size: 80).queryParameters(adding: ["q": query])
        )
        let response: PageResponseDTO<DiveShopDTO> = try await apiClient.request(endpoint)
        return try (response.content ?? []).map(mapper.map)
    }

    func learnArticles() async throws -> [LearnArticle] {
        let response: [LearnArticleDTO] = try await apiClient.request(
            Endpoint(path: APIPath.learnArticles)
        )
        return try response.map(mapper.map)
    }
}
