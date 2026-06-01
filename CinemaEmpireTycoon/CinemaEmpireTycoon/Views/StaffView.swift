import SwiftUI

struct StaffView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        ScreenShell(engine: engine, title: "Mitarbeiter", subtitle: "Gute Teams machen dein Kino schneller, sauberer und profitabler.") {
            ForEach(GameCatalog.employees) { employee in
                EmployeeRow(engine: engine, employee: employee)
            }
        }
    }
}

struct EmployeeRow: View {
    @ObservedObject var engine: GameEngine
    let employee: EmployeeDefinition

    var body: some View {
        let count = engine.state.employees[employee.id, default: 0]
        let cost = engine.employeeCost(employee)
        let locked = engine.state.level < employee.unlockLevel

        CinemaCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: employee.icon)
                        .font(.title2)
                        .frame(width: 34, height: 34)
                        .foregroundStyle(CinemaTheme.gold)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(employee.name)
                                .font(.headline)
                            Spacer()
                            Text("x\(count)")
                                .font(.caption.weight(.bold))
                        }
                        Text(locked ? "Freischaltung mit Level \(employee.unlockLevel)" : "Einnahmen +\(Int(employee.incomeMultiplier * 100))%, Kunden +\(Int(employee.customerMultiplier * 100))%, Offline +\(Int(employee.offlineBonus * 100))% je Person")
                            .font(.caption)
                            .foregroundStyle(CinemaTheme.muted)
                    }
                }

                PrimaryGameButton(title: "Einstellen \(engine.formatShort(cost))", icon: "person.badge.plus.fill", disabled: locked || engine.state.coins < cost) {
                    engine.hire(employee)
                }
            }
        }
    }
}

