import Foundation

actor APIClient {
    private let config: AppConfig
    private let session: URLSession
    private let tokenStore: any TokenStore
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private var tokenPair: TokenPair?
    private var refreshTask: Task<TokenPair, Error>?

    init(
        config: AppConfig,
        tokenStore: any TokenStore,
        session: URLSession? = nil
    ) {
        self.config = config
        self.tokenStore = tokenStore

        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = AppConfig.requestTimeout
            configuration.timeoutIntervalForResource = AppConfig.requestTimeout
            configuration.waitsForConnectivity = true
            self.session = URLSession(configuration: configuration)
        }

        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    func setTokenPair(_ tokenPair: TokenPair?) {
        self.tokenPair = tokenPair
    }

    func currentTokenPair() -> TokenPair? {
        tokenPair
    }

    func request<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        try await request(endpoint, bodyData: nil)
    }

    func request<Response: Decodable, Body: Encodable>(
        _ endpoint: Endpoint,
        body: Body
    ) async throws -> Response {
        let bodyData: Data
        do {
            bodyData = try encoder.encode(body)
        } catch {
            throw APIError.encoding("Could not encode the request: \(error.localizedDescription)")
        }
        return try await request(endpoint, bodyData: bodyData)
    }

    func requestNoContent(_ endpoint: Endpoint) async throws {
        let _: EmptyResponse = try await request(endpoint, bodyData: nil)
    }

    func requestNoContent<Body: Encodable>(_ endpoint: Endpoint, body: Body) async throws {
        let _: EmptyResponse = try await request(endpoint, body: body)
    }

    private func request<Response: Decodable>(
        _ endpoint: Endpoint,
        bodyData: Data?,
        retrying: Bool = false
    ) async throws -> Response {
        var urlRequest = try makeURLRequest(endpoint: endpoint, bodyData: bodyData)
        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        if http.statusCode == 401, endpoint.requiresAuth, !retrying, tokenPair?.refreshToken != nil {
            tokenPair = try await refreshTokens()
            urlRequest = try makeURLRequest(endpoint: endpoint, bodyData: bodyData)
            let (retryData, retryResponse) = try await session.data(for: urlRequest)
            guard let retryHTTP = retryResponse as? HTTPURLResponse else { throw APIError.invalidResponse }
            return try decodeResponse(retryData, status: retryHTTP.statusCode)
        }

        return try decodeResponse(data, status: http.statusCode)
    }

    private func makeURLRequest(endpoint: Endpoint, bodyData: Data?) throws -> URLRequest {
        let path = endpoint.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard var components = URLComponents(
            url: config.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidBaseURL
        }

        let queryItems = endpoint.query
            .filter { !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted { $0.key < $1.key }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        guard let url = components.url else { throw APIError.invalidBaseURL }

        var request = URLRequest(url: url, timeoutInterval: AppConfig.requestTimeout)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let bodyData {
            request.httpBody = bodyData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if endpoint.requiresAuth, let token = tokenPair?.accessToken, !token.isEmpty {
            request.setValue(token.hasPrefix("Bearer ") ? token : "Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func decodeResponse<Response: Decodable>(_ data: Data, status: Int) throws -> Response {
        guard (200..<300).contains(status) else {
            let apiError = try? decoder.decode(APIErrorBody.self, from: data)
            let message = apiError?.message
                ?? apiError?.detail
                ?? apiError?.error
                ?? HTTPURLResponse.localizedString(forStatusCode: status)
            if status == 401 { throw APIError.unauthorized }
            throw APIError.server(message: message, status: status)
        }

        if Response.self == EmptyResponse.self {
            return EmptyResponse() as! Response
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding("Could not decode the server response: \(error.localizedDescription)")
        }
    }

    private func refreshTokens() async throws -> TokenPair {
        if let refreshTask { return try await refreshTask.value }
        guard let refreshToken = tokenPair?.refreshToken else { throw APIError.unauthorized }

        let task = Task<TokenPair, Error> {
            let endpoint = Endpoint(path: "/api/auth/refresh", method: .post, requiresAuth: false)
            let response: AuthResponse = try await request(
                endpoint,
                body: RefreshTokenRequest(refreshToken: refreshToken)
            )
            guard let accessToken = response.accessToken else { throw APIError.unauthorized }
            let pair = TokenPair(
                accessToken: accessToken,
                refreshToken: response.refreshToken ?? refreshToken
            )
            try tokenStore.save(pair)
            return pair
        }
        refreshTask = task
        defer { refreshTask = nil }
        return try await task.value
    }
}

private struct EmptyResponse: Decodable {}
