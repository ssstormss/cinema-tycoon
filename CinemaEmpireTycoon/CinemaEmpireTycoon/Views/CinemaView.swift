import SwiftUI
import simd

struct CinemaView: View {
    @ObservedObject var engine: GameEngine
    @State private var playerPosition = SIMD2<Float>(0, -1.2)
    @State private var movement = SIMD2<Float>.zero
    @State private var nearbyStation: CinemaStation?
    private let movementTimer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            CinemaTheme.background.ignoresSafeArea()

            Cinema3DSceneView(playerPosition: $playerPosition, nearbyStation: $nearbyStation)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topHud
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                Spacer()
                HStack(alignment: .bottom) {
                    JoystickPad(velocity: $movement)
                    Spacer()
                    interactionPanel
                }
                .padding(14)
                .padding(.bottom, 54)
            }
        }
        .onReceive(movementTimer) { _ in
            updateMovement()
        }
    }

    private var topHud: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Cinema Empire Tycoon")
                        .font(.headline.weight(.black))
                    Text("Laufe zu Stationen und upgrade dein Kino")
                        .font(.caption)
                        .foregroundStyle(CinemaTheme.muted)
                }
                Spacer()
                Image(systemName: engine.activeFilm.icon)
                    .font(.title2)
                    .foregroundStyle(CinemaTheme.gold)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                MetricPill(icon: "bitcoinsign.circle.fill", title: "Coins", value: engine.formatShort(engine.state.coins), tint: CinemaTheme.gold)
                MetricPill(icon: "chart.line.uptrend.xyaxis", title: "Pro Sek.", value: engine.formatShort(engine.incomePerSecond), tint: CinemaTheme.green)
                MetricPill(icon: "star.fill", title: "Level", value: "\(engine.state.level)", tint: .orange)
                MetricPill(icon: "face.smiling.fill", title: "Zufrieden", value: "\(Int(engine.state.customerSatisfaction))%", tint: .cyan)
            }
            ProgressView(value: engine.state.xp, total: engine.xpForNextLevel)
                .tint(CinemaTheme.gold)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12), lineWidth: 1))
    }

    private var interactionPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let station = nearbyStation {
                HStack(spacing: 8) {
                    Image(systemName: station.icon)
                        .foregroundStyle(CinemaTheme.gold)
                    Text(station.title)
                        .font(.headline)
                }
                Text(station.detail(engine: engine))
                    .font(.caption)
                    .foregroundStyle(CinemaTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                PrimaryGameButton(title: "Interagieren", icon: "hand.tap.fill", disabled: false) {
                    station.perform(engine: engine)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(CinemaTheme.gold)
                    Text("Suche Station")
                        .font(.headline)
                }
                Text("Laufe mit dem Joystick zu Kasse, Snacks, Saelen oder VIP-Bereich.")
                    .font(.caption)
                    .foregroundStyle(CinemaTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(width: 210)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12), lineWidth: 1))
    }

    private func updateMovement() {
        guard movement.x != 0 || movement.y != 0 else {
            nearbyStation = closestStation()
            return
        }

        let speed: Float = 0.11
        playerPosition.x = min(5.0, max(-5.0, playerPosition.x + movement.x * speed))
        playerPosition.y = min(4.0, max(-4.0, playerPosition.y + movement.y * speed))
        nearbyStation = closestStation()
    }

    private func closestStation() -> CinemaStation? {
        CinemaStation.allCases
            .map { station -> (CinemaStation, Float) in
                let delta = playerPosition - station.position
                return (station, simd_length(delta))
            }
            .filter { $0.1 < 1.15 }
            .min { $0.1 < $1.1 }?
            .0
    }
}

struct BuildingsManagementView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        ScreenShell(engine: engine, title: "Kino-Management", subtitle: "Detailansicht fuer alle Gebaeude und Saal-Level.") {
            ForEach(GameCatalog.buildings) { building in
                BuildingRow(engine: engine, building: building)
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
