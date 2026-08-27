import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ExamsSectionView: View {
    var store: StudyStore

    private let columns = [GridItem(.adaptive(minimum: 160, maximum: 220), spacing: 10)]

    var body: some View {
        VStack(alignment: .trailing, spacing: 14) {
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

    var body: some View {
        HStack(spacing: 8) {
            // Completion toggle
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

            // Name
            Text(exam.displayName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(exam.isCompleted ? .secondary : .primary)
                .strikethrough(exam.isCompleted, color: .secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)

            // Open button
            Button {
                openFile(exam.openURL)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.purple)
                }
            }
            .buttonStyle(.plain)
            .help("פתח מבחן PDF")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    exam.isCompleted ? Color.green.opacity(0.45) : Color.white.opacity(0.08),
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
