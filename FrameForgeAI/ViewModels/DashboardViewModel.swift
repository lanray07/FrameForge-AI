import Combine
import Foundation

struct DashboardProject: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let template: String
}

struct DashboardMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

final class DashboardViewModel: ObservableObject {
    @Published var recentProjects: [DashboardProject] = [
        DashboardProject(title: "Launch Week Kit", subtitle: "6 screenshots", template: "Dark Luxury"),
        DashboardProject(title: "App Store Preview", subtitle: "5.5-inch and 6.7-inch", template: "Apple Style"),
        DashboardProject(title: "Founder Update", subtitle: "LinkedIn carousel", template: "Startup")
    ]

    @Published var metrics: [DashboardMetric] = [
        DashboardMetric(title: "Exports", value: "128", systemImage: "square.and.arrow.up"),
        DashboardMetric(title: "Templates", value: "34", systemImage: "rectangle.on.rectangle"),
        DashboardMetric(title: "Voice Prompts", value: "12", systemImage: "mic")
    ]

    @Published var suggestions: [String] = [
        "Turn your latest dashboard into a launch card.",
        "Create an App Store before and after set.",
        "Try a voice prompt for faster caption generation."
    ]

    private let aiService: FrameForgeAIProviding

    init(aiService: FrameForgeAIProviding = MockAIService()) {
        self.aiService = aiService
    }

    func refreshSuggestions() {
        Task {
            do {
                let response = try await aiService.generate(
                    AIRequest(
                        module: "dashboard",
                        screenshotType: ScreenshotType.dashboard.rawValue,
                        style: DesignStyle.startup.rawValue,
                        platform: "iOS"
                    )
                )

                await MainActor.run {
                    suggestions = response.designSuggestions
                }
            } catch {
                await MainActor.run {
                    suggestions = ["Mock AI is ready. Add a screenshot to unlock tailored ideas."]
                }
            }
        }
    }
}

final class CaptionAssistantViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var captions: [String] = [
        "We rebuilt the screenshot workflow for launch-day speed.",
        "Your product deserves visuals that look ready before the post goes live.",
        "From raw capture to premium launch asset in seconds."
    ]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let aiService: FrameForgeAIProviding

    init(aiService: FrameForgeAIProviding = MockAIService()) {
        self.aiService = aiService
    }

    @MainActor
    func generateCaptions() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await aiService.generate(
                AIRequest(
                    module: "caption_assistant",
                    screenshotType: prompt.isEmpty ? "product" : prompt,
                    style: DesignStyle.startup.rawValue,
                    platform: "social"
                )
            )
            captions = response.captions
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
