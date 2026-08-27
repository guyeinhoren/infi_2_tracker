import SwiftUI

struct ContentView: View {
    @State private var store = StudyStore()

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                appHeader
                    .padding(.top, 8)

                CountdownView(targetDate: examDate)
                    .padding(.horizontal)

                ProgressSectionView(store: store)
                    .padding(.horizontal)

                studyUnitsSection

                ExamsSectionView(store: store)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
            }
        }
        .background(backgroundGradient)
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Header

    private var appHeader: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue.opacity(0.6), .indigo.opacity(0.3)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 12)
                Image(systemName: "sum")
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("חדווא 2")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)

            Text("מעקב למידה למבחן")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Study Units Section

    private var studyUnitsSection: some View {
        VStack(alignment: .trailing, spacing: 10) {
            SectionHeader(
                "יחידות לימוד",
                badge: "\(store.completedSubTasks)/\(store.totalSubTasks) הושלמו"
            )
            .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(store.units) { unit in
                    TaskGroupRowView(store: store, unit: unit)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.04, green: 0.07, blue: 0.22), location: 0.0),
                .init(color: Color(red: 0.07, green: 0.04, blue: 0.18), location: 0.45),
                .init(color: Color(red: 0.05, green: 0.08, blue: 0.20), location: 1.0),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .frame(width: 480, height: 900)
}
