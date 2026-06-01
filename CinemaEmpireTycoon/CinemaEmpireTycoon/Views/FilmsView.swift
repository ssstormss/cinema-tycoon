import SwiftUI

struct FilmsView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        ScreenShell(engine: engine, title: "Filme", subtitle: "Schalte Genres frei und waehle den besten Film fuer dein Publikum.") {
            ForEach(GameCatalog.films) { film in
                FilmRow(engine: engine, film: film)
            }
        }
    }
}

struct FilmRow: View {
    @ObservedObject var engine: GameEngine
    let film: FilmDefinition

    var body: some View {
        let unlocked = engine.state.unlockedFilms.contains(film.id)
        let selected = engine.state.activeFilmId == film.id
        let lockedByLevel = engine.state.level < film.unlockLevel

        CinemaCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: film.icon)
                        .font(.title2)
                        .frame(width: 34, height: 34)
                        .foregroundStyle(selected ? CinemaTheme.green : CinemaTheme.gold)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(film.name)
                                .font(.headline)
                            Spacer()
                            Text(film.audience.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(CinemaTheme.muted)
                        }
                        Text("Beliebtheit \(String(format: "%.2fx", film.popularity)) · Laufzeit \(film.runtimeMinutes) Min · Umsatz \(String(format: "%.2fx", film.revenueBonus))")
                            .font(.caption)
                            .foregroundStyle(CinemaTheme.muted)
                    }
                }

                if unlocked {
                    PrimaryGameButton(title: selected ? "Laeuft gerade" : "Auswaehlen", icon: selected ? "checkmark.circle.fill" : "play.circle.fill", disabled: selected) {
                        engine.selectFilm(film)
                    }
                } else {
                    PrimaryGameButton(title: lockedByLevel ? "Level \(film.unlockLevel)" : "Freischalten \(engine.formatShort(film.unlockCost))", icon: "lock.open.fill", disabled: lockedByLevel || engine.state.coins < film.unlockCost) {
                        engine.unlockFilm(film)
                    }
                }
            }
        }
    }
}

