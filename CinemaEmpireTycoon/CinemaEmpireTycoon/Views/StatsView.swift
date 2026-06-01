import SwiftUI

struct StatsView: View {
    @ObservedObject var engine: GameEngine
    @State private var showReset = false

    var body: some View {
        ScreenShell(engine: engine, title: "Statistik", subtitle: "Imperiumsueberblick, Standorte und Prestige.") {
            CinemaCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Kennzahlen")
                        .font(.headline)
                    stat("Einkommen pro Sekunde", engine.formatShort(engine.incomePerSecond), "bitcoinsign.circle.fill")
                    stat("Tickets verkauft", "\(engine.state.ticketsSold)", "ticket.fill")
                    stat("Snack-Verkaeufe", "\(engine.state.snackbarSales)", "popcorn.fill")
                    stat("VIP-Kunden", "\(engine.state.vipCustomers)", "crown.fill")
                    stat("Offline-Multiplikator", "\(Int(engine.offlineMultiplier * 100))%", "moon.zzz.fill")
                    stat("Prestige-Punkte", "\(engine.state.prestigePoints)", "star.circle.fill")
                }
            }

            Text("Standorte")
                .font(.headline)
            ForEach(GameCatalog.locations) { location in
                LocationRow(engine: engine, location: location)
            }

            CinemaCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Prestige")
                        .font(.headline)
                    Text("Ab Level 25 und 1M Lifetime-Coins startest du neu und bekommst Sternenpunkte. Jeder Punkt gibt dauerhaft +8% Einkommen.")
                        .font(.caption)
                        .foregroundStyle(CinemaTheme.muted)
                    PrimaryGameButton(title: engine.canPrestige ? "Prestige starten" : "Prestige gesperrt", icon: "star.circle.fill", disabled: !engine.canPrestige) {
                        engine.prestige()
                    }
                }
            }

            Button(role: .destructive) {
                showReset = true
            } label: {
                Label("Spielstand zuruecksetzen", systemImage: "trash.fill")
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(CinemaTheme.red.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
            .alert("Spielstand loeschen?", isPresented: $showReset) {
                Button("Abbrechen", role: .cancel) { }
                Button("Loeschen", role: .destructive) { engine.resetGame() }
            } message: {
                Text("Dieser lokale Spielstand wird entfernt.")
            }
        }
    }

    private func stat(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundStyle(CinemaTheme.muted)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundStyle(CinemaTheme.gold)
        }
        .font(.subheadline)
    }
}

struct LocationRow: View {
    @ObservedObject var engine: GameEngine
    let location: LocationDefinition

    var body: some View {
        let unlocked = engine.state.unlockedLocations.contains(location.id)
        let locked = engine.state.level < location.requiredLevel

        CinemaCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: location.icon)
                        .font(.title2)
                        .frame(width: 34, height: 34)
                        .foregroundStyle(unlocked ? CinemaTheme.green : CinemaTheme.gold)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.headline)
                        Text("Einkommen \(String(format: "%.2fx", location.incomeMultiplier)) · Ruf +\(Int(location.reputationReward))")
                            .font(.caption)
                            .foregroundStyle(CinemaTheme.muted)
                    }
                }
                PrimaryGameButton(title: unlocked ? "Freigeschaltet" : locked ? "Level \(location.requiredLevel)" : "Kaufen \(engine.formatShort(location.unlockCost))", icon: "building.2.crop.circle.fill", disabled: unlocked || locked || engine.state.coins < location.unlockCost) {
                    engine.unlockLocation(location)
                }
            }
        }
    }
}

