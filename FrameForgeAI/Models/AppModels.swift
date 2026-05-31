import Foundation
import SwiftData

enum CreatorType: String, CaseIterable, Identifiable {
    case founder = "Founder"
    case appDeveloper = "App Developer"
    case creator = "Creator"
    case marketer = "Marketer"
    case agency = "Agency"
    case designer = "Designer"

    var id: String { rawValue }
}

enum PrimaryUse: String, CaseIterable, Identifiable {
    case appStoreScreenshots = "App Store Screenshots"
    case socialMedia = "Social Media"
    case productLaunches = "Product Launches"
    case websites = "Websites"
    case clientWork = "Client Work"
    case courseContent = "Course Content"

    var id: String { rawValue }
}

enum DesignStyle: String, CaseIterable, Identifiable {
    case minimal = "Minimal"
    case startup = "Startup"
    case appleStyle = "Apple Style"
    case saas = "SaaS"
    case darkLuxury = "Dark Luxury"
    case neon = "Neon"
    case creator = "Creator"
    case appStore = "App Store"

    var id: String { rawValue }
}

enum ScreenshotType: String, CaseIterable, Identifiable {
    case appScreenshot = "App Screenshot"
    case webScreenshot = "Web Screenshot"
    case dashboard = "Dashboard"
    case socialContent = "Social Content"
    case productMockup = "Product Mockup"

    var id: String { rawValue }
}

enum ExportFormat: String, CaseIterable, Identifiable {
    case png = "PNG"
    case jpg = "JPG"
    case pdf = "PDF"
    case appStore = "App Store Set"
    case social = "Social Sizes"

    var id: String { rawValue }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case free = "Free"
    case proCreator = "Pro Creator"
    case agencyPro = "Agency Pro"

    var id: String { rawValue }
}

enum VoiceCommandTarget: String, CaseIterable, Identifiable {
    case assistant = "AI Assistant"
    case captions = "Captions"
    case beautifier = "Beautifier"
    case designStudio = "Design Studio"

    var id: String { rawValue }
}

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var creatorType: String
    var primaryUse: String
    var createdAt: Date
    var voiceInputEnabled: Bool

    init(
        id: UUID = UUID(),
        creatorType: String,
        primaryUse: String,
        createdAt: Date = .now,
        voiceInputEnabled: Bool = true
    ) {
        self.id = id
        self.creatorType = creatorType
        self.primaryUse = primaryUse
        self.createdAt = createdAt
        self.voiceInputEnabled = voiceInputEnabled
    }
}

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var title: String
    var screenshotCount: Int
    var templateUsed: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        screenshotCount: Int,
        templateUsed: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.screenshotCount = screenshotCount
        self.templateUsed = templateUsed
        self.createdAt = createdAt
    }
}

@Model
final class ImportedScreenshot {
    @Attribute(.unique) var id: UUID
    @Attribute(.externalStorage) var imageData: Data?
    var createdAt: Date

    init(id: UUID = UUID(), imageData: Data? = nil, createdAt: Date = .now) {
        self.id = id
        self.imageData = imageData
        self.createdAt = createdAt
    }
}

@Model
final class DesignVariation {
    @Attribute(.unique) var id: UUID
    var projectId: UUID
    var style: String
    var settings: String
    var voicePrompt: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        projectId: UUID,
        style: String,
        settings: String,
        voicePrompt: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.projectId = projectId
        self.style = style
        self.settings = settings
        self.voicePrompt = voicePrompt
        self.createdAt = createdAt
    }
}

@Model
final class BrandKit {
    @Attribute(.unique) var id: UUID
    var colors: [String]
    var logoPlaceholder: String
    var exportPreferences: String

    init(
        id: UUID = UUID(),
        colors: [String] = ["#7C3AED", "#06B6D4", "#F97316"],
        logoPlaceholder: String = "Logo Placeholder",
        exportPreferences: String = "PNG, social sizes, transparent safe area"
    ) {
        self.id = id
        self.colors = colors
        self.logoPlaceholder = logoPlaceholder
        self.exportPreferences = exportPreferences
    }
}

@Model
final class ExportRecord {
    @Attribute(.unique) var id: UUID
    var format: String
    var size: String
    var createdAt: Date

    init(id: UUID = UUID(), format: String, size: String, createdAt: Date = .now) {
        self.id = id
        self.format = format
        self.size = size
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var plan: String
    var isActive: Bool

    init(id: UUID = UUID(), plan: String = SubscriptionPlan.free.rawValue, isActive: Bool = false) {
        self.id = id
        self.plan = plan
        self.isActive = isActive
    }
}
