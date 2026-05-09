import Foundation
import SwiftUI
import UserNotifications
import AppKit

enum Phase {
    case work, shortBreak, longBreak

    var label: String {
        switch self {
        case .work: return "专注"
        case .shortBreak: return "短休息"
        case .longBreak: return "长休息"
        }
    }

    var color: Color {
        switch self {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }

    var icon: String {
        switch self {
        case .work: return "timer"
        case .shortBreak, .longBreak: return "cup.and.saucer"
        }
    }
}

@MainActor
final class PomodoroTimer: ObservableObject {
    @Published var phase: Phase = .work
    @Published var remaining: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var completedWorkSessions: Int = 0

    let workDuration = 25 * 60
    let shortBreakDuration = 5 * 60
    let longBreakDuration = 15 * 60
    let sessionsBeforeLongBreak = 4

    private var endDate: Date?
    private var tickTask: Task<Void, Never>?

    var totalForPhase: Int {
        switch phase {
        case .work: return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }

    var progress: Double {
        let total = Double(totalForPhase)
        guard total > 0 else { return 0 }
        return 1.0 - Double(remaining) / total
    }

    var timeString: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    var menuBarTitle: String {
        if isRunning || remaining < totalForPhase {
            return timeString
        }
        return phase.label
    }

    var menuBarIcon: String { phase.icon }

    var cyclePosition: Int {
        completedWorkSessions % sessionsBeforeLongBreak
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func start() {
        guard !isRunning else { return }
        if remaining <= 0 { remaining = totalForPhase }
        isRunning = true
        endDate = Date().addingTimeInterval(TimeInterval(remaining))
        tickTask = Task { @MainActor [weak self] in
            while let self, self.isRunning, !Task.isCancelled {
                self.tick()
                if self.remaining <= 0 { break }
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    func pause() {
        isRunning = false
        tickTask?.cancel()
        tickTask = nil
    }

    func reset() {
        pause()
        remaining = totalForPhase
    }

    func resetAll() {
        pause()
        phase = .work
        completedWorkSessions = 0
        remaining = workDuration
    }

    private func tick() {
        guard let end = endDate else { return }
        let r = Int(end.timeIntervalSinceNow.rounded(.up))
        remaining = max(0, r)
        if remaining == 0 {
            advancePhase()
        }
    }

    private func advancePhase() {
        let finished = phase
        pause()
        if finished == .work {
            completedWorkSessions += 1
        }
        let next: Phase
        switch finished {
        case .work:
            next = (completedWorkSessions % sessionsBeforeLongBreak == 0) ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            next = .work
        }
        phase = next
        remaining = totalForPhase
        notify(finished: finished, next: next)
        playSound()
    }

    private func notify(finished: Phase, next: Phase) {
        let content = UNMutableNotificationContent()
        content.title = "\(finished.label)结束"
        content.body = "下一阶段：\(next.label) · 点击菜单栏开始"
        content.sound = .default
        let req = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(req)
    }

    private func playSound() {
        NSSound(named: NSSound.Name("Glass"))?.play()
    }
}
