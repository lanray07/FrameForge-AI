import Foundation

struct AIRequest: Codable {
    let module: String
    let screenshotType: String
    let style: String
    let platform: String
}

struct AIResponse: Codable {
    let designSuggestions: [String]
    let captions: [String]
    let variations: [String]
}

protocol FrameForgeAIProviding {
    func generate(_ request: AIRequest) async throws -> AIResponse
}

struct MockAIService: FrameForgeAIProviding {
    func generate(_ request: AIRequest) async throws -> AIResponse {
        try await Task.sleep(nanoseconds: 350_000_000)

        return AIResponse(
            designSuggestions: [
                "Use a larger hero crop with soft neon edge light.",
                "Add a concise headline above the device frame.",
                "Increase padding and place the CTA in the lower third."
            ],
            captions: [
                "We turned a simple screenshot into a launch-ready visual.",
                "The product story is sharper when the screenshot looks premium.",
                "Ship the update, share the story, and make the first impression count."
            ],
            variations: [
                "\(request.style) hero layout",
                "\(request.style) carousel cover",
                "\(request.style) App Store frame"
            ]
        )
    }
}

struct RemoteAIService: FrameForgeAIProviding {
    var endpoint = URL(string: "https://YOUR_BACKEND_URL.com/frameforge-ai")!

    func generate(_ requestBody: AIRequest) async throws -> AIResponse {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(AIResponse.self, from: data)
    }
}
