import SwiftUI

struct UpgradesView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        ScreenShell(engine: engine, title: "Upgrades", subtitle: "Verbessere Technik, Komfort und Forschung.") {
            Text("Kino-Upgrades")
                .font(.headline)
            ForEach(GameCatalog.upgrades) { upgrade in
                UpgradeRow(engine: engine, upgrade: upgrade)
            }

            Text("Forschung")
                .font(.headline)
                .padding(.top, 6)
            ForEach(GameCatalog.research) { research in
                ResearchRow(engine: engine, research: research)
            }
        }
    }
}

struct UpgradeRow: View {
    @ObservedObject var engine: GameEngine
    let upgrade: UpgradeDefinition

    var body: some View {
        let level = engine.state.upgrades[upgrade.id, default: 0]
        let cost = engine.upgradeCost(upgrade)
        let locked = engine.state.level < upgrade.unlockLevel
        let maxed = level >= upgrade.maxLevel

        CinemaCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: upgrade.icon)
                        .font(.title2)
                        .frame(width: 34, height: 34)
                        .foregroundStyle(CinemaTheme.gold)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(upgrade.name)
                                .font(.headline)
                            Spacer()
                            Text("\(level)/\(upgrade.maxLevel)")
                                .font(.caption.weight(.bold))
                        }
                        Text(locked ? "Freischaltung mit Level \(upgrade.unlockLevel)" : upgrade.description)
                            .font(.caption)
                            .foregroundStyle(CinemaTheme.muted)
                    }
                }
                ProgressView(value: Double(level), total: Double(upgrade.maxLevel))
                    .tint(CinemaTheme.red)
                PrimaryGameButton(title: maxed ? "Maximum" : "Kaufen \(engine.formatShort(cost))", icon: "arrow.up.circle.fill", disabled: locked || maxed || engine.state.coins < cost) {
                    engine.buyUpgrade(upgrade)
                }
            }
        }
    }
}

struct ResearchRow: View {
    @ObservedObject var engine: GameEngine
    let research: ResearchDefinition

    var body: some View {
        let done = engine.state.completedResearch.contains(research.id)
        let locked = engine.state.level < research.requiredLevel

        CinemaCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: research.icon)
                        .font(.title2)
                        .frame(width: 34, height: 34)
                        .foregroundStyle(done ? CinemaTheme.green : CinemaTheme.gold)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(research.name)
                            .font(.headline)
                        Text(locked ? "Freischaltung mit Level \(research.requiredLevel)" : research.description)
                            .font(.caption)
                            .foregroundStyle(CinemaTheme.muted)
                    }
                }
                PrimaryGameButton(title: done ? "Erforscht" : "Forschen \(engine.formatShort(research.cost))", icon: "lightbulb.fill", disabled: done || locked || engine.state.coins < research.cost) {
                    engine.completeResearch(research)
                }
            }
        }
    }
}

