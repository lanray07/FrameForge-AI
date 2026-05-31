import PhotosUI
import SwiftUI
import UIKit

struct StudioScreen<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        ZStack {
            PremiumBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    content()
                }
                .padding(20)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DesignStudioView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedStyle: DesignStyle = .darkLuxury
    @State private var selectedGradient = "Launch Neon"
    @State private var voicePrompt = "Launch-ready visuals in seconds"

    private let columns = [
        GridItem(.adaptive(minimum: 155), spacing: 14)
    ]

    var body: some View {
        StudioScreen(title: "Design Studio") {
            VoiceInputPanel(title: "Design Command", target: .designStudio) { prompt in
                voicePrompt = prompt
                appState.routeVoicePrompt(prompt, to: .designStudio)
            }

            DesignVariationCard(title: voicePrompt, subtitle: "\(selectedStyle.rawValue) with \(selectedGradient)")

            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Mode")

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(DesignStyle.allCases) { style in
                        Button {
                            selectedStyle = style
                        } label: {
                            Text(style.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(selectedStyle == style ? Color.black : Color.white)
                                .frame(maxWidth: .infinity, minHeight: 46)
                                .background(
                                    selectedStyle == style ? Color.cyan : Color.white.opacity(0.08),
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            GradientPicker(selectedGradient: $selectedGradient)

            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Tools")

                NavigationLink {
                    ScreenshotImportView()
                } label: {
                    toolRow("Import Screenshot", systemImage: "photo.badge.plus")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    AIBeautifierView()
                } label: {
                    toolRow("AI Beautifier", systemImage: "wand.and.stars")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    CaptionAssistantView()
                } label: {
                    toolRow("Caption Assistant", systemImage: "text.quote")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DeviceMockupGeneratorView()
                } label: {
                    toolRow("Device Mockup", systemImage: "macbook.and.iphone")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toolRow(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.cyan)
                .frame(width: 42, height: 42)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.42))
        }
        .padding(16)
        .glassPanel(cornerRadius: 20)
    }
}

struct ScreenshotImportView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        StudioScreen(title: "Screenshot Import") {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                EmptyStateView(title: "Import screenshots, app screens, dashboards, and social content", systemImage: "photo.stack")
            }
            .onChange(of: selectedItem) { _, item in
                Task {
                    guard let item else {
                        selectedImageData = nil
                        return
                    }

                    selectedImageData = try? await item.loadTransferable(type: Data.self)
                }
            }

            if let selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )
            }

            EmptyStateView(title: "Batch upload and drag-and-drop are ready for the production pipeline.", systemImage: "square.grid.3x3")
        }
    }
}

struct AIBeautifierView: View {
    @State private var selectedStyle: DesignStyle = .startup
    @State private var voicePrompt = "Center the product and add premium padding"
    @State private var isGenerating = false

    var body: some View {
        StudioScreen(title: "AI Beautifier") {
            VoiceInputPanel(title: "Beautifier Prompt", target: .beautifier) { prompt in
                voicePrompt = prompt
                runMockGeneration()
            }

            DesignVariationCard(title: voicePrompt, subtitle: selectedStyle.rawValue)

            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "AI Modes")

                ForEach(DesignStyle.allCases) { style in
                    Button {
                        selectedStyle = style
                        runMockGeneration()
                    } label: {
                        HStack {
                            Text(style.rawValue)
                                .font(.headline)
                                .foregroundStyle(.white)

                            Spacer()

                            if selectedStyle == style {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.cyan)
                            }
                        }
                        .padding(16)
                        .glassPanel(cornerRadius: 18, strokeOpacity: selectedStyle == style ? 0.42 : 0.16)
                    }
                    .buttonStyle(.plain)
                }
            }

            if isGenerating {
                HStack {
                    ProgressView()
                        .tint(.cyan)
                    Text("Creating premium variations")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.72))
                }
                .padding(16)
                .glassPanel(cornerRadius: 18)
            }
        }
    }

    private func runMockGeneration() {
        isGenerating = true

        Task {
            try? await Task.sleep(nanoseconds: 650_000_000)
            await MainActor.run {
                isGenerating = false
            }
        }
    }
}

struct DeviceMockupGeneratorView: View {
    @State private var selectedDevice = "iPhone"

    var body: some View {
        StudioScreen(title: "Device Mockup") {
            DeviceMockupView(device: selectedDevice, title: "FrameForge AI")
                .frame(maxWidth: .infinity)
                .padding(20)
                .glassPanel(cornerRadius: 26)

            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Frames")

                ForEach(TemplateLibrary.deviceFrames, id: \.self) { device in
                    Button {
                        selectedDevice = device
                    } label: {
                        HStack {
                            Text(device)
                                .font(.headline)
                                .foregroundStyle(.white)

                            Spacer()

                            if selectedDevice == device {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.cyan)
                            }
                        }
                        .padding(16)
                        .glassPanel(cornerRadius: 18)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct SocialMediaGeneratorView: View {
    @State private var selectedPreset = "Portrait"

    var body: some View {
        StudioScreen(title: "Social Generator") {
            DesignVariationCard(title: "Launch card for \(selectedPreset)", subtitle: "X, LinkedIn, Instagram, Threads, Pinterest")

            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Output Size")

                ForEach(TemplateLibrary.socialPresets, id: \.self) { preset in
                    Button {
                        selectedPreset = preset
                    } label: {
                        HStack {
                            Text(preset)
                                .font(.headline)
                                .foregroundStyle(.white)

                            Spacer()

                            if selectedPreset == preset {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.cyan)
                            }
                        }
                        .padding(16)
                        .glassPanel(cornerRadius: 18)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct CaptionAssistantView: View {
    @StateObject private var viewModel = CaptionAssistantViewModel()

    var body: some View {
        StudioScreen(title: "Caption Assistant") {
            VoiceInputPanel(title: "Caption Prompt", target: .captions) { prompt in
                viewModel.prompt = prompt

                Task {
                    await viewModel.generateCaptions()
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .tint(.cyan)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassPanel(cornerRadius: 18)
            }

            ForEach(viewModel.captions, id: \.self) { caption in
                VStack(alignment: .leading, spacing: 12) {
                    Text(caption)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white)

                    HStack {
                        Button {
                            UIPasteboard.general.string = caption
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }

                        Spacer()

                        Button {
                            Task {
                                await viewModel.generateCaptions()
                            }
                        } label: {
                            Label("Regenerate", systemImage: "arrow.clockwise")
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.cyan)
                }
                .padding(16)
                .glassPanel(cornerRadius: 20)
            }
        }
    }
}

struct AppStoreBuilderView: View {
    var body: some View {
        StudioScreen(title: "App Store Builder") {
            DesignVariationCard(title: "App Store screenshot set", subtitle: "Feature callouts, headline overlays, previews")

            ForEach(["Modern", "Premium", "Gaming", "Productivity", "Finance", "AI Apps"], id: \.self) { template in
                HStack {
                    Image(systemName: "apps.iphone")
                        .foregroundStyle(.cyan)

                    Text(template)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()
                }
                .padding(16)
                .glassPanel(cornerRadius: 18)
            }
        }
    }
}

struct AIDesignAssistantView: View {
    @EnvironmentObject private var appState: AppState
    @State private var recommendations = [
        "Move the headline above the device frame.",
        "Increase screenshot scale by 12 percent.",
        "Use a calmer background for App Store exports."
    ]
    @State private var isLoading = false

    private let aiService = MockAIService()

    var body: some View {
        StudioScreen(title: "AI Assistant") {
            VoiceInputPanel(title: "Voice Assistant", target: .assistant) { prompt in
                appState.routeVoicePrompt(prompt, to: .assistant)
                generateRecommendations(from: prompt)
            }

            ForEach(recommendations, id: \.self) { recommendation in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.cyan)

                    Text(recommendation)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.82))

                    Spacer()
                }
                .padding(16)
                .glassPanel(cornerRadius: 18)
            }

            if isLoading {
                ProgressView()
                    .tint(.cyan)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassPanel(cornerRadius: 18)
            }
        }
    }

    private func generateRecommendations(from prompt: String) {
        isLoading = true

        Task {
            let response = try? await aiService.generate(
                AIRequest(
                    module: "voice_design_assistant",
                    screenshotType: prompt,
                    style: DesignStyle.darkLuxury.rawValue,
                    platform: "iOS"
                )
            )

            await MainActor.run {
                recommendations = response?.designSuggestions ?? recommendations
                isLoading = false
            }
        }
    }
}

struct ExportCenterView: View {
    var body: some View {
        StudioScreen(title: "Export Center") {
            ShareLink(item: "FrameForge AI export placeholder") {
                Label("Share Latest Export", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.cyan, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            ForEach(ExportFormat.allCases) { format in
                ExportCard(format: format, size: size(for: format))
            }

            EmptyStateView(title: "Batch export placeholder for PNG, JPG, PDF, social sizes, and App Store sizes.", systemImage: "tray.and.arrow.down")
        }
    }

    private func size(for format: ExportFormat) -> String {
        switch format {
        case .png:
            return "Transparent and full-bleed"
        case .jpg:
            return "Compressed social exports"
        case .pdf:
            return "Presentation-ready"
        case .appStore:
            return "6.7-inch, 6.5-inch, 5.5-inch"
        case .social:
            return "Square, portrait, landscape, story"
        }
    }
}

struct BrandKitView: View {
    @State private var selectedGradient = "Launch Neon"

    var body: some View {
        StudioScreen(title: "Brand Kit") {
            GradientPicker(selectedGradient: $selectedGradient)
            EmptyStateView(title: "Fonts, logos, and export presets are scaffolded for production assets.", systemImage: "paintpalette")
        }
    }
}

struct TemplateMarketplaceView: View {
    var body: some View {
        StudioScreen(title: "Marketplace") {
            ForEach(TemplateLibrary.trending) { template in
                TemplateCard(template: template)
            }
        }
    }
}

struct AnalyticsView: View {
    var body: some View {
        StudioScreen(title: "Analytics") {
            MetricPill(metric: DashboardMetric(title: "Exports Created", value: "128", systemImage: "square.and.arrow.up"))
            MetricPill(metric: DashboardMetric(title: "Templates Used", value: "34", systemImage: "rectangle.on.rectangle"))
            MetricPill(metric: DashboardMetric(title: "Content Volume", value: "7.8K", systemImage: "chart.line.uptrend.xyaxis"))
            EmptyStateView(title: "Most successful layouts placeholder is ready for backend analytics.", systemImage: "chart.bar")
        }
    }
}

struct WidgetsPlaceholderView: View {
    var body: some View {
        StudioScreen(title: "Widgets") {
            EmptyStateView(title: "Recent project, quick import, and design inspiration widgets are reserved.", systemImage: "rectangle.3.group")
        }
    }
}

struct AppleWatchPlaceholderView: View {
    var body: some View {
        StudioScreen(title: "Apple Watch") {
            EmptyStateView(title: "Export notifications and workflow reminders are ready for a watch extension.", systemImage: "applewatch")
        }
    }
}

struct BatchCreatePlaceholderView: View {
    var body: some View {
        StudioScreen(title: "Batch Create") {
            EmptyStateView(title: "Batch upload, batch beautify, and multi-size exports are scaffolded placeholders.", systemImage: "square.grid.3x3")
        }
    }
}

struct PaywallView: View {
    var body: some View {
        StudioScreen(title: "Upgrade") {
            planCard("Free", price: "GBP 0", details: "Limited exports, basic templates, watermark")
            planCard("Pro Creator", price: "GBP 9.99 monthly", details: "Unlimited exports, premium templates, App Store generator, AI assistant, voice input")
            planCard("Pro Yearly", price: "GBP 79.99 yearly", details: "Best value for creators shipping every month")
            planCard("Agency Pro", price: "GBP 29.99 monthly", details: "Brand kits, batch exports, advanced templates, white-label exports")
        }
    }

    private func planCard(_ title: String, price: String, details: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text(price)
                .font(.headline)
                .foregroundStyle(.cyan)

            Text(details)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.68))

            PrimaryGradientButton(title: "Choose \(title)", systemImage: "crown") {}
        }
        .padding(18)
        .glassPanel(cornerRadius: 24)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("voiceInputEnabled") private var voiceInputEnabled = true
    @AppStorage("mockAIEnabled") private var mockAIEnabled = true

    var body: some View {
        StudioScreen(title: "Settings") {
            Toggle("Voice Input", isOn: $voiceInputEnabled)
                .tint(.cyan)
                .padding(16)
                .glassPanel(cornerRadius: 18)

            Toggle("Mock AI", isOn: $mockAIEnabled)
                .tint(.cyan)
                .padding(16)
                .glassPanel(cornerRadius: 18)

            settingsLink("Subscription", systemImage: "crown", destination: PaywallView())
            settingsLink("Brand Kit", systemImage: "paintpalette", destination: BrandKitView())
            settingsLink("Template Marketplace", systemImage: "rectangle.on.rectangle", destination: TemplateMarketplaceView())
            settingsLink("Analytics", systemImage: "chart.line.uptrend.xyaxis", destination: AnalyticsView())
            settingsLink("Widgets", systemImage: "rectangle.3.group", destination: WidgetsPlaceholderView())
            settingsLink("Apple Watch", systemImage: "applewatch", destination: AppleWatchPlaceholderView())

            Button(role: .destructive) {
                appState.hasCompletedOnboarding = false
            } label: {
                Label("Delete All Projects", systemImage: "trash")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassPanel(cornerRadius: 18)
            }
            .buttonStyle(.plain)
        }
    }

    private func settingsLink<Destination: View>(
        _ title: String,
        systemImage: String,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .foregroundStyle(.cyan)
                    .frame(width: 30)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.42))
            }
            .padding(16)
            .glassPanel(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}
