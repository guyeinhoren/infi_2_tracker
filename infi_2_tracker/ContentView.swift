import SwiftUI

struct ContentView: View {
    @State private var store = StudyStore()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                appHeader
                    .padding(.top, 12)

                CountdownView(targetDate: examDate)
                    .padding(.horizontal)

                ProgressSectionView(store: store)
                    .padding(.horizontal)

                studyUnitsSection

                ExamsSectionView(store: store)
                    .padding(.horizontal)
                    .padding(.bottom, 36)
            }
        }
        .background(adaptiveBackground)
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Header

    private var appHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.4), .cyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                    .blur(radius: 16)

                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                    Image(systemName: "sum")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(width: 76, height: 76)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
            }

            Text("חדווא 2")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("מעקב למידה למבחן")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Study Units Section

    private var studyUnitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                "יחידות לימוד",
                badge: "\(store.completedSubTasks)/\(store.totalSubTasks) הושלמו"
            )
            .padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(store.units) { unit in
                    TaskGroupRowView(store: store, unit: unit)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var adaptiveBackground: some View {
        ZStack {
            #if os(iOS)
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            #else
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()
            #endif

            // Ambient backdrop glows for Liquid Glass design
            GeometryReader { proxy in
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 60)
                    .position(x: proxy.size.width * 0.8, y: 100)

                Circle()
                    .fill(Color.indigo.opacity(0.1))
                    .frame(width: 360, height: 360)
                    .blur(radius: 80)
                    .position(x: proxy.size.width * 0.2, y: proxy.size.height * 0.6)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview("בהיר", traits: .fixedLayout(width: 480, height: 900)) {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("כהה", traits: .fixedLayout(width: 480, height: 900)) {
    ContentView()
        .preferredColorScheme(.dark)
}
