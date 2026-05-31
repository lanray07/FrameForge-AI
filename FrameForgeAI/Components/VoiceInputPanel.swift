import SwiftUI

struct VoiceInputPanel: View {
    @EnvironmentObject private var speechService: SpeechRecognizerService

    let title: String
    let target: VoiceCommandTarget
    let onCommit: (String) -> Void

    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Button {
                    Task {
                        await speechService.toggleRecording()
                    }
                } label: {
                    Image(systemName: speechService.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(speechService.isRecording ? Color.orange : Color.cyan)
                        .frame(width: 52, height: 52)
                        .background(Color.white.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(speechService.isRecording ? "Stop voice input" : "Start voice input")

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(target.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(speechService.isRecording ? Color.orange : Color.cyan)
                }

                Spacer()

                if speechService.isRecording {
                    ProgressView()
                        .tint(.orange)
                }
            }

            TextEditor(text: $draft)
                .font(.body)
                .foregroundStyle(.white)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 92)
                .padding(12)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if draft.isEmpty {
                        Text("Describe the visual, caption, or design change")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.34))
                            .padding(.horizontal, 17)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }

            if let message = speechService.errorMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            PrimaryGradientButton(title: "Apply Voice Prompt", systemImage: "sparkles") {
                let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                onCommit(trimmed)
            }
        }
        .padding(18)
        .glassPanel(cornerRadius: 24)
        .onChange(of: speechService.transcript) { _, newValue in
            draft = newValue
        }
    }
}
