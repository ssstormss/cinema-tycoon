import Foundation
import Combine

final class GameEngine: ObservableObject {
    @Published private(set) var state: GameState
    @Published var offlineReward: Double = 0
    @Published var floatingCoins: [FloatingCoin] = []
    @Published var eventMessage: String?

    private var timer: AnyCancellable?
    private var saveTimer: AnyCancellable?

    init(state: GameState = SaveStore.load()) {
        self.state = state
        applyOfflineIncome()
        evaluateProgress()
        startTimers()
    }

    var activeFilm: FilmDefinition {
        GameCatalog.films.first { $0.id == state.activeFilmId } ?? GameCatalog.films[0]
    }

    var incomePerSecond: Double {
        let buildingIncome = GameCatalog.buildings.reduce(0) { partial, building in
            let count = Double(state.buildings[building.id, default: 0])
            let level = Double(state.buildingLevels[building.id, default: 1])
            return partial + count * building.incomePerSecond * pow(1.18, max(0, level - 1))
        }
        let upgrades = 1 + GameCatalog.upgrades.reduce(0) { partial, upgrade in
            partial + Double(state.upgrades[upgrade.id, default: 0]) * upgrade.incomeMultiplierPerLevel
        }
        let employees = 1 + GameCatalog.employees.reduce(0) { partial, employee in
            partial + Double(state.employees[employee.id, default: 0]) * employee.incomeMultiplier
        }
        let research = 1 + GameCatalog.research.reduce(0) { partial, item in
            state.completedResearch.contains(item.id) ? partial + item.incomeMultiplier : partial
        }
        let locations = GameCatalog.locations.reduce(1.0) { partial, location in
            state.unlockedLocations.contains(location.id) ? partial * location.incomeMultiplier : partial
        }
        let eventMultiplier = activeEventsMultiplier
        let prestige = 1 + Double(state.prestigePoints) * 0.08
        let satisfaction = max(0.35, state.customerSatisfaction / 100)
        return max(0, buildingIncome * activeFilm.revenueBonus * upgrades * employees * research * locations * eventMultiplier * prestige * satisfaction)
    }

    var customersPerMinute: Double {
        let buildings = GameCatalog.buildings.reduce(0) { partial, building in
            partial + Double(state.buildings[building.id, default: 0]) * building.customerBonus
        }
        let employees = 1 + GameCatalog.employees.reduce(0) { partial, employee in
            partial + Double(state.employees[employee.id, default: 0]) * employee.customerMultiplier
        }
        let research = 1 + GameCatalog.research.reduce(0) { partial, item in
            state.completedResearch.contains(item.id) ? partial + item.customerMultiplier : partial
        }
        let eventMultiplier = state.activeEvents.reduce(1.0) { $0 * $1.customerMultiplier }
        return max(1, buildings * activeFilm.popularity * employees * eventMultiplier)
    }

    var offlineMultiplier: Double {
        let employees = GameCatalog.employees.reduce(0.25) { partial, employee in
            partial + Double(state.employees[employee.id, default: 0]) * employee.offlineBonus
        }
        let research = GameCatalog.research.reduce(0) { partial, item in
            state.completedResearch.contains(item.id) ? partial + item.offlineMultiplier : partial
        }
        return min(0.95, employees + research + Double(state.prestigePoints) * 0.01)
    }

    var xpForNextLevel: Double {
        120 * pow(1.28, Double(state.level - 1))
    }

    var ticketTapValue: Double {
        max(3, incomePerSecond * 3.5 + Double(state.level) * 2)
    }

    var canPrestige: Bool {
        state.level >= 25 && state.lifetimeCoins >= 1_000_000
    }

    func sellTickets() {
        let tickets = max(1, Int(customersPerMinute / 8))
        let earned = ticketTapValue * Double(tickets)
        state.ticketsSold += tickets
        state.totalCustomers += Double(tickets)
        state.coins += earned
        state.lifetimeCoins += earned
        state.xp += 8 + Double(tickets)
        state.snackbarSales += Int(Double(tickets) * snackSaleRate)
        state.customerSatisfaction = min(100, state.customerSatisfaction + 0.05)
        floatingCoins.append(FloatingCoin(text: "+\(formatShort(earned))"))
        trimFloatingCoins()
        evaluateProgress()
        save()
    }

    func buyBuilding(_ building: BuildingDefinition) {
        let cost = buildingCost(building)
        guard state.level >= building.unlockLevel, state.coins >= cost else { return }
        state.coins -= cost
        state.buildings[building.id, default: 0] += 1
        state.buildingLevels[building.id] = max(1, state.buildingLevels[building.id, default: 1])
        state.reputation += building.reputationBonus
        state.customerSatisfaction = min(100, state.customerSatisfaction + building.satisfactionBonus * 0.25)
        state.xp += 35 + cost * 0.01
        evaluateProgress()
        save()
    }

    func upgradeBuilding(_ building: BuildingDefinition) {
        guard state.buildings[building.id, default: 0] > 0 else { return }
        let cost = buildingUpgradeCost(building)
        guard state.coins >= cost else { return }
        state.coins -= cost
        state.buildingLevels[building.id, default: 1] += 1
        state.xp += 25 + cost * 0.008
        state.reputation += building.reputationBonus * 0.5
        evaluateProgress()
        save()
    }

    func unlockFilm(_ film: FilmDefinition) {
        guard state.level >= film.unlockLevel, state.coins >= film.unlockCost else { return }
        guard !state.unlockedFilms.contains(film.id) else {
            state.activeFilmId = film.id
            save()
            return
        }
        state.coins -= film.unlockCost
        state.unlockedFilms.insert(film.id)
        state.activeFilmId = film.id
        state.reputation += film.revenueBonus * 2
        state.xp += film.unlockCost * 0.02
        evaluateProgress()
        save()
    }

    func selectFilm(_ film: FilmDefinition) {
        guard state.unlockedFilms.contains(film.id) else { return }
        state.activeFilmId = film.id
        save()
    }

    func hire(_ employee: EmployeeDefinition) {
        let cost = employeeCost(employee)
        guard state.level >= employee.unlockLevel, state.coins >= cost else { return }
        state.coins -= cost
        state.employees[employee.id, default: 0] += 1
        state.customerSatisfaction = min(100, state.customerSatisfaction + employee.satisfactionBonus * 0.2)
        state.xp += 30 + cost * 0.01
        evaluateProgress()
        save()
    }

    func buyUpgrade(_ upgrade: UpgradeDefinition) {
        let current = state.upgrades[upgrade.id, default: 0]
        let cost = upgradeCost(upgrade)
        guard current < upgrade.maxLevel, state.level >= upgrade.unlockLevel, state.coins >= cost else { return }
        state.coins -= cost
        state.upgrades[upgrade.id] = current + 1
        state.customerSatisfaction = min(100, state.customerSatisfaction + upgrade.satisfactionPerLevel)
        state.reputation += upgrade.reputationPerLevel
        state.xp += 25 + cost * 0.012
        evaluateProgress()
        save()
    }

    func completeResearch(_ research: ResearchDefinition) {
        guard state.level >= research.requiredLevel, !state.completedResearch.contains(research.id), state.coins >= research.cost else { return }
        state.coins -= research.cost
        state.completedResearch.insert(research.id)
        state.xp += research.cost * 0.015
        state.reputation += 4
        evaluateProgress()
        save()
    }

    func unlockLocation(_ location: LocationDefinition) {
        guard state.level >= location.requiredLevel, !state.unlockedLocations.contains(location.id), state.coins >= location.unlockCost else { return }
        state.coins -= location.unlockCost
        state.unlockedLocations.insert(location.id)
        state.reputation += location.reputationReward
        state.xp += location.unlockCost * 0.01
        evaluateProgress()
        save()
    }

    func launchAdCampaign() {
        let cost = 600 * pow(1.42, Double(state.level - 1))
        guard state.coins >= cost else { return }
        state.coins -= cost
        let bonusCustomers = 35 + Double(state.level) * 4
        state.totalCustomers += bonusCustomers
        state.reputation += 1.8
        state.xp += 80
        addTemporaryEvent(kind: .viralReview)
        evaluateProgress()
        save()
    }

    func hostEvent() {
        let cost = 1_400 * pow(1.5, Double(state.level - 1))
        guard state.coins >= cost else { return }
        state.coins -= cost
        state.vipCustomers += 8 + state.level
        state.reputation += 4
        state.customerSatisfaction = min(100, state.customerSatisfaction + 3.5)
        addTemporaryEvent(kind: .celebrityVisit)
        evaluateProgress()
        save()
    }

    func claimMission(_ mission: MissionDefinition) {
        guard !state.completedMissions.contains(mission.id), missionProgress(mission) >= mission.target else { return }
        state.completedMissions.insert(mission.id)
        state.coins += mission.rewardCoins
        state.lifetimeCoins += mission.rewardCoins
        state.xp += mission.rewardXP
        evaluateProgress()
        save()
    }

    func prestige() {
        guard canPrestige else { return }
        let earnedPrestige = max(1, Int(log10(max(10, state.lifetimeCoins / 100_000))) + state.level / 10)
        let previousPrestige = state.prestigePoints
        let previousRuns = state.prestigeRuns
        let savedResearch = state.completedResearch
        state = GameState.fresh
        state.prestigePoints = previousPrestige + earnedPrestige
        state.prestigeRuns = previousRuns + 1
        state.completedResearch = savedResearch.filter { $0 == "overnight_ops" || $0 == "franchise_ai" }
        eventMessage = "Prestige gestartet: +\(earnedPrestige) Sternenpunkte"
        save()
    }

    func resetGame() {
        SaveStore.reset()
        state = .fresh
        offlineReward = 0
        floatingCoins.removeAll()
        save()
    }

    func buildingCost(_ building: BuildingDefinition) -> Double {
        let count = Double(state.buildings[building.id, default: 0])
        return building.baseCost * pow(1.32, count)
    }

    func buildingUpgradeCost(_ building: BuildingDefinition) -> Double {
        let level = Double(state.buildingLevels[building.id, default: 1])
        return building.baseCost * 0.75 * pow(1.45, level - 1)
    }

    func employeeCost(_ employee: EmployeeDefinition) -> Double {
        let count = Double(state.employees[employee.id, default: 0])
        return employee.baseCost * pow(1.38, count)
    }

    func upgradeCost(_ upgrade: UpgradeDefinition) -> Double {
        let level = Double(state.upgrades[upgrade.id, default: 0])
        return upgrade.baseCost * pow(1.5, level)
    }

    func missionProgress(_ mission: MissionDefinition) -> Double {
        switch mission.kind {
        case .earnCoins:
            return state.lifetimeCoins
        case .buildRooms:
            return Double(cinemaRoomCount)
        case .sellTickets:
            return Double(state.ticketsSold)
        case .reachLevel:
            return Double(state.level)
        case .unlockFilm:
            return state.unlockedFilms.contains("blockbuster") ? 1 : 0
        case .satisfaction:
            return state.customerSatisfaction
        case .reputation:
            return state.reputation
        }
    }

    func achievementProgress(_ achievement: AchievementDefinition) -> Double {
        switch achievement.kind {
        case .earnCoins:
            return state.lifetimeCoins
        case .buildRooms:
            return Double(cinemaRoomCount)
        case .sellTickets:
            if achievement.id == "ach_first_hire" {
                return Double(state.employees.values.reduce(0, +))
            }
            return Double(state.ticketsSold)
        case .reachLevel:
            return Double(state.level)
        case .unlockFilm:
            return state.unlockedFilms.contains("blockbuster") ? 1 : 0
        case .satisfaction:
            return state.customerSatisfaction
        case .reputation:
            return state.reputation
        }
    }

    var cinemaRoomCount: Int {
        ["small_screen", "large_screen", "luxury_screen", "imax_screen", "four_d_screen"].reduce(0) {
            $0 + state.buildings[$1, default: 0]
        }
    }

    var snackSaleRate: Double {
        let snacks = state.buildings["snack_bar", default: 0] + state.buildings["drink_stand", default: 0]
        return min(1.0, 0.12 + Double(snacks) * 0.08)
    }

    func formatShort(_ value: Double) -> String {
        let absValue = abs(value)
        if absValue >= 1_000_000_000 { return String(format: "%.2fB", value / 1_000_000_000) }
        if absValue >= 1_000_000 { return String(format: "%.2fM", value / 1_000_000) }
        if absValue >= 1_000 { return String(format: "%.1fK", value / 1_000) }
        return String(format: "%.0f", value)
    }

    private var activeEventsMultiplier: Double {
        state.activeEvents.reduce(1.0) { $0 * $1.incomeMultiplier }
    }

    private func startTimers() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.tick()
        }
        saveTimer = Timer.publish(every: 8, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.save()
        }
    }

    private func tick() {
        let earned = incomePerSecond
        state.coins += earned
        state.lifetimeCoins += earned
        state.xp += max(1, earned * 0.018)
        state.totalCustomers += customersPerMinute / 60
        state.ticketsSold += max(0, Int(customersPerMinute / 60))
        state.snackbarSales += max(0, Int(customersPerMinute / 100))
        state.customerSatisfaction = adjustedSatisfaction()
        clearExpiredEvents()
        maybeTriggerRandomEvent()
        evaluateProgress()
    }

    private func applyOfflineIncome() {
        let elapsed = min(28_800, max(0, Date().timeIntervalSince(state.lastLogin)))
        guard elapsed > 30 else { return }
        let earned = elapsed * incomePerSecond * offlineMultiplier
        offlineReward = earned
        state.coins += earned
        state.lifetimeCoins += earned
        state.xp += earned * 0.012
        state.totalCustomers += elapsed * customersPerMinute / 120
    }

    private func evaluateProgress() {
        while state.xp >= xpForNextLevel {
            state.xp -= xpForNextLevel
            state.level += 1
            state.coins += Double(state.level) * 120
            state.reputation += 0.8
        }

        for achievement in GameCatalog.achievements where !state.achievements.contains(achievement.id) {
            if achievementProgress(achievement) >= achievement.target {
                state.achievements.insert(achievement.id)
                state.reputation += achievement.rewardReputation
                eventMessage = "\(achievement.title) freigeschaltet"
            }
        }
    }

    private func adjustedSatisfaction() -> Double {
        let buildingBonus = GameCatalog.buildings.reduce(0) { partial, building in
            partial + Double(state.buildings[building.id, default: 0]) * building.satisfactionBonus * 0.03
        }
        let employeeBonus = GameCatalog.employees.reduce(0) { partial, employee in
            partial + Double(state.employees[employee.id, default: 0]) * employee.satisfactionBonus * 0.015
        }
        let eventDelta = state.activeEvents.reduce(0) { $0 + $1.satisfactionDelta }
        let roomPressure = max(0, customersPerMinute / max(8, Double(cinemaRoomCount) * 38) - 1) * 0.08
        return min(100, max(25, state.customerSatisfaction + buildingBonus + employeeBonus + eventDelta - roomPressure))
    }

    private func maybeTriggerRandomEvent() {
        guard Date().timeIntervalSince(state.lastEventAt) > 75 else { return }
        guard Int.random(in: 0...100) < 18 else { return }
        state.lastEventAt = Date()
        addTemporaryEvent(kind: GameEventKind.allCases.randomElement() ?? .localFestival)
    }

    private func addTemporaryEvent(kind: GameEventKind) {
        let event: ActiveGameEvent
        switch kind {
        case .celebrityVisit:
            event = .init(id: UUID().uuidString, kind: kind, title: "Starbesuch", detail: "VIPs stroemen ins Kino.", expiresAt: Date().addingTimeInterval(90), incomeMultiplier: 1.18, customerMultiplier: 1.25, satisfactionDelta: 0.08)
        case .projectorIssue:
            event = .init(id: UUID().uuidString, kind: kind, title: "Projektorproblem", detail: "Technik kostet kurz Zufriedenheit.", expiresAt: Date().addingTimeInterval(70), incomeMultiplier: 0.92, customerMultiplier: 0.95, satisfactionDelta: -0.18)
        case .localFestival:
            event = .init(id: UUID().uuidString, kind: kind, title: "Stadtfestival", detail: "Mehr Laufkundschaft besucht die Vorstellungen.", expiresAt: Date().addingTimeInterval(110), incomeMultiplier: 1.08, customerMultiplier: 1.32, satisfactionDelta: 0.03)
        case .viralReview:
            event = .init(id: UUID().uuidString, kind: kind, title: "Virale Kritik", detail: "Dein Kino trendet.", expiresAt: Date().addingTimeInterval(100), incomeMultiplier: 1.22, customerMultiplier: 1.16, satisfactionDelta: 0.05)
        case .cleaningRush:
            event = .init(id: UUID().uuidString, kind: kind, title: "Saubere Saele", detail: "Das Publikum merkt die Extra-Schicht.", expiresAt: Date().addingTimeInterval(80), incomeMultiplier: 1.03, customerMultiplier: 1.05, satisfactionDelta: 0.22)
        }
        state.activeEvents.append(event)
        eventMessage = event.title
    }

    private func clearExpiredEvents() {
        state.activeEvents.removeAll { $0.expiresAt <= Date() }
    }

    private func trimFloatingCoins() {
        if floatingCoins.count > 5 {
            floatingCoins.removeFirst(floatingCoins.count - 5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            if !self.floatingCoins.isEmpty {
                self.floatingCoins.removeFirst()
            }
        }
    }

    func save() {
        state.lastLogin = Date()
        SaveStore.save(state)
    }
}
