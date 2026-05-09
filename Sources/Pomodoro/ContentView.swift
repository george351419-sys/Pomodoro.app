import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var timer: PomodoroTimer
    @State private var showingSettings = false

    var body: some View {
        Group {
            if showingSettings {
                SettingsView(showing: $showingSettings)
            } else {
                TimerView(showSettings: { showingSettings = true })
            }
        }
        .padding(18)
        .frame(width: 280)
    }
}

private struct TimerView: View {
    @EnvironmentObject var timer: PomodoroTimer
    let showSettings: () -> Void

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
                Button(action: showSettings) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.borderless)
                .help("设置")
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
    }
}

private struct SettingsView: View {
    @EnvironmentObject var timer: PomodoroTimer
    @Binding var showing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("设置").font(.headline)
                Spacer()
                Button("完成") { showing = false }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .keyboardShortcut(.defaultAction)
            }

            durationRow(
                title: "专注",
                value: $timer.workMinutes,
                range: 1...120,
                tint: .red
            )
            durationRow(
                title: "短休息",
                value: $timer.shortBreakMinutes,
                range: 1...60,
                tint: .green
            )
            durationRow(
                title: "长休息",
                value: $timer.longBreakMinutes,
                range: 1...60,
                tint: .blue
            )

            HStack {
                Text("长休息间隔")
                    .frame(width: 80, alignment: .leading)
                Stepper(
                    value: $timer.sessionsBeforeLongBreak,
                    in: 2...10
                ) {
                    Text("每 \(timer.sessionsBeforeLongBreak) 个专注")
                        .monospacedDigit()
                }
            }

            Divider()

            HStack {
                Button("恢复默认") { timer.restoreDefaults() }
                    .buttonStyle(.borderless)
                    .font(.caption)
                Spacer()
                Text("修改不影响进行中的阶段")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func durationRow(
        title: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        tint: Color
    ) -> some View {
        HStack {
            Text(title)
                .frame(width: 80, alignment: .leading)
                .foregroundColor(tint)
            Stepper(value: value, in: range) {
                Text("\(value.wrappedValue) 分钟")
                    .monospacedDigit()
            }
        }
    }
}
