import Foundation
import Security

/// Tiny wrapper around the Keychain for secrets we don't want in UserDefaults.
/// Currently used for the user's Ollama tunnel URL.
enum KeychainStore {

    private static let service = "com.pierceindustries.winx"

    enum Key: String {
        case ollamaBaseURL
        case openAIKey
        case elevenLabsKey
        case geminiKey
        case xaiKey
    }

    @discardableResult
    static func set(_ value: String?, for key: Key) -> Bool {
        let account = key.rawValue
        if let value, !value.isEmpty, let data = value.data(using: .utf8) {
            // Update or add.
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attrs: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
            let updateStatus = SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
            if updateStatus == errSecItemNotFound {
                var addQuery = query
                addQuery.merge(attrs) { _, new in new }
                let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
                return addStatus == errSecSuccess
            }
            return updateStatus == errSecSuccess
        } else {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            return SecItemDelete(query as CFDictionary) == errSecSuccess
        }
    }

    static func get(_ key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    // MARK: - Convenience

    static var ollamaBaseURL: String? {
        get { get(.ollamaBaseURL) ?? Config.defaultOllamaBaseURL.nonEmpty }
        set { set(newValue, for: .ollamaBaseURL) }
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
