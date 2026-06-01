import SwiftUI

@main
struct CinemaEmpireTycoonApp: App {
    @StateObject private var engine = GameEngine()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView(engine: engine)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background || phase == .inactive {
                        engine.save()
                    }
                }
        }
    }
}

