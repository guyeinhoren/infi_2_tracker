import SwiftUI

// MARK: - Circular Progress Ring

struct CircularRingView: View {
    var progress: Double
    var color: Color = .blue
    var lineWidth: CGFloat = 10
    var size: CGFloat = 80
    var label: String? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.18), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.6), color],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: progress)

            VStack(spacing: 1) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.21, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .animation(.spring(), value: progress)
                if let label = label {
                    Text(label)
                        .font(.system(size: size * 0.13, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(size * 0.1)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Countdown View

struct CountdownView: View {
    let targetDate: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let remaining = max(0, targetDate.timeIntervalSince(ctx.date))
            let days    = Int(remaining) / 86400
            let hours   = (Int(remaining) % 86400) / 3600
            let minutes = (Int(remaining) % 3600) / 60
            let seconds = Int(remaining) % 60

            VStack(spacing: 10) {
                VStack(spacing: 2) {
                    Text("מבחן חדווא 2")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    Text("ה-3 בספטמבר 2026  |  08:30")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    timeUnit(value: days,    label: "ימים")
                    colonSeparator
                    timeUnit(value: hours,   label: "שעות")
                    colonSeparator
                    timeUnit(value: minutes, label: "דקות")
                    colonSeparator
                    timeUnit(value: seconds, label: "שניות")
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .glassEffect(in: .rect(cornerRadius: 22))
        }
    }

    private var colonSeparator: some View {
        Text(":")
            .font(.system(size: 26, weight: .ultraLight))
            .foregroundStyle(.tertiary)
            .offset(y: -10)
    }

    private func timeUnit(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .contentTransition(.numericText(countsDown: true))
                .animation(.linear(duration: 0.25), value: value)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 58)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let badge: String?

    init(_ title: String, badge: String? = nil) {
        self.title = title
        self.badge = badge
    }

    var body: some View {
        HStack(spacing: 8) {
            if let badge = badge {
                Text(badge)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.primary)
        }
    }
}
