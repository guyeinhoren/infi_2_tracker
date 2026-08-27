import SwiftUI

struct ProgressSectionView: View {
    var store: StudyStore
    @Environment(\.colorScheme) private var colorScheme

    private let taskTypeColumns = [
        GridItem(.adaptive(minimum: 95, maximum: 120), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("התקדמות")

            // Overall Progress Card
            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("התקדמות כוללת")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text("\(store.completedSubTasks) מתוך \(store.totalSubTasks) משימות הושלמו")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                CircularRingView(
                    progress: store.overallProgress,
                    color: overallColor,
                    lineWidth: 12,
                    size: 104,
                    showPercentage: true
                )
            }
            .padding(20)
            .background(
                colorScheme == .dark
                    ? AnyShapeStyle(.regularMaterial)
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

            // Rings per task type section
            VStack(alignment: .leading, spacing: 10) {
                Text("התקדמות לפי סוג מטלה")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: taskTypeColumns, spacing: 12) {
                    ForEach(SubTaskType.allCases, id: \.self) { type in
                        let tasks = store.units.flatMap(\.subTasks).filter { $0.type == type }
                        let completed = tasks.filter(\.isCompleted).count
                        let total = tasks.count
                        let progress = total > 0 ? Double(completed) / Double(total) : 0.0

                        if total > 0 {
                            VStack(spacing: 8) {
                                CircularRingView(
                                    progress: progress,
                                    color: type.color,
                                    lineWidth: 6,
                                    size: 60,
                                    showPercentage: true
                                )

                                VStack(spacing: 2) {
                                    HStack(spacing: 4) {
                                        Image(systemName: type.sfSymbol)
                                            .font(.caption2.bold())
                                            .foregroundStyle(type.color)
                                        Text(type.title)
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                    }

                                    Text("\(completed)/\(total)")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                colorScheme == .dark
                                    ? AnyShapeStyle(.regularMaterial)
                                    : AnyShapeStyle(Color.white),
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                            .shadow(
                                color: colorScheme == .dark ? .clear : Color.black.opacity(0.04),
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.06),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }
            }
        }
    }

    private var overallColor: Color {
        let p = store.overallProgress
        if p < 0.33 { return .red }
        if p < 0.66 { return .orange }
        return .green
    }
}

extension SubTaskType {
    var title: String {
        switch self {
        case .lecture:          return "שיעורים"
        case .exercise:         return "תרגילים"
        case .extraExercise:    return "תרגול נוסף"
        case .reminder:         return "תזכורות"
        case .computerExercise: return "ממוחשב"
        }
    }
}

extension SubTaskType: CaseIterable {
    public static var allCases: [SubTaskType] {
        [.lecture, .exercise, .extraExercise, .reminder, .computerExercise]
    }
}
