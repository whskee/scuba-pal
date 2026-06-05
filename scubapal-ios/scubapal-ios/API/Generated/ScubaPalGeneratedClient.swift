import Foundation
import OpenAPIURLSession
import ScubaPalAPI

struct ScubaPalGeneratedClient {
    let client: Client

    init(baseURL: URL) {
        client = Client(
            serverURL: baseURL,
            transport: URLSessionTransport()
        )
    }
}
