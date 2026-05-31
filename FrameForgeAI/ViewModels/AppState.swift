import Combine
import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case studio = "Studio"
    case assistant = "Assistant"
    case export = "Export"
    case settings = "Settings"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard:
            return "sparkles.rectangle.stack"
        case .studio:
            return "slider.horizontal.3"
        case .assistant:
            return "waveform.and.person.filled"
        case .export:
            return "square.and.arrow.up"
        case .settings:
            return "gearshape"
        }
    }
}

enum QuickAction: String, CaseIterable, Identifiable {
    case beautify = "Beautify Screenshot"
    case appStore = "App Store Generator"
    case social = "Social Post Generator"
    case device = "Device Mockup"
    case batch = "Batch Create"
    case assistant = "AI Design Assistant"
    case voice = "Voice Command"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .beautify:
            return "wand.and.stars"
        case .appStore:
            return "apps.iphone"
        case .social:
            return "megaphone"
        case .device:
            return "macbook.and.iphone"
        case .batch:
            return "square.grid.3x3"
        case .assistant:
            return "sparkles"
        case .voice:
            return "mic.circle"
        }
    }

    var subtitle: String {
        switch self {
        case .beautify:
            return "Premium one-tap compositions"
        case .appStore:
            return "Feature callouts and store sets"
        case .social:
            return "Launch cards and carousels"
        case .device:
            return "iPhone, iPad, MacBook, browser"
        case .batch:
            return "Multi-format export placeholder"
        case .assistant:
            return "Layout, hierarchy, and captions"
        case .voice:
            return "Speak prompts and design commands"
        }
    }
}

final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var selectedTab: AppTab = .dashboard
    @Published var selectedCreatorType: CreatorType = .founder
    @Published var selectedPrimaryUse: PrimaryUse = .productLaunches
    @Published var subscriptionPlan: SubscriptionPlan = .free
    @Published var lastVoicePrompt = ""

    func completeOnboarding(creatorType: CreatorType, primaryUse: PrimaryUse) {
        selectedCreatorType = creatorType
        selectedPrimaryUse = primaryUse
        hasCompletedOnboarding = true
    }

    func routeVoicePrompt(_ prompt: String, to target: VoiceCommandTarget) {
        lastVoicePrompt = prompt

        switch target {
        case .assistant:
            selectedTab = .assistant
        case .captions, .beautifier, .designStudio:
            selectedTab = .studio
        }
    }
}
