import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ExamsSectionView: View {
    var store: StudyStore

    private let columns = [GridItem(.adaptive(minimum: 160, maximum: 220), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(
                "מבחנים קודמים",
                badge: "\(store.completedExams)/\(store.exams.count) נפתרו"
            )

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(store.exams) { exam in
                    ExamFileRowView(store: store, exam: exam)
                }
            }
        }
    }
}

struct ExamFileRowView: View {
    var store: StudyStore
    let exam: ExamFile
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 10) {
            // Checkmark button on FAR RIGHT side in RTL
            Button {
                withAnimation(.spring(response: 0.28)) {
                    store.toggleExam(exam.id)
                }
            } label: {
                Image(systemName: exam.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(exam.isCompleted ? .green : Color.secondary.opacity(0.5))
                    .symbolEffect(.bounce, value: exam.isCompleted)
            }
            .buttonStyle(.plain)

            // Name aligned to right
            Text(exam.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(exam.isCompleted ? .secondary : .primary)
                .strikethrough(exam.isCompleted, color: .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Open button on FAR LEFT side in RTL
            Button {
                openFile(exam.openURL)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.18))
                        .frame(width: 30, height: 30)
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.purple)
                }
            }
            .buttonStyle(.plain)
            .help("פתח מבחן PDF")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            colorScheme == .dark
                ? AnyShapeStyle(.regularMaterial)
                : AnyShapeStyle(Color.white),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .shadow(
            color: colorScheme == .dark ? .clear : Color.black.opacity(0.04),
            radius: 6,
            x: 0,
            y: 2
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    exam.isCompleted
                        ? Color.green.opacity(0.5)
                        : (colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.06)),
                    lineWidth: 1
                )
        )
    }

    private func openFile(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}
