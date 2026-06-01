import SwiftUI
import SceneKit

enum CinemaStation: String, CaseIterable, Identifiable {
    case ticket
    case screen
    case snack
    case staff
    case marketing
    case film
    case vip
    case location

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ticket: return "Kasse"
        case .screen: return "Kinosaele"
        case .snack: return "Snacks"
        case .staff: return "Personal"
        case .marketing: return "Werbung"
        case .film: return "Filmregal"
        case .vip: return "Event"
        case .location: return "Karte"
        }
    }

    var icon: String {
        switch self {
        case .ticket: return "ticket.fill"
        case .screen: return "sparkles.tv.fill"
        case .snack: return "popcorn.fill"
        case .staff: return "person.3.fill"
        case .marketing: return "megaphone.fill"
        case .film: return "film.stack.fill"
        case .vip: return "crown.fill"
        case .location: return "map.fill"
        }
    }

    var position: SIMD2<Float> {
        switch self {
        case .ticket: return SIMD2(-4.0, -2.5)
        case .screen: return SIMD2(0.0, 3.2)
        case .snack: return SIMD2(4.0, -2.4)
        case .staff: return SIMD2(-4.5, 1.2)
        case .marketing: return SIMD2(4.5, 1.2)
        case .film: return SIMD2(-1.8, -3.6)
        case .vip: return SIMD2(2.0, -3.6)
        case .location: return SIMD2(0.0, 0.2)
        }
    }

    var color: UIColor {
        switch self {
        case .ticket: return UIColor(red: 1.0, green: 0.72, blue: 0.23, alpha: 1)
        case .screen: return UIColor(red: 0.78, green: 0.12, blue: 0.18, alpha: 1)
        case .snack: return UIColor(red: 0.95, green: 0.45, blue: 0.16, alpha: 1)
        case .staff: return UIColor(red: 0.25, green: 0.65, blue: 1.0, alpha: 1)
        case .marketing: return UIColor(red: 0.7, green: 0.45, blue: 1.0, alpha: 1)
        case .film: return UIColor(red: 0.3, green: 0.85, blue: 0.58, alpha: 1)
        case .vip: return UIColor(red: 1.0, green: 0.86, blue: 0.32, alpha: 1)
        case .location: return UIColor(red: 0.2, green: 0.85, blue: 0.9, alpha: 1)
        }
    }

    func detail(engine: GameEngine) -> String {
        switch self {
        case .ticket:
            return "Verkaufe Tickets direkt. Wert: +\(engine.formatShort(engine.ticketTapValue)) pro Kundengruppe."
        case .screen:
            return "Baue oder verbessere den naechsten bezahlbaren Kinosaal."
        case .snack:
            return "Erweitere Popcorn, Getraenke und Snack-Umsatz."
        case .staff:
            return "Stelle den naechsten bezahlbaren Mitarbeiter ein."
        case .marketing:
            return "Starte Werbung fuer mehr Kunden und Ruf."
        case .film:
            return "Schalte den naechsten Film frei oder waehle den besten freigeschalteten Film."
        case .vip:
            return "Veranstalte ein VIP-Event mit kurzer Umsatzspitze."
        case .location:
            return "Schalte den naechsten Standort frei."
        }
    }

    func perform(engine: GameEngine) {
        switch self {
        case .ticket:
            engine.sellTickets()
        case .screen:
            let rooms = ["small_screen", "large_screen", "luxury_screen", "imax_screen", "four_d_screen"]
            if let owned = GameCatalog.buildings.first(where: { rooms.contains($0.id) && engine.state.buildings[$0.id, default: 0] > 0 && engine.state.coins >= engine.buildingUpgradeCost($0) }) {
                engine.upgradeBuilding(owned)
            } else if let next = GameCatalog.buildings.first(where: { rooms.contains($0.id) && engine.state.level >= $0.unlockLevel && engine.state.coins >= engine.buildingCost($0) }) {
                engine.buyBuilding(next)
            } else {
                engine.eventMessage = "Nicht genug Coins fuer den naechsten Saal"
            }
        case .snack:
            let snackIds = ["snack_bar", "drink_stand", "arcade", "merch"]
            if let next = GameCatalog.buildings.first(where: { snackIds.contains($0.id) && engine.state.level >= $0.unlockLevel && engine.state.coins >= engine.buildingCost($0) }) {
                engine.buyBuilding(next)
            } else {
                engine.eventMessage = "Noch kein Snack-Upgrade bezahlbar"
            }
        case .staff:
            if let next = GameCatalog.employees.first(where: { engine.state.level >= $0.unlockLevel && engine.state.coins >= engine.employeeCost($0) }) {
                engine.hire(next)
            } else {
                engine.eventMessage = "Kein Mitarbeiter bezahlbar"
            }
        case .marketing:
            engine.launchAdCampaign()
        case .film:
            if let next = GameCatalog.films.first(where: { !engine.state.unlockedFilms.contains($0.id) && engine.state.level >= $0.unlockLevel && engine.state.coins >= $0.unlockCost }) {
                engine.unlockFilm(next)
            } else if let best = GameCatalog.films.filter({ engine.state.unlockedFilms.contains($0.id) }).max(by: { $0.revenueBonus < $1.revenueBonus }) {
                engine.selectFilm(best)
                engine.eventMessage = "\(best.name) laeuft jetzt"
            }
        case .vip:
            engine.hostEvent()
        case .location:
            if let next = GameCatalog.locations.first(where: { !engine.state.unlockedLocations.contains($0.id) && engine.state.level >= $0.requiredLevel && engine.state.coins >= $0.unlockCost }) {
                engine.unlockLocation(next)
            } else {
                engine.eventMessage = "Kein Standort bereit"
            }
        }
    }
}

struct Cinema3DSceneView: UIViewRepresentable {
    @Binding var playerPosition: SIMD2<Float>
    @Binding var nearbyStation: CinemaStation?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = context.coordinator.scene
        view.backgroundColor = UIColor(red: 0.055, green: 0.045, blue: 0.065, alpha: 1)
        view.allowsCameraControl = false
        view.isPlaying = true
        context.coordinator.buildScene()
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.update(playerPosition: playerPosition, nearbyStation: nearbyStation)
    }

    final class Coordinator {
        let scene = SCNScene()
        private let playerNode = SCNNode()
        private let cameraNode = SCNNode()
        private var stationNodes: [CinemaStation: SCNNode] = [:]

        func buildScene() {
            scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
            scene.background.contents = UIColor(red: 0.055, green: 0.045, blue: 0.065, alpha: 1)

            let ambient = SCNLight()
            ambient.type = .ambient
            ambient.intensity = 650
            let ambientNode = SCNNode()
            ambientNode.light = ambient
            scene.rootNode.addChildNode(ambientNode)

            let light = SCNLight()
            light.type = .omni
            light.intensity = 950
            let lightNode = SCNNode()
            lightNode.light = light
            lightNode.position = SCNVector3(0, 8, 2)
            scene.rootNode.addChildNode(lightNode)

            cameraNode.camera = SCNCamera()
            cameraNode.camera?.usesOrthographicProjection = true
            cameraNode.camera?.orthographicScale = 10
            cameraNode.position = SCNVector3(0, 8.5, 7.5)
            cameraNode.eulerAngles = SCNVector3(-Float.pi / 3.0, 0, 0)
            scene.rootNode.addChildNode(cameraNode)
            scene.rootNode.camera = cameraNode.camera

            addBox(name: "floor", size: SCNVector3(11, 0.12, 9), position: SCNVector3(0, -0.06, 0), color: UIColor(red: 0.13, green: 0.10, blue: 0.12, alpha: 1))
            addBox(name: "carpet", size: SCNVector3(2.0, 0.05, 8.0), position: SCNVector3(0, 0.03, -0.2), color: UIColor(red: 0.55, green: 0.04, blue: 0.08, alpha: 1))
            addWalls()
            addSeats()
            addCounters()
            addStations()
            addPlayer()
        }

        func update(playerPosition: SIMD2<Float>, nearbyStation: CinemaStation?) {
            let clampedX = min(5.0, max(-5.0, playerPosition.x))
            let clampedZ = min(4.0, max(-4.0, playerPosition.y))
            playerNode.position = SCNVector3(clampedX, 0.42, clampedZ)
            cameraNode.position.x = clampedX * 0.18
            cameraNode.position.z = 7.5 + clampedZ * 0.12

            for station in CinemaStation.allCases {
                let selected = station == nearbyStation
                stationNodes[station]?.scale = selected ? SCNVector3(1.22, 1.22, 1.22) : SCNVector3(1, 1, 1)
                stationNodes[station]?.opacity = selected ? 1.0 : 0.72
            }
        }

        private func addPlayer() {
            let body = SCNCapsule(capRadius: 0.22, height: 0.85)
            body.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.72, blue: 0.23, alpha: 1)
            playerNode.geometry = body
            playerNode.position = SCNVector3(0, 0.42, -1.2)
            playerNode.name = "Manager"
            scene.rootNode.addChildNode(playerNode)
        }

        private func addStations() {
            for station in CinemaStation.allCases {
                let base = SCNNode()
                base.position = SCNVector3(station.position.x, 0.2, station.position.y)

                let pad = SCNCylinder(radius: 0.52, height: 0.12)
                pad.firstMaterial?.diffuse.contents = station.color
                let padNode = SCNNode(geometry: pad)
                padNode.position = SCNVector3(0, 0, 0)
                base.addChildNode(padNode)

                let pillar = SCNBox(width: 0.56, height: 0.72, length: 0.56, chamferRadius: 0.07)
                pillar.firstMaterial?.diffuse.contents = station.color.withAlphaComponent(0.88)
                let pillarNode = SCNNode(geometry: pillar)
                pillarNode.position = SCNVector3(0, 0.42, 0)
                base.addChildNode(pillarNode)

                let label = SCNText(string: station.title, extrusionDepth: 0.01)
                label.font = UIFont.boldSystemFont(ofSize: 0.22)
                label.firstMaterial?.diffuse.contents = UIColor.white
                let labelNode = SCNNode(geometry: label)
                labelNode.scale = SCNVector3(0.9, 0.9, 0.9)
                labelNode.position = SCNVector3(-0.48, 0.95, -0.18)
                labelNode.eulerAngles = SCNVector3(-Float.pi / 2.8, 0, 0)
                base.addChildNode(labelNode)

                stationNodes[station] = base
                scene.rootNode.addChildNode(base)
            }
        }

        private func addSeats() {
            for row in 0..<3 {
                for col in 0..<5 {
                    let x = Float(col) * 0.65 - 1.3
                    let z = Float(row) * 0.45 + 1.55
                    addBox(name: "seat", size: SCNVector3(0.42, 0.22, 0.32), position: SCNVector3(x, 0.17, z), color: UIColor(red: 0.42, green: 0.03, blue: 0.06, alpha: 1))
                }
            }
            addBox(name: "screen", size: SCNVector3(3.8, 1.25, 0.12), position: SCNVector3(0, 0.9, 4.05), color: UIColor(red: 0.82, green: 0.80, blue: 0.72, alpha: 1))
        }

        private func addCounters() {
            addBox(name: "ticketCounter", size: SCNVector3(1.45, 0.55, 0.45), position: SCNVector3(-4, 0.28, -3.1), color: UIColor(red: 0.36, green: 0.16, blue: 0.07, alpha: 1))
            addBox(name: "snackCounter", size: SCNVector3(1.45, 0.55, 0.45), position: SCNVector3(4, 0.28, -3.1), color: UIColor(red: 0.40, green: 0.09, blue: 0.08, alpha: 1))
            addBox(name: "officeDesk", size: SCNVector3(1.25, 0.45, 0.45), position: SCNVector3(-4.5, 0.23, 1.85), color: UIColor(red: 0.12, green: 0.25, blue: 0.33, alpha: 1))
            addBox(name: "billboard", size: SCNVector3(1.2, 0.9, 0.15), position: SCNVector3(4.5, 0.62, 1.85), color: UIColor(red: 0.33, green: 0.12, blue: 0.45, alpha: 1))
        }

        private func addWalls() {
            addBox(name: "backWall", size: SCNVector3(11, 1.2, 0.18), position: SCNVector3(0, 0.6, 4.5), color: UIColor(red: 0.08, green: 0.06, blue: 0.08, alpha: 1))
            addBox(name: "leftWall", size: SCNVector3(0.18, 1.0, 9), position: SCNVector3(-5.55, 0.5, 0), color: UIColor(red: 0.08, green: 0.06, blue: 0.08, alpha: 1))
            addBox(name: "rightWall", size: SCNVector3(0.18, 1.0, 9), position: SCNVector3(5.55, 0.5, 0), color: UIColor(red: 0.08, green: 0.06, blue: 0.08, alpha: 1))
        }

        @discardableResult
        private func addBox(name: String, size: SCNVector3, position: SCNVector3, color: UIColor) -> SCNNode {
            let geometry = SCNBox(width: CGFloat(size.x), height: CGFloat(size.y), length: CGFloat(size.z), chamferRadius: 0.02)
            geometry.firstMaterial?.diffuse.contents = color
            let node = SCNNode(geometry: geometry)
            node.name = name
            node.position = position
            scene.rootNode.addChildNode(node)
            return node
        }
    }
}

struct JoystickPad: View {
    @Binding var velocity: SIMD2<Float>

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.36))
                .frame(width: 118, height: 118)
                .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
            Circle()
                .fill(CinemaTheme.gold)
                .frame(width: 46, height: 46)
                .offset(x: CGFloat(velocity.x) * 34, y: CGFloat(velocity.y) * 34)
                .shadow(color: CinemaTheme.gold.opacity(0.55), radius: 12)
            Image(systemName: "figure.walk")
                .foregroundStyle(.black)
                .font(.headline)
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let dx = Float(value.translation.width / 42)
                    let dy = Float(value.translation.height / 42)
                    velocity = SIMD2(min(1, max(-1, dx)), min(1, max(-1, dy)))
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.78)) {
                        velocity = .zero
                    }
                }
        )
    }
}

