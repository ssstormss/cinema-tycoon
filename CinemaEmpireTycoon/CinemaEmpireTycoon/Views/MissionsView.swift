import SwiftUI

struct MissionsView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        ScreenShell(engine: engine, title: "Missionen", subtitle: "Ziele geben Tempo, Achievements geben Ruf.") {
            Text("Missionen")
                .font(.headline)
            ForEach(GameCatalog.missions) { mission in
                MissionRow(engine: engine, mission: mission)
            }

            Text("Achievements")
                .font(.headline)
                .padding(.top, 6)
            ForEach(GameCatalog.achievements) { achievement in
                AchievementRow(engine: engine, achievement: achievement)
            }
        }
    }
}

struct MissionRow: View {
    @ObservedObject var engine: GameEngine
    let mission: MissionDefinition

    var body: some View {
        let progress = engine.missionProgress(mission)
        let complete = progress >= mission.target
        let claimed = engine.state.completedMissions.contains(mission.id)

        CinemaCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(mission.title)
                    .font(.headline)
                Text(mission.detail)
                    .font(.caption)
                    .foregroundStyle(CinemaTheme.muted)
                ProgressLine(title: "Fortschritt", value: progress, target: mission.target, tint: complete ? CinemaTheme.green : CinemaTheme.gold)
                PrimaryGameButton(title: claimed ? "Abgeschlossen" : "Belohnung \(engine.formatShort(mission.rewardCoins))", icon: "gift.fill", disabled: !complete || claimed) {
                    engine.claimMission(mission)
                }
            }
        }
    }
}

struct AchievementRow: View {
    @ObservedObject var engine: GameEngine
    let achievement: AchievementDefinition

    var body: some View {
        let progress = engine.achievementProgress(achievement)
        let unlocked = engine.state.achievements.contains(achievement.id)

        CinemaCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: unlocked ? "trophy.fill" : "trophy")
                        .foregroundStyle(unlocked ? CinemaTheme.gold : CinemaTheme.muted)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(achievement.title)
                            .font(.headline)
                        Text(achievement.detail)
                            .font(.caption)
                            .foregroundStyle(CinemaTheme.muted)
                    }
                    Spacer()
                    Text("+\(Int(achievement.rewardReputation)) Ruf")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CinemaTheme.red)
                }
                ProgressView(value: min(progress / achievement.target, 1))
                    .tint(unlocked ? CinemaTheme.gold : CinemaTheme.red)
            }
        }
    }
}

