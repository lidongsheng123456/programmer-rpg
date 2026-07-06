import Foundation

/// \u6301\u4e45\u5316\u5c42\u534f\u8bae\uff0c\u7c7b\u6bd4 Spring Boot \u7684 JPA \u63a5\u53e3
protocol PersistenceProtocol: Sendable {
    func save<T: Encodable>(_ value: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
    func remove(forKey key: String)
    func getString(forKey key: String) -> String?
    func setString(_ value: String, forKey key: String)
}
