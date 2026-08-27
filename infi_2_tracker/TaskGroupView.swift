import SwiftUI
#if os(macOS)
import AppKit
#endif

// MARK: - Task Group Row

struct TaskGroupRowView: View {
    var store: StudyStore
    let unit: StudyUnit
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            groupHeader

            if unit.isExpanded {
                Divider()
                    .padding(.horizontal, 14)
                    .opacity(0.4)

                subTasksList
            }
        }
        .background(
            colorScheme == .dark
                ? AnyShapeStyle(.regularMaterial)
                : AnyShapeStyle(Color.white),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .shadow(
            color: colorScheme == .dark ? .clear : Color.black.opacity(0.04),
            radius: 8,
            x: 0,
            y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    unit.progress >= 1.0
                        ? Color.green.opacity(0.5)
                        : (colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.06)),
                    lineWidth: 1
                )
        )
        .clipped()
    }

    private var groupHeader: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                store.toggleExpanded(unit.id)
            }
        } label: {
            HStack(spacing: 12) {
                // Unit Title & Number (Right side)
                VStack(alignment: .leading, spacing: 3) {
                    Text(unit.topic)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text("יחידה \(unit.unitNumber)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Badge (completed / total count)
                Text("\(unit.completedCount)/\(unit.totalCount)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(unit.progress >= 1.0 ? .green : .secondary)
                    .monospacedDigit()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        unit.progress >= 1.0
                            ? Color.green.opacity(0.15)
                            : Color.primary.opacity(0.06),
                        in: Capsule()
                    )

                // Chevron indicating expansion (Left side)
                Image(systemName: "chevron.left")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(unit.isExpanded ? -90 : 0))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
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
                        .padding(.horizontal, 16)
                        .opacity(0.3)
                }
            }
        }
        .padding(.vertical, 4)
        .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
    }
}

// MARK: - Sub-Task Row

struct SubTaskRowView: View {
    var store: StudyStore
    let unitId: String
    let task: SubTask

    var body: some View {
        HStack(spacing: 12) {
            // Checkmark completion toggle
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

            // Tappable Task Type Icon
            if let url = task.openURL {
                Button {
                    openItem(url)
                } label: {
                    typeBadge
                }
                .buttonStyle(.plain)
                .help(task.type == .computerExercise ? "פתח תרגול ממוחשב בדפדפן" : "פתח קובץ PDF")
            } else {
                typeBadge
            }

            // Task display name
            Text(task.displayName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .strikethrough(task.isCompleted, color: .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            task.isCompleted
                ? Color.green.opacity(0.08)
                : Color.clear
        )
    }

    private var typeBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(task.type.color.opacity(0.18))
                .frame(width: 32, height: 32)
            Image(systemName: task.type.sfSymbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(task.type.color)
        }
    }

    private func openItem(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}
