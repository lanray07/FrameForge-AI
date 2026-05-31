import Foundation

enum TemplateCategory: String, CaseIterable, Identifiable {
    case saas = "SaaS"
    case mobileApps = "Mobile Apps"
    case aiStartups = "AI Startups"
    case creators = "Creators"
    case agencies = "Agencies"
    case ecommerce = "Ecommerce"

    var id: String { rawValue }
}

struct FrameForgeTemplate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: TemplateCategory
    let style: DesignStyle
    let output: String
}

struct TemplateLibrary {
    static let trending: [FrameForgeTemplate] = [
        FrameForgeTemplate(name: "Launch Hero", category: .aiStartups, style: .startup, output: "X/Twitter landscape"),
        FrameForgeTemplate(name: "Luxury App Store", category: .mobileApps, style: .darkLuxury, output: "App Store set"),
        FrameForgeTemplate(name: "Founder Carousel", category: .creators, style: .creator, output: "LinkedIn carousel"),
        FrameForgeTemplate(name: "SaaS Proof", category: .saas, style: .saas, output: "Website mockup"),
        FrameForgeTemplate(name: "Agency Client Win", category: .agencies, style: .appleStyle, output: "Presentation slide")
    ]

    static let socialPresets = ["Square", "Portrait", "Landscape", "Story", "Carousel"]
    static let deviceFrames = ["iPhone", "iPad", "MacBook", "Desktop", "Apple Watch", "Browser"]
}
