import SwiftUI

struct CinemaView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        ScreenShell(engine: engine, title: "Cinema Empire", subtitle: "Baue dein Kino vom ersten Saal zum Imperium aus.") {
            CinemaCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Aktueller Film")
                                .font(.caption)
                                .foregroundStyle(CinemaTheme.muted)
                            Text(engine.activeFilm.name)
                                .font(.title3.weight(.bold))
                        }
                        Spacer()
                        Image(systemName: engine.activeFilm.icon)
                            .font(.largeTitle)
                            .foregroundStyle(CinemaTheme.gold)
                    }

                    HStack {
                        Label("\(engine.formatShort(engine.incomePerSecond))/s", systemImage: "chart.line.uptrend.xyaxis")
                        Spacer()
                        Label("\(Int(engine.state.customerSatisfaction))%", systemImage: "face.smiling.fill")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CinemaTheme.muted)

                    ZStack(alignment: .top) {
                        PrimaryGameButton(title: "Tickets verkaufen", icon: "ticket.fill", disabled: false) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                engine.sellTickets()
                            }
                        }
                        VStack(spacing: 4) {
                            ForEach(engine.floatingCoins) { coin in
                                Text(coin.text)
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(CinemaTheme.gold)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .offset(y: -24)
                    }
                }
            }

            quickActions
            activeEvents

            Text("Gebaeude")
                .font(.headline)
            ForEach(GameCatalog.buildings) { building in
                BuildingRow(engine: engine, building: building)
            }
        }
    }

    private var quickActions: some View {
        CinemaCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Marketing & Events")
                    .font(.headline)
                HStack(spacing: 10) {
                    PrimaryGameButton(title: "Werbung", icon: "megaphone.fill", disabled: engine.state.coins < 600 * pow(1.42, Double(engine.state.level - 1))) {
                        engine.launchAdCampaign()
                    }
                    PrimaryGameButton(title: "Event", icon: "sparkles", disabled: engine.state.coins < 1_400 * pow(1.5, Double(engine.state.level - 1))) {
                        engine.hostEvent()
                    }
                }
            }
        }
    }

    private var activeEvents: some View {
        Group {
            if !engine.state.activeEvents.isEmpty {
                CinemaCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Laufende Events")
                            .font(.headline)
                        ForEach(engine.state.activeEvents) { event in
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(CinemaTheme.gold)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title)
                                        .font(.subheadline.weight(.bold))
                                    Text(event.detail)
                                        .font(.caption)
                                        .foregroundStyle(CinemaTheme.muted)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct BuildingRow: View {
    @ObservedObject var engine: GameEngine
    let building: BuildingDefinition

    var body: some View {
        let count = engine.state.buildings[building.id, default: 0]
        let level = engine.state.buildingLevels[building.id, default: 1]
        let buyCost = engine.buildingCost(building)
        let upgradeCost = engine.buildingUpgradeCost(building)
        let locked = engine.state.level < building.unlockLevel

        CinemaCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: building.icon)
                        .font(.title2)
                        .frame(width: 34, height: 34)
                        .foregroundStyle(locked ? Color.white.opacity(0.35) : CinemaTheme.gold)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(building.name)
                                .font(.headline)
                            Spacer()
                            Text("x\(count)")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(CinemaTheme.panelLight, in: Capsule())
                        }
                        Text(locked ? "Freischaltung mit Level \(building.unlockLevel)" : building.description)
                            .font(.caption)
                            .foregroundStyle(CinemaTheme.muted)
                        Text("Level \(level) · +\(engine.formatShort(building.incomePerSecond * pow(1.18, Double(level - 1))))/s je Gebaeude")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CinemaTheme.gold)
                    }
                }

                HStack(spacing: 10) {
                    PrimaryGameButton(title: engine.formatShort(buyCost), icon: "plus.circle.fill", disabled: locked || engine.state.coins < buyCost) {
                        engine.buyBuilding(building)
                    }
                    PrimaryGameButton(title: engine.formatShort(upgradeCost), icon: "arrow.up.circle.fill", disabled: count == 0 || engine.state.coins < upgradeCost) {
                        engine.upgradeBuilding(building)
                    }
                }
            }
        }
    }
}

