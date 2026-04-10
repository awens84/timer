import SwiftUI

struct AddTimerSheet: View {
    let viewModel: TimerListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var minutes: Int = 5
    @State private var seconds: Int = 0

    // Presets: (label, seconds)
    private let presets: [(String, Int)] = [
        ("1m", 60),
        ("3m", 180),
        ("5m", 300),
        ("10m", 600),
        ("15m", 900),
        ("25m", 1500),
        ("30m", 1800),
    ]

    private var totalSeconds: Int {
        minutes * 60 + seconds
    }

    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.cyan)
                Text("Новый таймер")
                    .font(.system(size: 14, weight: .semibold))
            }

            // Name field
            TextField("Название (необязательно)", text: $name)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))

            // Presets
            VStack(alignment: .leading, spacing: 8) {
                Text("Пресеты")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4),
                    spacing: 6
                ) {
                    ForEach(presets, id: \.1) { preset in
                        Button(preset.0) {
                            minutes = preset.1 / 60
                            seconds = preset.1 % 60
                        }
                        .buttonStyle(PresetButtonStyle(isSelected: totalSeconds == preset.1))
                    }
                }
            }

            // Manual input
            VStack(alignment: .leading, spacing: 8) {
                Text("Вручную")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    // Minutes stepper
                    HStack(spacing: 4) {
                        Text("\(minutes)")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .frame(width: 30, alignment: .trailing)

                        Text("мин")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)

                        Stepper("", value: $minutes, in: 0...99)
                            .labelsHidden()
                    }

                    Text(":")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(.tertiary)

                    // Seconds stepper
                    HStack(spacing: 4) {
                        Text(String(format: "%02d", seconds))
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .frame(width: 30, alignment: .trailing)

                        Text("сек")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)

                        Stepper("", value: $seconds, in: 0...59)
                            .labelsHidden()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            // Total time display
            if totalSeconds > 0 {
                Text("Всего: \(totalTimeDisplay)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.cyan)
            }

            Divider()

            // Action buttons
            HStack {
                Button("Отмена") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Создать") {
                    createTimer()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(totalSeconds == 0)
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
            }
        }
        .padding(20)
        .frame(width: 300)
    }

    // MARK: - Helpers

    private var totalTimeDisplay: String {
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func createTimer() {
        guard totalSeconds > 0 else { return }
        let timerName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.addTimer(
            name: timerName.isEmpty ? "Таймер" : timerName,
            seconds: totalSeconds
        )
        dismiss()
    }
}

// MARK: - Preset Button Style

struct PresetButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.cyan.opacity(0.15) : Color.gray.opacity(0.08))
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(
                                isSelected ? Color.cyan.opacity(0.5) : Color.gray.opacity(0.15),
                                lineWidth: 1
                            )
                    }
            }
            .foregroundStyle(isSelected ? .cyan : .secondary)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
