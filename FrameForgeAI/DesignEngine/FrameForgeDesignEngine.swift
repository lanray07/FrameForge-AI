import Foundation
import SwiftUI

struct DesignRenderSettings: Hashable {
    var style: DesignStyle
    var padding: CGFloat
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    var backgroundName: String
    var headline: String
}

struct FrameForgeDesignEngine {
    static func settings(for style: DesignStyle, voicePrompt: String = "") -> DesignRenderSettings {
        let headline = voicePrompt.isEmpty ? "Make every screenshot look launch-ready." : voicePrompt

        switch style {
        case .minimal:
            return DesignRenderSettings(style: style, padding: 28, cornerRadius: 24, shadowRadius: 18, backgroundName: "Graphite", headline: headline)
        case .startup:
            return DesignRenderSettings(style: style, padding: 34, cornerRadius: 28, shadowRadius: 28, backgroundName: "Launch Neon", headline: headline)
        case .appleStyle:
            return DesignRenderSettings(style: style, padding: 40, cornerRadius: 32, shadowRadius: 20, backgroundName: "Keynote Glass", headline: headline)
        case .saas:
            return DesignRenderSettings(style: style, padding: 32, cornerRadius: 24, shadowRadius: 24, backgroundName: "SaaS Aurora", headline: headline)
        case .darkLuxury:
            return DesignRenderSettings(style: style, padding: 42, cornerRadius: 34, shadowRadius: 36, backgroundName: "Black Diamond", headline: headline)
        case .neon:
            return DesignRenderSettings(style: style, padding: 36, cornerRadius: 30, shadowRadius: 42, backgroundName: "Neon Pulse", headline: headline)
        case .creator:
            return DesignRenderSettings(style: style, padding: 30, cornerRadius: 26, shadowRadius: 26, backgroundName: "Creator Pop", headline: headline)
        case .appStore:
            return DesignRenderSettings(style: style, padding: 38, cornerRadius: 28, shadowRadius: 22, backgroundName: "Storefront", headline: headline)
        }
    }
}
