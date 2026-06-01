import Foundation
import SwiftUI

enum TargetAudience: String, Codable, CaseIterable {
    case arthouse = "Arthouse"
    case families = "Familien"
    case teens = "Teenager"
    case adults = "Erwachsene"
    case fans = "Fans"
    case vip = "VIP"
}

enum MissionKind: String, Codable {
    case earnCoins
    case buildRooms
    case sellTickets
    case reachLevel
    case unlockFilm
    case satisfaction
    case reputation
}

enum GameEventKind: String, Codable, CaseIterable {
    case celebrityVisit
    case projectorIssue
    case localFestival
    case viralReview
    case cleaningRush
}

struct BuildingDefinition: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let baseCost: Double
    let incomePerSecond: Double
    let customerBonus: Double
    let satisfactionBonus: Double
    let reputationBonus: Double
    let unlockLevel: Int
}

struct FilmDefinition: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let popularity: Double
    let runtimeMinutes: Int
    let revenueBonus: Double
    let audience: TargetAudience
    let unlockCost: Double
    let unlockLevel: Int
}

struct EmployeeDefinition: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let baseCost: Double
    let customerMultiplier: Double
    let incomeMultiplier: Double
    let waitTimeReduction: Double
    let satisfactionBonus: Double
    let offlineBonus: Double
    let unlockLevel: Int
}

struct UpgradeDefinition: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let baseCost: Double
    let maxLevel: Int
    let incomeMultiplierPerLevel: Double
    let satisfactionPerLevel: Double
    let reputationPerLevel: Double
    let unlockLevel: Int
}

struct ResearchDefinition: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let cost: Double
    let requiredLevel: Int
    let incomeMultiplier: Double
    let customerMultiplier: Double
    let offlineMultiplier: Double
}

struct LocationDefinition: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let unlockCost: Double
    let requiredLevel: Int
    let incomeMultiplier: Double
    let reputationReward: Double
}

struct MissionDefinition: Identifiable, Codable {
    let id: String
    let title: String
    let detail: String
    let kind: MissionKind
    let target: Double
    let rewardCoins: Double
    let rewardXP: Double
}

struct AchievementDefinition: Identifiable, Codable {
    let id: String
    let title: String
    let detail: String
    let kind: MissionKind
    let target: Double
    let rewardReputation: Double
}

struct ActiveGameEvent: Identifiable, Codable {
    let id: String
    let kind: GameEventKind
    let title: String
    let detail: String
    let expiresAt: Date
    let incomeMultiplier: Double
    let customerMultiplier: Double
    let satisfactionDelta: Double
}

struct FloatingCoin: Identifiable {
    let id = UUID()
    let text: String
}

struct GameState: Codable {
    var coins: Double = 1_000
    var lifetimeCoins: Double = 0
    var level: Int = 1
    var xp: Double = 0
    var reputation: Double = 0
    var ticketsSold: Int = 0
    var vipCustomers: Int = 0
    var prestigePoints: Int = 0
    var prestigeRuns: Int = 0
    var customerSatisfaction: Double = 62
    var totalCustomers: Double = 12
    var lastLogin: Date = Date()
    var lastEventAt: Date = Date()
    var buildings: [String: Int] = ["small_screen": 1]
    var buildingLevels: [String: Int] = ["small_screen": 1]
    var unlockedFilms: Set<String> = ["indie"]
    var activeFilmId: String = "indie"
    var employees: [String: Int] = [:]
    var upgrades: [String: Int] = [:]
    var completedMissions: Set<String> = []
    var achievements: Set<String> = []
    var completedResearch: Set<String> = []
    var unlockedLocations: Set<String> = ["neighborhood"]
    var activeEvents: [ActiveGameEvent] = []
    var snackbarSales: Int = 0
}

extension GameState {
    static let fresh = GameState()
}

