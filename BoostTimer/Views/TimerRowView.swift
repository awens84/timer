import SwiftUI

struct TimerRowView: View {
    let timer: TimerItem
    let onDelete: () -> Void

    @State private var pulseOpacity: Double = 0.0
    @State private var isHovering = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            // Name + delete button
            nameRow

            // Large timer display
            timerDisplay

            // Progress bar + controls
            controlsRow
        }
        .padding(12)
        .background { cardBackground }
        .onHover { isHovering = $0 }
        .onChange(of: timer.state) { oldState, newState in
            handleStateTransition(from: oldState, to: newState)
        }
    }

    // MARK: - Name Row

    private var nameRow: some View {
        HStack {
            Text(timer.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            // State indicator
            if timer.state == .running || timer.state == .warning {
                Circle()
                    .fill(timer.state.color)
                    .frame(width: 6, height: 6)
                    .shadow(color: timer.state.color.opacity(0.5), radius: 3)
            }

            // Delete button (visible on hover)
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .opacity(isHovering ? 1 : 0)
            .animation(.easeInOut(duration: 0.15), value: isHovering)
            .help("Удалить таймер")
        }
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        Text(timer.displayTime)
            .font(.system(size: 40, weight: .ultraLight, design: .monospaced))
            .foregroundStyle(timer.state.color)
            .contentTransition(.numericText())
            .animation(.linear(duration: 0.1), value: timer.remainingSeconds)
            .shadow(
                color: timer.state.isAlert ? timer.state.color.opacity(0.4) : .clear,
                radius: timer.state.isAlert ? 8 : 0
            )
    }

    // MARK: - Controls Row

    private var controlsRow: some View {
        HStack(spacing: 8) {
            // Progress bar
            progressBar

            Spacer()

            // Control buttons
            HStack(spacing: 2) {
                // Play / Pause / Restart
                Button(action: { timer.toggleStartPause() }) {
                    Image(systemName: playPauseIcon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(timer.state.color)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(playPauseTooltip)

                // Reset
                Button(action: { timer.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(timer.state == .idle)
                .opacity(timer.state == .idle ? 0.3 : 1)
                .help("Сбросить")
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.15))

                // Filled portion
                RoundedRectangle(cornerRadius: 2)
                    .fill(timer.state.color.opacity(0.8))
                    .frame(width: max(0, geo.size.width * timer.progress))
                    .animation(.linear(duration: 0.3), value: timer.progress)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Card Background

    private var cardBackground: some View {
        ZStack {
            // Base material
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)

            // Alert glow overlay
            if timer.state.isAlert {
                RoundedRectangle(cornerRadius: 10)
                    .fill(timer.state.color.opacity(0.05 + pulseOpacity * 0.08))

                RoundedRectangle(cornerRadius: 10)
                    .stroke(timer.state.color.opacity(0.3 + pulseOpacity * 0.3), lineWidth: 1)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
            }
        }
        .shadow(
            color: timer.state.isAlert
                ? timer.state.color.opacity(0.15 + pulseOpacity * 0.15)
                : Color.black.opacity(0.1),
            radius: timer.state.isAlert ? 10 : 4,
            y: 2
        )
    }

    // MARK: - Helpers

    private var playPauseIcon: String {
        switch timer.state {
        case .idle:
            return "play.fill"
        case .running, .warning:
            return "pause.fill"
        case .paused:
            return "play.fill"
        case .finished:
            return "arrow.counterclockwise"
        }
    }

    private var playPauseTooltip: String {
        switch timer.state {
        case .idle, .paused:
            return "Старт"
        case .running, .warning:
            return "Пауза"
        case .finished:
            return "Перезапустить"
        }
    }

    private func handleStateTransition(from oldState: TimerState, to newState: TimerState) {
        if newState.isAlert {
            startPulsing()
        } else {
            stopPulsing()
        }
    }

    private func startPulsing() {
        withAnimation(
            .easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        ) {
            pulseOpacity = 1.0
        }
    }

    private func stopPulsing() {
        withAnimation(.easeOut(duration: 0.3)) {
            pulseOpacity = 0.0
        }
    }
}
