import SwiftData
import SwiftUI

@main
struct FrameForgeAIApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var speechService = SpeechRecognizerService()
    @StateObject private var subscriptionService = SubscriptionService()

    private let modelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Project.self,
            ImportedScreenshot.self,
            DesignVariation.self,
            BrandKit.self,
            ExportRecord.self,
            SubscriptionState.self
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create FrameForge AI model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(speechService)
                .environmentObject(subscriptionService)
                .modelContainer(modelContainer)
        }
    }
}
