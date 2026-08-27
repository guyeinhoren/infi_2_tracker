import SwiftUI
#if os(macOS)
import AppKit
#endif

// MARK: - Task Group Row

struct TaskGroupRowView: View {
    var store: StudyStore
    let unit: StudyUnit

    var body: some View {
        VStack(spacing: 0) {
            groupHeader
            if unit.isExpanded {
                Divider()
                    .padding(.horizontal, 14)
                subTasksList
            }
        }
        .background(.regularMaterial, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    unit.progress >= 1.0 ? Color.green.opacity(0.5) : Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }

    private var groupHeader: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                store.toggleExpanded(unit.id)
            }
        } label: {
            HStack(spacing: 12) {
                // Expand chevron
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(unit.isExpanded ? 90 : 0))
                    .animation(.spring(response: 0.35), value: unit.isExpanded)

                // Progress ring
                CircularRingView(
                    progress: unit.progress,
                    color: unit.progress >= 1.0 ? .green : .blue,
                    lineWidth: 4,
                    size: 42,
                    label: nil
                )

                // Unit info
                VStack(alignment: .trailing, spacing: 2) {
                    Text(unit.topic)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.trailing)
                    Text("יחידה \(unit.unitNumber)  •  \(unit.completedCount)/\(unit.totalCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var subTasksList: some View {
        VStack(spacing: 1) {
            ForEach(unit.subTasks) { task in
                SubTaskRowView(store: store, unitId: unit.id, task: task)
                if task.id != unit.subTasks.last?.id {
                    Divider()
                        .padding(.leading, 48)
                        .padding(.trailing, 14)
                }
            }
        }
        .padding(.bottom, 6)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - Sub-Task Row

struct SubTaskRowView: View {
    var store: StudyStore
    let unitId: String
    let task: SubTask

    var body: some View {
        HStack(spacing: 10) {
            // Completion toggle
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                    store.toggleSubTask(unitId: unitId, subTaskId: task.id)
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : Color.secondary.opacity(0.5))
                    .symbolEffect(.bounce, value: task.isCompleted)
            }
            .buttonStyle(.plain)

            // Type icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(task.type.color.opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: task.type.sfSymbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(task.type.color)
            }

            // Name
            Text(task.displayName)
                .font(.subheadline)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .strikethrough(task.isCompleted, color: .secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)

            // Open button
            if let url = task.openURL {
                Button {
                    openItem(url)
                } label: {
                    ZStack {
                        Circle()
                            .fill(task.type.color.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: task.type.openIcon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(task.type.color)
                    }
                }
                .buttonStyle(.plain)
                .help(task.type == .computerExercise ? "פתח תרגול ממוחשב בדפדפן" : "פתח קובץ PDF")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            task.isCompleted
                ? Color.green.opacity(0.06)
                : Color.clear
        )
    }

    private func openItem(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}
