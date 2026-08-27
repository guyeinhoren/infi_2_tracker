import SwiftUI

// MARK: - Circular Progress Ring

struct CircularRingView: View {
    var progress: Double
    var color: Color = .blue
    var lineWidth: CGFloat = 10
    var size: CGFloat = 80
    var label: String? = nil
    var showPercentage: Bool = true

    var body: some View {
        ZStack {
            // Background ring track
            Circle()
                .stroke(color.opacity(0.12), lineWidth: lineWidth)

            // Outer blur ring effect
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    color.opacity(0.3),
                    style: StrokeStyle(lineWidth: lineWidth + 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .blur(radius: 4)

            // Main animated progress stroke
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.7), color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: progress)

            if showPercentage {
                VStack(spacing: 1) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                        .animation(.spring(), value: progress)
                    if let label = label {
                        Text(label)
                            .font(.system(size: size * 0.12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(size * 0.08)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Countdown View

struct CountdownView: View {
    let targetDate: Date
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let remaining = max(0, targetDate.timeIntervalSince(ctx.date))
            let days    = Int(remaining) / 86400
            let hours   = (Int(remaining) % 86400) / 3600
            let minutes = (Int(remaining) % 3600) / 60
            let seconds = Int(remaining) % 60

            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("מבחן חדווא 2")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("ה-3 בספטמבר 2026  |  08:30")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // First item in HStack in RTL layout direction appears on the FAR RIGHT side
                HStack(spacing: 6) {
                    timeUnit(value: seconds, label: "שניות")
                    colonSeparator
                    timeUnit(value: minutes, label: "דקות")
                    colonSeparator
                    timeUnit(value: hours,   label: "שעות")
                    colonSeparator
                    timeUnit(value: days,    label: "ימים")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                colorScheme == .dark
                    ? AnyShapeStyle(.ultraThinMaterial)
                    : AnyShapeStyle(Color.white),
                in: RoundedRectangle(cornerRadius: 24)
            )
            .shadow(
                color: colorScheme == .dark ? .clear : Color.black.opacity(0.04),
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.06),
                        lineWidth: 1
                    )
            )
        }
    }

    private var colonSeparator: some View {
        Text(":")
            .font(.system(size: 24, weight: .light))
            .foregroundStyle(.tertiary)
            .offset(y: -10)
    }

    private func timeUnit(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .contentTransition(.numericText(countsDown: true))
                .animation(.linear(duration: 0.25), value: value)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 54)
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
            // First item in RTL is placed on the RIGHT edge
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Spacer()

            if let badge = badge {
                Text(badge)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
            }
        }
    }
}
