import SwiftUI

struct ProgressSectionView: View {
    var store: StudyStore

    private let columns = [GridItem(.adaptive(minimum: 88, maximum: 108), spacing: 10)]

    var body: some View {
        VStack(alignment: .trailing, spacing: 14) {
            SectionHeader("התקדמות")

            // Overall progress card
            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 6) {
                    Text("התקדמות כוללת")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("\(store.completedSubTasks) מתוך \(store.totalSubTasks) הושלמו")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Progress breakdown
                    VStack(alignment: .trailing, spacing: 3) {
                        ForEach(SubTaskType.allCases, id: \.self) { type in
                            let count = store.units.flatMap(\.subTasks)
                                .filter { $0.type == type && $0.isCompleted }.count
                            let total = store.units.flatMap(\.subTasks)
                                .filter { $0.type == type }.count
                            if total > 0 {
                                HStack(spacing: 6) {
                                    Text("\(count)/\(total)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                    Image(systemName: type.sfSymbol)
                                        .font(.caption)
                                        .foregroundStyle(type.color)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                CircularRingView(
                    progress: store.overallProgress,
                    color: overallColor,
                    lineWidth: 14,
                    size: 118
                )
            }
            .padding(18)
            .background(.regularMaterial, in: .rect(cornerRadius: 20))

            // Per-unit progress grid
            Text("לפי יחידה")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(store.units) { unit in
                    VStack(spacing: 5) {
                        CircularRingView(
                            progress: unit.progress,
                            color: ringColor(for: unit.progress),
                            lineWidth: 6,
                            size: 68
                        )
                        Text("יח׳ \(unit.unitNumber)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 6)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial, in: .rect(cornerRadius: 14))
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

    private func ringColor(for progress: Double) -> Color {
        if progress < 0.33 { return .blue }
        if progress < 0.99 { return .orange }
        return .green
    }
}

extension SubTaskType: CaseIterable {
    public static var allCases: [SubTaskType] {
        [.lecture, .exercise, .extraExercise, .reminder, .computerExercise]
    }
}
