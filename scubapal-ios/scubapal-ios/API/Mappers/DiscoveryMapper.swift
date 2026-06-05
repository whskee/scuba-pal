import Foundation

struct DiscoveryMapper: Sendable {
    let mediaURLResolver: MediaURLResolver

    func map(_ input: DiveLocationDTO) throws -> DiveLocation {
        DiveLocation(
            id: try RequiredField.value(input.locationId, "locationId"),
            name: try RequiredField.nonBlank(input.locationName, "locationName"),
            description: input.description,
            imageUrl: mediaURLResolver.resolve(input.imageUrl),
            city: input.city,
            state: input.state,
            country: input.country,
            latitude: input.latitude,
            longitude: input.longitude,
            difficultyLevel: input.difficultyLevel,
            popularityScore: input.popularityScore
        )
    }

    func map(_ input: DiveShopDTO) throws -> DiveShop {
        DiveShop(
            id: try RequiredField.value(input.shopId, "shopId"),
            name: try RequiredField.nonBlank(input.shopName, "shopName"),
            description: input.description,
            imageUrl: mediaURLResolver.resolve(input.imageUrl),
            phoneNumber: input.phoneNumber,
            email: input.email,
            websiteUrl: input.websiteUrl,
            streetAddress: input.streetAddress,
            city: input.city,
            state: input.state,
            country: input.country,
            locationName: input.locationName
        )
    }

    func map(_ input: LearnArticleDTO) throws -> LearnArticle {
        LearnArticle(
            id: try RequiredField.value(input.articleId, "articleId"),
            slug: try RequiredField.nonBlank(input.slug, "article.slug"),
            title: try RequiredField.nonBlank(input.title, "article.title"),
            summary: input.summary ?? "",
            content: input.content ?? "",
            category: input.category ?? "Learning",
            difficultyLevel: input.difficultyLevel ?? "Beginner",
            estimatedMinutes: input.estimatedMinutes ?? 5,
            updatedAt: try DateParsing.fromAPI(input.updatedAt, field: "article.updatedAt")
        )
    }
}
