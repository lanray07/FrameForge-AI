# FrameForge AI

FrameForge AI is a premium SwiftUI screenshot design studio for social assets, App Store screenshots, device mockups, launch graphics, caption generation, and export workflows.

## Voice Input Technology

Voice input is included as a first-class feature:

- `SpeechRecognizerService` uses Apple's Speech and AVFoundation frameworks.
- `VoiceInputPanel` provides reusable microphone input for AI prompts.
- Voice prompts feed the AI assistant, caption assistant, beautifier, and design studio.
- `Info.plist` includes microphone and speech-recognition permission strings.
- `UserProfile` and `DesignVariation` include voice-related fields for persistence.

Mock AI is enabled by default through `MockAIService`. `RemoteAIService` is scaffolded for `POST https://YOUR_BACKEND_URL.com/frameforge-ai`.
