import SwiftUI

enum CinemaTheme {
    static let background = Color(red: 0.055, green: 0.045, blue: 0.065)
    static let panel = Color(red: 0.12, green: 0.09, blue: 0.12)
    static let panelLight = Color(red: 0.18, green: 0.13, blue: 0.16)
    static let gold = Color(red: 1.0, green: 0.72, blue: 0.23)
    static let red = Color(red: 0.78, green: 0.12, blue: 0.18)
    static let green = Color(red: 0.18, green: 0.74, blue: 0.48)
    static let muted = Color.white.opacity(0.68)
}

struct MetricPill: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(CinemaTheme.muted)
                Text(value)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(CinemaTheme.panelLight, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct CinemaCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .background(CinemaTheme.panel, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
    }
}

struct PrimaryGameButton: View {
    let title: String
    let icon: String
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .foregroundStyle(disabled ? Color.white.opacity(0.35) : Color.black)
        .background(disabled ? Color.white.opacity(0.10) : CinemaTheme.gold, in: RoundedRectangle(cornerRadius: 8))
        .disabled(disabled)
    }
}

struct ProgressLine: View {
    let title: String
    let value: Double
    let target: Double
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(min(value, target)))/\(Int(target))")
                    .foregroundStyle(CinemaTheme.muted)
            }
            .font(.caption.weight(.semibold))

            ProgressView(value: min(value / max(1, target), 1))
                .tint(tint)
        }
    }
}

