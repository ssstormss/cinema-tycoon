import SwiftUI

struct RootView: View {
    @ObservedObject var engine: GameEngine
    @State private var showOffline = false

    var body: some View {
        TabView {
            CinemaView(engine: engine)
                .tabItem { Label("Kino", systemImage: "popcorn.fill") }
            UpgradesView(engine: engine)
                .tabItem { Label("Upgrades", systemImage: "arrow.up.circle.fill") }
            FilmsView(engine: engine)
                .tabItem { Label("Filme", systemImage: "film.stack.fill") }
            StaffView(engine: engine)
                .tabItem { Label("Mitarbeiter", systemImage: "person.3.fill") }
            MissionsView(engine: engine)
                .tabItem { Label("Missionen", systemImage: "checklist") }
            StatsView(engine: engine)
                .tabItem { Label("Statistik", systemImage: "chart.bar.xaxis") }
        }
        .tint(CinemaTheme.gold)
        .background(CinemaTheme.background)
        .onAppear {
            showOffline = engine.offlineReward > 1
        }
        .alert("Offline-Einnahmen", isPresented: $showOffline) {
            Button("Einzahlen", role: .cancel) { }
        } message: {
            Text("Dein Kino hat waehrend deiner Pause \(engine.formatShort(engine.offlineReward)) Coins verdient.")
        }
        .alert("Event", isPresented: eventBinding) {
            Button("Weiter", role: .cancel) { engine.eventMessage = nil }
        } message: {
            Text(engine.eventMessage ?? "")
        }
    }

    private var eventBinding: Binding<Bool> {
        Binding(
            get: { engine.eventMessage != nil },
            set: { if !$0 { engine.eventMessage = nil } }
        )
    }
}

struct ScreenShell<Content: View>: View {
    @ObservedObject var engine: GameEngine
    let title: String
    let subtitle: String
    let content: Content

    init(engine: GameEngine, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.engine = engine
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CinemaTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HeaderView(engine: engine, title: title, subtitle: subtitle)
                        content
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HeaderView: View {
    @ObservedObject var engine: GameEngine
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.weight(.black))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(CinemaTheme.muted)
                }
                Spacer()
                Image(systemName: "ticket.fill")
                    .font(.title2)
                    .foregroundStyle(CinemaTheme.gold)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                MetricPill(icon: "bitcoinsign.circle.fill", title: "Coins", value: engine.formatShort(engine.state.coins), tint: CinemaTheme.gold)
                MetricPill(icon: "person.2.fill", title: "Kunden/min", value: engine.formatShort(engine.customersPerMinute), tint: .cyan)
                MetricPill(icon: "star.fill", title: "Level", value: "\(engine.state.level)", tint: .orange)
                MetricPill(icon: "heart.fill", title: "Ruf", value: engine.formatShort(engine.state.reputation), tint: CinemaTheme.red)
            }

            ProgressLine(title: "XP bis Level \(engine.state.level + 1)", value: engine.state.xp, target: engine.xpForNextLevel, tint: CinemaTheme.gold)
        }
    }
}

