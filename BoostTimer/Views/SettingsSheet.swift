import SwiftUI

struct SettingsSheet: View {
    var onDismiss: () -> Void

    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("warningThreshold") private var warningThreshold = 180
    @AppStorage("warningSound") private var warningSound = "Glass"
    @AppStorage("finishSound") private var finishSound = "Hero"
    @AppStorage("soundEnabled") private var soundEnabled = true

    private let availableSounds = SoundService.availableSounds

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Image(systemName: "gearshape")
                    .foregroundStyle(.secondary)
                Text("Настройки")
                    .font(.system(size: 14, weight: .semibold))
            }

            // Theme toggle
            themeSection

            Divider()

            // Warning threshold
            thresholdSection

            Divider()

            // Sound settings
            soundSection

            Divider()

            // Done button
            Button("Готово") {
                onDismiss()
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding(12)
    }

    // MARK: - Theme Section

    private var themeSection: some View {
        HStack {
            Text("Тема")
                .font(.system(size: 13))

            Spacer()

            Picker("", selection: $isDarkMode) {
                Label("Светлая", systemImage: "sun.max.fill")
                    .tag(false)
                Label("Тёмная", systemImage: "moon.fill")
                    .tag(true)
            }
            .pickerStyle(.segmented)
            .frame(width: 160)
        }
    }

    // MARK: - Threshold Section

    private var thresholdSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Предупреждение за")
                    .font(.system(size: 13))

                Spacer()

                Text(thresholdDisplay)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.orange)
            }

            Slider(
                value: Binding(
                    get: { Double(warningThreshold) },
                    set: { warningThreshold = Int($0) }
                ),
                in: 10...600,
                step: 10
            )
            .tint(.orange)

            HStack {
                Text("10 сек")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("10 мин")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Sound Section

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $soundEnabled) {
                Text("Звук")
                    .font(.system(size: 13))
            }

            if soundEnabled {
                // Warning sound
                HStack {
                    Text("Предупреждение")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Picker("", selection: $warningSound) {
                        ForEach(availableSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .frame(width: 110)

                    Button {
                        SoundService.shared.play(warningSound)
                    } label: {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Прослушать")
                }

                // Finish sound
                HStack {
                    Text("Окончание")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Picker("", selection: $finishSound) {
                        ForEach(availableSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .frame(width: 110)

                    Button {
                        SoundService.shared.play(finishSound)
                    } label: {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Прослушать")
                }
            }
        }
    }

    // MARK: - Helpers

    private var thresholdDisplay: String {
        let mins = warningThreshold / 60
        let secs = warningThreshold % 60
        if secs == 0 {
            return "\(mins):00"
        }
        return String(format: "%d:%02d", mins, secs)
    }
}
