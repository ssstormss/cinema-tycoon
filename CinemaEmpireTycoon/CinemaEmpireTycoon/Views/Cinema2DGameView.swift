import SwiftUI
import SpriteKit

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
            return "Tickets verkaufen. Wert: +\(engine.formatShort(engine.ticketTapValue)) pro Kundengruppe."
        case .screen:
            return "Baue oder verbessere den naechsten bezahlbaren Kinosaal."
        case .snack:
            return "Erweitere Popcorn, Getraenke und Snack-Umsatz."
        case .staff:
            return "Stelle den naechsten bezahlbaren Mitarbeiter ein."
        case .marketing:
            return "Starte Werbung fuer mehr Kunden und Ruf."
        case .film:
            return "Schalte den naechsten Film frei oder waehle den staerksten Film."
        case .vip:
            return "Starte ein VIP-Event mit kurzer Umsatzspitze."
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

struct Cinema2DGameView: UIViewRepresentable {
    @Binding var playerPosition: SIMD2<Float>
    @Binding var nearbyStation: CinemaStation?
    let coins: Double
    let level: Int
    let satisfaction: Double

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.backgroundColor = UIColor(red: 0.055, green: 0.045, blue: 0.065, alpha: 1)
        view.ignoresSiblingOrder = true
        view.allowsTransparency = false
        let scene = Cinema2DScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        context.coordinator.scene = scene
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        context.coordinator.scene?.updateGame(
            playerPosition: playerPosition,
            nearbyStation: nearbyStation,
            coins: coins,
            level: level,
            satisfaction: satisfaction
        )
    }

    final class Coordinator {
        var scene: Cinema2DScene?
    }
}

final class Cinema2DScene: SKScene {
    private let world = SKNode()
    private let player = SKShapeNode(circleOfRadius: 18)
    private let playerShadow = SKShapeNode(ellipseOf: CGSize(width: 42, height: 14))
    private let customerLayer = SKNode()
    private let stationLayer = SKNode()
    private let hudGlow = SKShapeNode(rectOf: CGSize(width: 220, height: 48), cornerRadius: 8)
    private let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var stationNodes: [CinemaStation: SKNode] = [:]
    private var lastCustomerSpawn = TimeInterval.zero

    override func didMove(to view: SKView) {
        removeAllChildren()
        backgroundColor = UIColor(red: 0.055, green: 0.045, blue: 0.065, alpha: 1)
        addChild(world)
        world.addChild(customerLayer)
        world.addChild(stationLayer)
        buildLobby()
        buildStations()
        buildPlayer()
        buildStatusRibbon()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        world.position = CGPoint(x: size.width / 2, y: size.height / 2 - 8)
        hudGlow.position = CGPoint(x: size.width / 2, y: size.height - 152)
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height - 160)
    }

    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastCustomerSpawn > 1.6 {
            lastCustomerSpawn = currentTime
            spawnCustomer()
        }
    }

    func updateGame(playerPosition: SIMD2<Float>, nearbyStation: CinemaStation?, coins: Double, level: Int, satisfaction: Double) {
        player.position = map(playerPosition)
        playerShadow.position = CGPoint(x: player.position.x, y: player.position.y - 18)
        statusLabel.text = "Level \(level)   Coins \(short(coins))   Stimmung \(Int(satisfaction))%"

        for station in CinemaStation.allCases {
            let selected = station == nearbyStation
            let node = stationNodes[station]
            node?.setScale(selected ? 1.08 : 1.0)
            node?.alpha = selected ? 1.0 : 0.82
            if selected {
                node?.run(.sequence([.scale(to: 1.12, duration: 0.18), .scale(to: 1.08, duration: 0.18)]), withKey: "pulse")
            }
        }
    }

    private func buildLobby() {
        let floor = SKShapeNode(rectOf: CGSize(width: 690, height: 850), cornerRadius: 22)
        floor.fillColor = UIColor(red: 0.12, green: 0.09, blue: 0.12, alpha: 1)
        floor.strokeColor = UIColor.white.withAlphaComponent(0.10)
        floor.lineWidth = 2
        floor.zPosition = 0
        world.addChild(floor)

        let carpet = SKShapeNode(rectOf: CGSize(width: 190, height: 780), cornerRadius: 18)
        carpet.fillColor = UIColor(red: 0.50, green: 0.04, blue: 0.08, alpha: 1)
        carpet.strokeColor = UIColor(red: 1.0, green: 0.72, blue: 0.23, alpha: 0.28)
        carpet.lineWidth = 2
        carpet.zPosition = 1
        world.addChild(carpet)

        let screen = SKShapeNode(rectOf: CGSize(width: 380, height: 78), cornerRadius: 10)
        screen.fillColor = UIColor(red: 0.83, green: 0.80, blue: 0.70, alpha: 1)
        screen.strokeColor = UIColor(red: 1.0, green: 0.72, blue: 0.23, alpha: 1)
        screen.lineWidth = 3
        screen.position = CGPoint(x: 0, y: 330)
        screen.zPosition = 3
        world.addChild(screen)

        let screenLabel = label("PREMIERE", size: 18, color: UIColor.black.withAlphaComponent(0.75))
        screenLabel.position = CGPoint(x: 0, y: 323)
        screenLabel.zPosition = 4
        world.addChild(screenLabel)

        for row in 0..<4 {
            for col in 0..<6 {
                let seat = SKShapeNode(rectOf: CGSize(width: 44, height: 34), cornerRadius: 8)
                seat.fillColor = UIColor(red: 0.43, green: 0.03, blue: 0.06, alpha: 1)
                seat.strokeColor = UIColor.white.withAlphaComponent(0.08)
                seat.lineWidth = 1
                seat.position = CGPoint(x: CGFloat(col - 3) * 54 + 27, y: 136 - CGFloat(row) * 48)
                seat.zPosition = 2
                world.addChild(seat)
            }
        }

        addDecorCounter(title: "TICKETS", at: CGPoint(x: -238, y: -275), color: UIColor(red: 0.95, green: 0.62, blue: 0.12, alpha: 1))
        addDecorCounter(title: "SNACKS", at: CGPoint(x: 238, y: -275), color: UIColor(red: 0.82, green: 0.15, blue: 0.12, alpha: 1))
        addDecorCounter(title: "OFFICE", at: CGPoint(x: -250, y: 58), color: UIColor(red: 0.18, green: 0.45, blue: 0.72, alpha: 1))
        addDecorCounter(title: "ADS", at: CGPoint(x: 250, y: 58), color: UIColor(red: 0.54, green: 0.25, blue: 0.86, alpha: 1))
    }

    private func buildStations() {
        for station in CinemaStation.allCases {
            let node = SKNode()
            node.position = map(station.position)
            node.zPosition = 8

            let pad = SKShapeNode(circleOfRadius: 38)
            pad.fillColor = station.color.withAlphaComponent(0.28)
            pad.strokeColor = station.color
            pad.lineWidth = 3
            pad.zPosition = 0
            node.addChild(pad)

            let tile = SKShapeNode(rectOf: CGSize(width: 82, height: 58), cornerRadius: 10)
            tile.fillColor = station.color.withAlphaComponent(0.92)
            tile.strokeColor = UIColor.white.withAlphaComponent(0.25)
            tile.lineWidth = 2
            tile.zPosition = 1
            node.addChild(tile)

            let icon = label(stationGlyph(station), size: 24, color: .white)
            icon.position = CGPoint(x: 0, y: 6)
            icon.zPosition = 2
            node.addChild(icon)

            let title = label(station.title.uppercased(), size: 10, color: .white)
            title.position = CGPoint(x: 0, y: -19)
            title.zPosition = 2
            node.addChild(title)

            stationNodes[station] = node
            stationLayer.addChild(node)
        }
    }

    private func buildPlayer() {
        playerShadow.fillColor = UIColor.black.withAlphaComponent(0.28)
        playerShadow.strokeColor = .clear
        playerShadow.zPosition = 19
        world.addChild(playerShadow)

        player.fillColor = UIColor(red: 1.0, green: 0.72, blue: 0.23, alpha: 1)
        player.strokeColor = UIColor.black.withAlphaComponent(0.35)
        player.lineWidth = 3
        player.zPosition = 20
        world.addChild(player)

        let suit = SKShapeNode(rectOf: CGSize(width: 22, height: 16), cornerRadius: 5)
        suit.fillColor = UIColor(red: 0.10, green: 0.08, blue: 0.11, alpha: 1)
        suit.strokeColor = .clear
        suit.position = CGPoint(x: 0, y: -9)
        suit.zPosition = 21
        player.addChild(suit)
    }

    private func buildStatusRibbon() {
        hudGlow.fillColor = UIColor.black.withAlphaComponent(0.28)
        hudGlow.strokeColor = UIColor(red: 1.0, green: 0.72, blue: 0.23, alpha: 0.35)
        hudGlow.lineWidth = 1
        hudGlow.zPosition = 100
        addChild(hudGlow)

        statusLabel.fontSize = 13
        statusLabel.fontColor = UIColor(red: 1.0, green: 0.89, blue: 0.58, alpha: 1)
        statusLabel.zPosition = 101
        addChild(statusLabel)
    }

    private func addDecorCounter(title: String, at point: CGPoint, color: UIColor) {
        let counter = SKShapeNode(rectOf: CGSize(width: 150, height: 72), cornerRadius: 12)
        counter.fillColor = color.withAlphaComponent(0.72)
        counter.strokeColor = UIColor.white.withAlphaComponent(0.14)
        counter.lineWidth = 2
        counter.position = point
        counter.zPosition = 2
        world.addChild(counter)

        let text = label(title, size: 13, color: .white)
        text.position = CGPoint(x: point.x, y: point.y - 5)
        text.zPosition = 3
        world.addChild(text)
    }

    private func spawnCustomer() {
        guard customerLayer.children.count < 12 else { return }
        let customer = SKShapeNode(circleOfRadius: CGFloat.random(in: 7...11))
        customer.fillColor = [
            UIColor(red: 0.25, green: 0.72, blue: 1.0, alpha: 1),
            UIColor(red: 0.96, green: 0.35, blue: 0.25, alpha: 1),
            UIColor(red: 0.35, green: 0.86, blue: 0.56, alpha: 1),
            UIColor(red: 0.72, green: 0.48, blue: 1.0, alpha: 1)
        ].randomElement() ?? .cyan
        customer.strokeColor = UIColor.white.withAlphaComponent(0.18)
        customer.lineWidth = 1
        customer.position = CGPoint(x: CGFloat.random(in: -280...280), y: -405)
        customer.zPosition = 14
        customerLayer.addChild(customer)

        let target = CGPoint(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: 65...170))
        let wait = SKAction.wait(forDuration: TimeInterval.random(in: 0.3...1.4))
        let enter = SKAction.move(to: target, duration: TimeInterval.random(in: 2.0...3.4))
        enter.timingMode = .easeInEaseOut
        let leave = SKAction.move(to: CGPoint(x: CGFloat.random(in: -280...280), y: -430), duration: TimeInterval.random(in: 2.2...3.8))
        leave.timingMode = .easeInEaseOut
        customer.run(.sequence([enter, wait, leave, .removeFromParent()]))
    }

    private func map(_ position: SIMD2<Float>) -> CGPoint {
        CGPoint(x: CGFloat(position.x) * 58, y: CGFloat(position.y) * 86)
    }

    private func stationGlyph(_ station: CinemaStation) -> String {
        switch station {
        case .ticket: return "$"
        case .screen: return "TV"
        case .snack: return "POP"
        case .staff: return "HR"
        case .marketing: return "AD"
        case .film: return "FILM"
        case .vip: return "VIP"
        case .location: return "MAP"
        }
    }

    private func label(_ text: String, size: CGFloat, color: UIColor) -> SKLabelNode {
        let node = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        node.text = text
        node.fontSize = size
        node.fontColor = color
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        return node
    }

    private func short(_ value: Double) -> String {
        let absValue = abs(value)
        if absValue >= 1_000_000_000 { return String(format: "%.1fB", value / 1_000_000_000) }
        if absValue >= 1_000_000 { return String(format: "%.1fM", value / 1_000_000) }
        if absValue >= 1_000 { return String(format: "%.1fK", value / 1_000) }
        return String(format: "%.0f", value)
    }
}

struct JoystickPad: View {
    @Binding var velocity: SIMD2<Float>

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.38))
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
