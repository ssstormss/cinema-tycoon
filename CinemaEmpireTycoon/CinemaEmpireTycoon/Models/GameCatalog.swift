import Foundation

enum GameCatalog {
    static let buildings: [BuildingDefinition] = [
        .init(id: "small_screen", name: "Kleiner Kinosaal", icon: "theatermasks.fill", description: "Ein intimer Saal fuer Indie-Hits und erste Stammkunden.", baseCost: 350, incomePerSecond: 2.2, customerBonus: 6, satisfactionBonus: 1.0, reputationBonus: 0.05, unlockLevel: 1),
        .init(id: "large_screen", name: "Grosser Kinosaal", icon: "rectangle.on.rectangle.angled", description: "Mehr Sitze, groessere Premieren, stabilere Einnahmen.", baseCost: 1_800, incomePerSecond: 8.5, customerBonus: 18, satisfactionBonus: 1.5, reputationBonus: 0.15, unlockLevel: 2),
        .init(id: "luxury_screen", name: "Luxus-Saal", icon: "sofa.fill", description: "Bequeme Sitze und Premiumpreise fuer anspruchsvolle Gaeste.", baseCost: 8_000, incomePerSecond: 27, customerBonus: 24, satisfactionBonus: 3.5, reputationBonus: 0.5, unlockLevel: 5),
        .init(id: "imax_screen", name: "IMAX-Saal", icon: "sparkles.tv.fill", description: "Riesige Leinwand, riesige Nachfrage.", baseCost: 35_000, incomePerSecond: 96, customerBonus: 65, satisfactionBonus: 4.5, reputationBonus: 1.4, unlockLevel: 9),
        .init(id: "four_d_screen", name: "4D-Saal", icon: "wind", description: "Effekte, Bewegung und hoehere Ticketpreise.", baseCost: 120_000, incomePerSecond: 265, customerBonus: 110, satisfactionBonus: 6, reputationBonus: 3, unlockLevel: 14),
        .init(id: "snack_bar", name: "Snack-Bar", icon: "popcorn.fill", description: "Popcorn, Suesses und der Duft nach Umsatz.", baseCost: 850, incomePerSecond: 4.5, customerBonus: 4, satisfactionBonus: 2.5, reputationBonus: 0.1, unlockLevel: 1),
        .init(id: "drink_stand", name: "Getraenke-Stand", icon: "takeoutbag.and.cup.and.straw.fill", description: "Kalte Drinks fuer lange Filmnaechte.", baseCost: 1_250, incomePerSecond: 5.8, customerBonus: 5, satisfactionBonus: 2, reputationBonus: 0.12, unlockLevel: 2),
        .init(id: "arcade", name: "Arcade-Bereich", icon: "gamecontroller.fill", description: "Wartezeiten werden zu extra Umsatz.", baseCost: 6_500, incomePerSecond: 18, customerBonus: 20, satisfactionBonus: 3, reputationBonus: 0.45, unlockLevel: 4),
        .init(id: "merch", name: "Merchandise-Shop", icon: "tshirt.fill", description: "Poster, Shirts und Sammlerartikel fuer Fans.", baseCost: 14_000, incomePerSecond: 36, customerBonus: 16, satisfactionBonus: 1.5, reputationBonus: 0.8, unlockLevel: 6),
        .init(id: "vip_lounge", name: "VIP-Lounge", icon: "crown.fill", description: "Lockt VIPs an und steigert Ruf spuerbar.", baseCost: 55_000, incomePerSecond: 105, customerBonus: 35, satisfactionBonus: 6.5, reputationBonus: 2.6, unlockLevel: 10),
        .init(id: "parking", name: "Parkhaus", icon: "parkingsign.circle.fill", description: "Mehr Komfort, mehr Besucher zu Stosszeiten.", baseCost: 90_000, incomePerSecond: 80, customerBonus: 140, satisfactionBonus: 4, reputationBonus: 1.7, unlockLevel: 12),
        .init(id: "studio", name: "Filmstudio", icon: "movieclapper.fill", description: "Eigene Premieren und dauerhafte Imperiumsboni.", baseCost: 420_000, incomePerSecond: 680, customerBonus: 260, satisfactionBonus: 5, reputationBonus: 8, unlockLevel: 18)
    ]

    static let films: [FilmDefinition] = [
        .init(id: "indie", name: "Indie-Film", icon: "camera.aperture", popularity: 1.0, runtimeMinutes: 92, revenueBonus: 1.00, audience: .arthouse, unlockCost: 0, unlockLevel: 1),
        .init(id: "action", name: "Actionfilm", icon: "flame.fill", popularity: 1.18, runtimeMinutes: 118, revenueBonus: 1.12, audience: .adults, unlockCost: 850, unlockLevel: 2),
        .init(id: "horror", name: "Horrorfilm", icon: "moon.stars.fill", popularity: 1.22, runtimeMinutes: 101, revenueBonus: 1.15, audience: .teens, unlockCost: 1_900, unlockLevel: 3),
        .init(id: "comedy", name: "Komoedie", icon: "face.smiling.fill", popularity: 1.28, runtimeMinutes: 96, revenueBonus: 1.18, audience: .families, unlockCost: 4_000, unlockLevel: 4),
        .init(id: "scifi", name: "Sci-Fi", icon: "atom", popularity: 1.42, runtimeMinutes: 132, revenueBonus: 1.32, audience: .fans, unlockCost: 12_500, unlockLevel: 7),
        .init(id: "hero", name: "Superheldenfilm", icon: "bolt.shield.fill", popularity: 1.65, runtimeMinutes: 145, revenueBonus: 1.55, audience: .families, unlockCost: 35_000, unlockLevel: 10),
        .init(id: "anime", name: "Anime-Film", icon: "sparkle.magnifyingglass", popularity: 1.72, runtimeMinutes: 110, revenueBonus: 1.62, audience: .fans, unlockCost: 75_000, unlockLevel: 13),
        .init(id: "blockbuster", name: "Blockbuster", icon: "star.circle.fill", popularity: 2.05, runtimeMinutes: 155, revenueBonus: 2.0, audience: .adults, unlockCost: 180_000, unlockLevel: 16),
        .init(id: "premiere", name: "Exklusiv-Premiere", icon: "rosette", popularity: 2.65, runtimeMinutes: 170, revenueBonus: 2.8, audience: .vip, unlockCost: 600_000, unlockLevel: 22)
    ]

    static let employees: [EmployeeDefinition] = [
        .init(id: "cashier", name: "Kassierer", icon: "person.text.rectangle.fill", baseCost: 500, customerMultiplier: 0.025, incomeMultiplier: 0.015, waitTimeReduction: 0.04, satisfactionBonus: 0.5, offlineBonus: 0.01, unlockLevel: 1),
        .init(id: "popcorn_seller", name: "Popcorn-Verkaeufer", icon: "popcorn.fill", baseCost: 900, customerMultiplier: 0.015, incomeMultiplier: 0.035, waitTimeReduction: 0.01, satisfactionBonus: 0.8, offlineBonus: 0.015, unlockLevel: 2),
        .init(id: "technician", name: "Filmtechniker", icon: "wrench.and.screwdriver.fill", baseCost: 2_400, customerMultiplier: 0.01, incomeMultiplier: 0.025, waitTimeReduction: 0.02, satisfactionBonus: 1.8, offlineBonus: 0.02, unlockLevel: 4),
        .init(id: "cleaner", name: "Reinigungskraft", icon: "sparkles", baseCost: 2_100, customerMultiplier: 0.01, incomeMultiplier: 0.01, waitTimeReduction: 0.01, satisfactionBonus: 2.2, offlineBonus: 0.01, unlockLevel: 3),
        .init(id: "manager", name: "Manager", icon: "briefcase.fill", baseCost: 9_000, customerMultiplier: 0.045, incomeMultiplier: 0.05, waitTimeReduction: 0.035, satisfactionBonus: 1.2, offlineBonus: 0.04, unlockLevel: 7),
        .init(id: "marketing", name: "Marketing-Experte", icon: "megaphone.fill", baseCost: 13_000, customerMultiplier: 0.075, incomeMultiplier: 0.025, waitTimeReduction: 0.0, satisfactionBonus: 0.6, offlineBonus: 0.03, unlockLevel: 8),
        .init(id: "security", name: "Sicherheitsdienst", icon: "shield.lefthalf.filled", baseCost: 18_000, customerMultiplier: 0.02, incomeMultiplier: 0.015, waitTimeReduction: 0.02, satisfactionBonus: 2.8, offlineBonus: 0.02, unlockLevel: 9)
    ]

    static let upgrades: [UpgradeDefinition] = [
        .init(id: "ticket_kiosks", name: "Digitale Ticketkioske", icon: "ticket.fill", description: "Schnellere Tickets und bessere Spitzenzeiten.", baseCost: 700, maxLevel: 30, incomeMultiplierPerLevel: 0.025, satisfactionPerLevel: 0.35, reputationPerLevel: 0.04, unlockLevel: 1),
        .init(id: "premium_seats", name: "Premium-Sitze", icon: "chair.lounge.fill", description: "Komfort verkauft Tickets teurer.", baseCost: 1_400, maxLevel: 35, incomeMultiplierPerLevel: 0.035, satisfactionPerLevel: 0.55, reputationPerLevel: 0.07, unlockLevel: 2),
        .init(id: "sound_system", name: "Dolby-Sound", icon: "speaker.wave.3.fill", description: "Besserer Sound macht jeden Film wertvoller.", baseCost: 3_500, maxLevel: 30, incomeMultiplierPerLevel: 0.045, satisfactionPerLevel: 0.45, reputationPerLevel: 0.09, unlockLevel: 4),
        .init(id: "snack_recipe", name: "Popcorn-Rezept", icon: "birthday.cake.fill", description: "Mehr Snackgewinn mit jeder Portion.", baseCost: 5_000, maxLevel: 25, incomeMultiplierPerLevel: 0.04, satisfactionPerLevel: 0.25, reputationPerLevel: 0.05, unlockLevel: 5),
        .init(id: "brand_campaign", name: "Markenkampagne", icon: "megaphone.fill", description: "Mehr Ruf und mehr Besucher fuer alle Standorte.", baseCost: 12_000, maxLevel: 40, incomeMultiplierPerLevel: 0.03, satisfactionPerLevel: 0.2, reputationPerLevel: 0.2, unlockLevel: 8),
        .init(id: "vip_service", name: "VIP-Service", icon: "crown.fill", description: "Luxusgaeste zahlen gerne mehr.", baseCost: 40_000, maxLevel: 20, incomeMultiplierPerLevel: 0.07, satisfactionPerLevel: 0.65, reputationPerLevel: 0.35, unlockLevel: 11)
    ]

    static let research: [ResearchDefinition] = [
        .init(id: "dynamic_pricing", name: "Dynamische Preise", icon: "chart.line.uptrend.xyaxis", description: "Tickets passen sich Nachfrage und Filmhype an.", cost: 9_500, requiredLevel: 6, incomeMultiplier: 0.12, customerMultiplier: 0.0, offlineMultiplier: 0.0),
        .init(id: "queue_science", name: "Warteschlangen-Analyse", icon: "person.3.sequence.fill", description: "Besucher verlieren weniger Geduld.", cost: 22_000, requiredLevel: 9, incomeMultiplier: 0.04, customerMultiplier: 0.1, offlineMultiplier: 0.0),
        .init(id: "overnight_ops", name: "Nachtbetrieb", icon: "moon.zzz.fill", description: "Mehr Einkommen, wenn du offline bist.", cost: 65_000, requiredLevel: 12, incomeMultiplier: 0.02, customerMultiplier: 0.0, offlineMultiplier: 0.25),
        .init(id: "data_driven_films", name: "Filmtrend-Labor", icon: "brain.head.profile", description: "Bessere Filmauswahl fuer jeden Standort.", cost: 180_000, requiredLevel: 17, incomeMultiplier: 0.18, customerMultiplier: 0.12, offlineMultiplier: 0.05),
        .init(id: "franchise_ai", name: "Franchise-Automation", icon: "cpu.fill", description: "Das Imperium skaliert schneller.", cost: 550_000, requiredLevel: 24, incomeMultiplier: 0.28, customerMultiplier: 0.18, offlineMultiplier: 0.2)
    ]

    static let locations: [LocationDefinition] = [
        .init(id: "neighborhood", name: "Stadtteilkino", icon: "building.2.fill", unlockCost: 0, requiredLevel: 1, incomeMultiplier: 1.0, reputationReward: 0),
        .init(id: "downtown", name: "Innenstadt-Palast", icon: "building.columns.fill", unlockCost: 28_000, requiredLevel: 8, incomeMultiplier: 1.28, reputationReward: 8),
        .init(id: "mall", name: "Mall-Multiplex", icon: "cart.fill", unlockCost: 95_000, requiredLevel: 13, incomeMultiplier: 1.55, reputationReward: 18),
        .init(id: "airport", name: "Airport Cinema", icon: "airplane.departure", unlockCost: 340_000, requiredLevel: 19, incomeMultiplier: 1.95, reputationReward: 40),
        .init(id: "global", name: "Globales Premierenhaus", icon: "globe.europe.africa.fill", unlockCost: 1_200_000, requiredLevel: 27, incomeMultiplier: 2.6, reputationReward: 90)
    ]

    static let missions: [MissionDefinition] = [
        .init(id: "earn_500", title: "Erste Abendkasse", detail: "Verdiene insgesamt 500 Coins.", kind: .earnCoins, target: 500, rewardCoins: 250, rewardXP: 90),
        .init(id: "build_2_rooms", title: "Zweiter Saal", detail: "Besitze 2 Kinosaele.", kind: .buildRooms, target: 2, rewardCoins: 750, rewardXP: 160),
        .init(id: "sell_100", title: "Hundert Tickets", detail: "Verkaufe 100 Tickets.", kind: .sellTickets, target: 100, rewardCoins: 900, rewardXP: 220),
        .init(id: "level_5", title: "Lokaler Favorit", detail: "Erreiche Level 5.", kind: .reachLevel, target: 5, rewardCoins: 2_500, rewardXP: 320),
        .init(id: "first_blockbuster", title: "Blockbuster-Nacht", detail: "Schalte den ersten Blockbuster frei.", kind: .unlockFilm, target: 1, rewardCoins: 15_000, rewardXP: 800),
        .init(id: "happy_90", title: "Standing Ovations", detail: "Erreiche 90% Kundenzufriedenheit.", kind: .satisfaction, target: 90, rewardCoins: 20_000, rewardXP: 900),
        .init(id: "rep_100", title: "Imperiums-Ruf", detail: "Erreiche 100 Ruf.", kind: .reputation, target: 100, rewardCoins: 80_000, rewardXP: 1_700)
    ]

    static let achievements: [AchievementDefinition] = [
        .init(id: "ach_first_hire", title: "Teamstart", detail: "Stelle deinen ersten Mitarbeiter ein.", kind: .sellTickets, target: 1, rewardReputation: 1),
        .init(id: "ach_1k_tickets", title: "Volles Haus", detail: "Verkaufe 1.000 Tickets.", kind: .sellTickets, target: 1_000, rewardReputation: 8),
        .init(id: "ach_level_10", title: "Stadtgespraech", detail: "Erreiche Level 10.", kind: .reachLevel, target: 10, rewardReputation: 12),
        .init(id: "ach_500k", title: "Kassenmagnet", detail: "Verdiene 500.000 Coins insgesamt.", kind: .earnCoins, target: 500_000, rewardReputation: 25),
        .init(id: "ach_satisfaction", title: "Publikumsliebling", detail: "Halte 95% Zufriedenheit.", kind: .satisfaction, target: 95, rewardReputation: 18)
    ]
}

