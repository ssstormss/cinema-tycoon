import Foundation

enum SaveStore {
    private static let key = "cinema_empire_tycoon_save_v1"

    static func load() -> GameState {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return .fresh
        }

        do {
            return try JSONDecoder().decode(GameState.self, from: data)
        } catch {
            return .fresh
        }
    }

    static func save(_ state: GameState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

