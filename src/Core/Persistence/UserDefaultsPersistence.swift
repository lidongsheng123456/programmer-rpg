import Foundation

final class UserDefaultsPersistence: PersistenceProtocol {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(suiteName: String? = AppConfig.appGroupIdentifier) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    func save<T: Encodable>(_ value: T, forKey key: String) throws {
        let data = try encoder.encode(value)
        defaults.set(data, forKey: key)
    }

    func load<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try decoder.decode(T.self, from: data)
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    func getString(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    func setString(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
