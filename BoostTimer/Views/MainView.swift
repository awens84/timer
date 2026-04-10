import SwiftUI

// MARK: - Panel Resize Notification

extension Notification.Name {
    static let panelResize = Notification.Name("com.boosttimer.panelResize")
    static let panelOpacityChanged = Notification.Name("com.boosttimer.panelOpacityChanged")
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
                .fill(.thinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            // Tap toggles to expanded timer list (shows full controls)
            if viewModel.hasTimers {
                viewModel.expandedScreen = .list
                viewModel.isExpanded = true
                requestResize()
            }
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
            switch viewModel.expandedScreen {
            case .list:
                expandedTimerList
            case .addTimer:
                HStack {
                    Spacer()
                    Button {
                        viewModel.isExpanded = viewModel.hasTimers
                        viewModel.expandedScreen = .list
                        requestResize()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.trailing, 6)
                .padding(.top, 4)

                AddTimerSheet(viewModel: viewModel) {
                    viewModel.isExpanded = viewModel.hasTimers
                    viewModel.expandedScreen = .list
                    requestResize()
                }
            case .settings:
                HStack {
                    Spacer()
                    Button {
                        viewModel.isExpanded = viewModel.hasTimers
                        viewModel.expandedScreen = .list
                        requestResize()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.trailing, 6)
                .padding(.top, 4)

                SettingsSheet {
                    viewModel.isExpanded = viewModel.hasTimers
                    viewModel.expandedScreen = .list
                    requestResize()
                }
            }
        }
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var expandedTimerList: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(viewModel.timers) { timer in
                    TimerRowView(timer: timer) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.removeTimer(timer)
                            if !viewModel.hasTimers {
                                viewModel.isExpanded = false
                            }
                            requestResize()
                        }
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Resize

    private func requestResize() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let size: NSSize
            if viewModel.isExpanded {
                switch viewModel.expandedScreen {
                case .list:
                    let h = viewModel.timers.count * 64 + 12
                    size = NSSize(width: 200, height: min(CGFloat(h), 300))
                case .addTimer:
                    size = NSSize(width: 200, height: 310)
                case .settings:
                    size = NSSize(width: 200, height: 490)
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
