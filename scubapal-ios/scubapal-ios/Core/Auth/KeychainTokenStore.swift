import Foundation
import Security

enum TokenStoreError: LocalizedError {
    case keychain(status: OSStatus)
    case encoding
    case decoding

    var errorDescription: String? {
        switch self {
        case let .keychain(status):
            "Keychain operation failed with status \(status)."
        case .encoding:
            "The session could not be securely encoded."
        case .decoding:
            "The saved session could not be decoded."
        }
    }
}

struct KeychainTokenStore: TokenStore {
    private let service: String
    private let account: String

    init(
        service: String = "com.scubapal.ios.session",
        account: String = "scubapal-token-pair"
    ) {
        self.service = service
        self.account = account
    }

    func load() throws -> TokenPair? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw TokenStoreError.keychain(status: status)
        }
        guard let tokenPair = try? JSONDecoder().decode(TokenPair.self, from: data) else {
            throw TokenStoreError.decoding
        }
        return tokenPair
    }

    func save(_ tokenPair: TokenPair) throws {
        guard let data = try? JSONEncoder().encode(tokenPair) else {
            throw TokenStoreError.encoding
        }

        var attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess { return }
        guard updateStatus == errSecItemNotFound else {
            throw TokenStoreError.keychain(status: updateStatus)
        }

        attributes.merge(baseQuery) { current, _ in current }
        let addStatus = SecItemAdd(attributes as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw TokenStoreError.keychain(status: addStatus)
        }
    }

    func delete() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw TokenStoreError.keychain(status: status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
