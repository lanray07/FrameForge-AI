import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label(AppTab.dashboard.rawValue, systemImage: AppTab.dashboard.systemImage)
            }
            .tag(AppTab.dashboard)

            NavigationStack {
                DesignStudioView()
            }
            .tabItem {
                Label(AppTab.studio.rawValue, systemImage: AppTab.studio.systemImage)
            }
            .tag(AppTab.studio)

            NavigationStack {
                AIDesignAssistantView()
            }
            .tabItem {
                Label(AppTab.assistant.rawValue, systemImage: AppTab.assistant.systemImage)
            }
            .tag(AppTab.assistant)

            NavigationStack {
                ExportCenterView()
            }
            .tabItem {
                Label(AppTab.export.rawValue, systemImage: AppTab.export.systemImage)
            }
            .tag(AppTab.export)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(AppTab.settings.rawValue, systemImage: AppTab.settings.systemImage)
            }
            .tag(AppTab.settings)
        }
        .tint(.cyan)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(SpeechRecognizerService())
}
