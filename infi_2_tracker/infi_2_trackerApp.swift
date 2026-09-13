import SwiftUI

@main
struct infi_2_trackerApp: App {
    @State private var store = StudyStore()

    var body: some Scene {
        WindowGroup("חדווא 2") {
            ContentView(store: store)
        }

        WindowGroup("תכנון שבועי", id: "weekly-calendar") {
            CalendarWindowView(store: store)
        }
        .defaultSize(width: 920, height: 560)
    }
}
