import SwiftUI
import UserNotifications

@main
struct PomodoroApp: App {
    @StateObject private var timer = PomodoroTimer()

    init() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(timer)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: timer.menuBarIcon)
                Text(timer.menuBarTitle)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .menuBarExtraStyle(.window)
    }
}
