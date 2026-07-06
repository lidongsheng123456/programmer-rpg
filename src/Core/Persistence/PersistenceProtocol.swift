import Foundation

protocol PersistenceProtocol: Sendable {
    func save<T: Encodable>(_ value: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
    func remove(forKey key: String)
    func getString(forKey key: String) -> String?
    func setString(_ value: String, forKey key: String)
}
