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

            // Featured exam — first in list, larger card
            if let featured = store.exams.first {
                FeaturedExamView(store: store, exam: featured)
            }

            // Remaining exams in adaptive grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(store.exams.dropFirst()) { exam in
                    ExamFileRowView(store: store, exam: exam)
                }
            }
        }
    }
}

// MARK: - Featured Exam Card

struct FeaturedExamView: View {
    var store: StudyStore
    let exam: ExamFile
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.28)) {
                    store.toggleExam(exam.id)
                }
            } label: {
                Image(systemName: exam.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(exam.isCompleted ? .green : Color.secondary.opacity(0.5))
                    .symbolEffect(.bounce, value: exam.isCompleted)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("הכי חשוב")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.orange)
                }

                Text(exam.displayName)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(exam.isCompleted ? .secondary : .primary)
                    .strikethrough(exam.isCompleted, color: .secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let solutionURL = exam.solutionURL {
                Button { openFile(solutionURL) } label: {
                    ZStack {
                        Circle().fill(Color.green.opacity(0.15)).frame(width: 40, height: 40)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.green)
                    }
                }
                .buttonStyle(.plain)
                .help("פתח פתרון")
            }

            Button { openFile(exam.openURL) } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.orange)
                }
            }
            .buttonStyle(.plain)
            .help("פתח מבחן")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            colorScheme == .dark
                ? AnyShapeStyle(Color(nsColor: .controlBackgroundColor))
                : AnyShapeStyle(Color.white),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    exam.isCompleted ? Color.green.opacity(0.5) : Color.orange.opacity(0.4),
                    lineWidth: 1.5
                )
        )
        .draggable(CalendarTask(
            id: exam.id, subTaskId: exam.id,
            unitNumber: "", displayName: exam.displayName, type: .exam
        ))
    }

    private func openFile(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}

// MARK: - Regular Exam Card

struct ExamFileRowView: View {
    var store: StudyStore
    let exam: ExamFile
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 10) {
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

            Text(exam.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(exam.isCompleted ? .secondary : .primary)
                .strikethrough(exam.isCompleted, color: .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let solutionURL = exam.solutionURL {
                Button { openFile(solutionURL) } label: {
                    ZStack {
                        Circle().fill(Color.green.opacity(0.18)).frame(width: 30, height: 30)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.green)
                    }
                }
                .buttonStyle(.plain)
                .help("פתח פתרון")
            }

            Button { openFile(exam.openURL) } label: {
                ZStack {
                    Circle().fill(Color.purple.opacity(0.18)).frame(width: 30, height: 30)
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.purple)
                }
            }
            .buttonStyle(.plain)
            .help("פתח מבחן")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            colorScheme == .dark
                ? AnyShapeStyle(Color(nsColor: .controlBackgroundColor))
                : AnyShapeStyle(Color.white),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    exam.isCompleted
                        ? Color.green.opacity(0.5)
                        : (colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.09)),
                    lineWidth: 1
                )
        )
        .draggable(CalendarTask(
            id: exam.id, subTaskId: exam.id,
            unitNumber: "", displayName: exam.displayName, type: .exam
        ))
    }

    private func openFile(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}
