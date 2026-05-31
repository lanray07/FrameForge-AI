import AVFoundation
import Combine
import Foundation
import Speech

enum SpeechInputError: LocalizedError {
    case recognizerUnavailable
    case permissionDenied
    case requestCreationFailed

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            return "Speech recognition is unavailable on this device."
        case .permissionDenied:
            return "Microphone and speech recognition permissions are required."
        case .requestCreationFailed:
            return "Unable to start a speech recognition request."
        }
    }
}

final class SpeechRecognizerService: NSObject, ObservableObject {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var microphoneGranted = false
    @Published var errorMessage: String?

    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isTapInstalled = false

    init(locale: Locale = Locale(identifier: "en_US")) {
        recognizer = SFSpeechRecognizer(locale: locale)
        super.init()
        recognizer?.delegate = self
    }

    var canRecord: Bool {
        authorizationStatus == .authorized && microphoneGranted && recognizer?.isAvailable == true
    }

    @MainActor
    func requestAuthorization() async {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        let micGranted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        authorizationStatus = speechStatus
        microphoneGranted = micGranted

        if speechStatus != .authorized || !micGranted {
            errorMessage = SpeechInputError.permissionDenied.localizedDescription
        }
    }

    @MainActor
    func toggleRecording() async {
        if isRecording {
            stopRecording()
            return
        }

        if authorizationStatus != .authorized || !microphoneGranted {
            await requestAuthorization()
        }

        do {
            try startRecording()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func startRecording() throws {
        guard recognizer?.isAvailable == true else {
            throw SpeechInputError.recognizerUnavailable
        }

        guard authorizationStatus == .authorized && microphoneGranted else {
            throw SpeechInputError.permissionDenied
        }

        recognitionTask?.cancel()
        recognitionTask = nil
        transcript = ""
        errorMessage = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        if isTapInstalled {
            inputNode.removeTap(onBus: 0)
            isTapInstalled = false
        }
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        isTapInstalled = true

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }

            if error != nil || result?.isFinal == true {
                Task { @MainActor in
                    self.stopRecording()
                }
            }
        }
    }

    @MainActor
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }

        if isTapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            isTapInstalled = false
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isRecording = false
    }
}

extension SpeechRecognizerService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            if !available {
                self.errorMessage = SpeechInputError.recognizerUnavailable.localizedDescription
            }
        }
    }
}
