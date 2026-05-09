import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var timer: PomodoroTimer

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label(timer.phase.label, systemImage: timer.phase.icon)
                    .font(.headline)
                    .foregroundColor(timer.phase.color)
                Spacer()
                Text("\(timer.cyclePosition)/\(timer.sessionsBeforeLongBreak)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.18), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(
                        timer.phase.color,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: timer.progress)
                Text(timer.timeString)
                    .font(.system(size: 40, weight: .medium, design: .monospaced))
                    .monospacedDigit()
            }
            .frame(width: 170, height: 170)
            .padding(.vertical, 4)

            HStack(spacing: 10) {
                Button(action: { timer.toggle() }) {
                    Label(
                        timer.isRunning ? "暂停" : "开始",
                        systemImage: timer.isRunning ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.space, modifiers: [])

                Button(action: { timer.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 24)
                }
                .controlSize(.large)
                .buttonStyle(.bordered)
                .help("重置当前阶段")
            }

            Divider()

            HStack {
                Button("全部重置") { timer.resetAll() }
                    .buttonStyle(.borderless)
                    .font(.caption)
                Spacer()
                Button("退出") { NSApp.terminate(nil) }
                    .buttonStyle(.borderless)
                    .font(.caption)
                    .keyboardShortcut("q")
            }
        }
        .padding(18)
        .frame(width: 260)
    }
}
