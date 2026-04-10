import SwiftUI

struct MainView: View {
    @Bindable var viewModel: TimerListViewModel
    @AppStorage("isDarkMode") private var isDarkMode = true

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            headerView

            Divider()
                .opacity(0.3)

            // Timer list or empty state
            if viewModel.hasTimers {
                timerListView
            } else {
                emptyStateView
            }

            // Add button
            addButtonView
        }
        .frame(minWidth: 260, idealWidth: 300, maxWidth: 400)
        .background(.ultraThinMaterial)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $viewModel.showingAddSheet) {
            AddTimerSheet(viewModel: viewModel)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsSheet()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            // App title
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.cyan)

                Text("Boost Timer")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Active timers count badge
            if viewModel.activeTimersCount > 0 {
                Text("\(viewModel.activeTimersCount)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(.cyan.opacity(0.8)))
            }

            // Settings button
            Button {
                viewModel.showingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Настройки")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "timer")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundStyle(.tertiary)

            Text("Нет активных таймеров")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)

            Text("Нажмите «+» чтобы создать")
                .font(.system(size: 11))
                .foregroundStyle(.quaternary)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(.vertical, 20)
    }

    // MARK: - Timer List

    private var timerListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.timers) { timer in
                    TimerRowView(timer: timer) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.removeTimer(timer)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Add Button

    private var addButtonView: some View {
        Button {
            viewModel.showingAddSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 14))
                Text("Новый таймер")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(.cyan)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: .command)
        .help("Создать новый таймер (⌘N)")
    }
}
