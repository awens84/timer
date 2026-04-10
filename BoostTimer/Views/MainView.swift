import SwiftUI

// MARK: - Panel Resize Notification

extension Notification.Name {
    static let panelResize = Notification.Name("com.boosttimer.panelResize")
}

// MARK: - Expanded Screen

enum ExpandedScreen {
    case list
    case addTimer
    case settings
}

// MARK: - Main View

struct MainView: View {
    @Bindable var viewModel: TimerListViewModel
    @AppStorage("isDarkMode") private var isDarkMode = true

    var body: some View {
        Group {
            if viewModel.isExpanded {
                expandedView
            } else {
                compactView
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear { requestResize() }
        .onChange(of: viewModel.isExpanded) { _, _ in requestResize() }
        .onChange(of: viewModel.timers.count) { _, _ in
            if !viewModel.isExpanded { requestResize() }
        }
    }

    // MARK: - Compact View (Micro Pill)

    private var compactView: some View {
        VStack(spacing: 0) {
            if viewModel.timers.isEmpty {
                emptyPill
            } else {
                ForEach(viewModel.timers) { timer in
                    CompactTimerRow(timer: timer)
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.5), radius: 6, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.timers.isEmpty {
                viewModel.expandedScreen = .addTimer
            } else {
                viewModel.expandedScreen = .list
            }
            viewModel.isExpanded = true
            requestResize()
        }
        .contextMenu {
            Button("Добавить таймер") {
                viewModel.expandedScreen = .addTimer
                viewModel.isExpanded = true
                requestResize()
            }
            Divider()
            Button("Настройки") {
                viewModel.expandedScreen = .settings
                viewModel.isExpanded = true
                requestResize()
            }
            Divider()
            Button("Выход") { NSApp.terminate(nil) }
        }
    }

    private var emptyPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 9))
                .foregroundStyle(.cyan)
            Text("+")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.cyan.opacity(0.5))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }

    // MARK: - Expanded View

    private var expandedView: some View {
        VStack(spacing: 0) {
            // Header
            expandedHeader

            Divider().opacity(0.15)

            // Content
            switch viewModel.expandedScreen {
            case .list:
                expandedTimerList
            case .addTimer:
                AddTimerSheet(viewModel: viewModel) {
                    viewModel.expandedScreen = .list
                    requestResize()
                }
            case .settings:
                SettingsSheet {
                    viewModel.expandedScreen = .list
                    requestResize()
                }
            }
        }
        .frame(width: 250)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.5), radius: 8, y: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var expandedHeader: some View {
        HStack(spacing: 6) {
            Button {
                viewModel.isExpanded = false
                viewModel.expandedScreen = .list
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Свернуть")

            Text("Boost Timer")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Spacer()

            if viewModel.expandedScreen == .list {
                Button {
                    viewModel.expandedScreen = .settings
                    requestResize()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    viewModel.expandedScreen = .list
                    requestResize()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
    }

    private var expandedTimerList: some View {
        VStack(spacing: 0) {
            if viewModel.hasTimers {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(viewModel.timers) { timer in
                            TimerRowView(timer: timer) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.removeTimer(timer)
                                    requestResize()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                }
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 22, weight: .ultraLight))
                        .foregroundStyle(.tertiary)
                    Text("Нет таймеров")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, minHeight: 60)
            }

            // Add button
            Button {
                viewModel.expandedScreen = .addTimer
                requestResize()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 11))
                    Text("Добавить")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(.cyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Resize

    private func requestResize() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let size: NSSize
            if viewModel.isExpanded {
                switch viewModel.expandedScreen {
                case .list:
                    let h = max(150, viewModel.timers.count * 90 + 75)
                    size = NSSize(width: 250, height: min(CGFloat(h), 380))
                case .addTimer:
                    size = NSSize(width: 250, height: 320)
                case .settings:
                    size = NSSize(width: 250, height: 340)
                }
            } else {
                if viewModel.timers.isEmpty {
                    size = NSSize(width: 64, height: 28)
                } else {
                    let rows = viewModel.timers.count
                    size = NSSize(width: 100, height: CGFloat(rows * 24 + 10))
                }
            }
            NotificationCenter.default.post(
                name: .panelResize,
                object: nil,
                userInfo: ["size": size]
            )
        }
    }
}

// MARK: - Compact Timer Row

struct CompactTimerRow: View {
    let timer: TimerItem
    @State private var pulseOpacity: Double = 0.0

    var body: some View {
        HStack(spacing: 4) {
            if timer.isActive || timer.state == .finished {
                Circle()
                    .fill(timer.state.color)
                    .frame(width: 5, height: 5)
                    .shadow(color: timer.state.isAlert ? timer.state.color : .clear, radius: 3)
            }

            Text(timer.displayTime)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(timer.state.color)
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.1), value: timer.remainingSeconds)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity)
        .onChange(of: timer.state) { _, newState in
            if newState.isAlert {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    pulseOpacity = 1
                }
            } else {
                withAnimation { pulseOpacity = 0 }
            }
        }
    }
}
