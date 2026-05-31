import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 155), spacing: 14)
    ]

    var body: some View {
        ZStack {
            PremiumBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.metrics) { metric in
                            MetricPill(metric: metric)
                        }
                    }

                    quickActions
                    recentProjects
                    templates
                    aiSuggestions
                }
                .padding(20)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.refreshSuggestions()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(appState.selectedCreatorType.rawValue)
                .font(.caption.weight(.bold))
                .foregroundStyle(.cyan)
                .textCase(.uppercase)

            Text("Your launch-ready screenshot studio")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            Text(appState.selectedPrimaryUse.rawValue)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.62))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Quick Actions")

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(QuickAction.allCases) { action in
                    NavigationLink {
                        destination(for: action)
                    } label: {
                        QuickActionTile(action: action)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var recentProjects: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Recent Projects", trailing: "Offline-ready")

            ForEach(viewModel.recentProjects) { project in
                ProjectCard(project: project)
            }
        }
    }

    private var templates: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Trending Templates")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(TemplateLibrary.trending) { template in
                        TemplateCard(template: template)
                    }
                }
            }
        }
    }

    private var aiSuggestions: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "AI Suggestions")

            ForEach(viewModel.suggestions, id: \.self) { suggestion in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.cyan)

                    Text(suggestion)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))

                    Spacer()
                }
                .padding(16)
                .glassPanel(cornerRadius: 18)
            }
        }
    }

    @ViewBuilder
    private func destination(for action: QuickAction) -> some View {
        switch action {
        case .beautify:
            AIBeautifierView()
        case .appStore:
            AppStoreBuilderView()
        case .social:
            SocialMediaGeneratorView()
        case .device:
            DeviceMockupGeneratorView()
        case .batch:
            BatchCreatePlaceholderView()
        case .assistant, .voice:
            AIDesignAssistantView()
        }
    }
}
