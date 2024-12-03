import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case timeout
    case modelLoading
    case invalidImageData
    case rateLimit
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out. Please try again."
        case .modelLoading:
            return "Model is still loading. Please try again in a few seconds."
        case .invalidImageData:
            return "Failed to generate image. Please try again."
        case .rateLimit:
            return "Rate limit exceeded. Please try again in a few minutes."
        case .unauthorized:
            return "API token is invalid or expired."
        }
    }
}

class HuggingFaceService {
    static let shared = HuggingFaceService()
    private let apiToken = "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"
    private let maxRetries = 3
    
    private init() {}
    
    func generateImageWithRetry(prompt: String, model: String) async throws -> Data {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                let imageData = try await generateImage(prompt: prompt, model: model)
                return imageData
            } catch APIError.modelLoading {
                lastError = APIError.modelLoading
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(attempt) * 2_000_000_000) // Wait 2, 4, 6 seconds
                }
            } catch APIError.rateLimit {
                print("Rate limit hit on attempt \(attempt)")
                lastError = APIError.rateLimit
                break // Don't retry on rate limit
            } catch {
                print("Error on attempt \(attempt): \(error.localizedDescription)")
                lastError = error
                break
            }
        }
        
        throw lastError ?? APIError.requestFailed(NSError(domain: "Unknown error", code: -1))
    }
    
    private func generateImage(prompt: String, model: String) async throws -> Data {
        let baseURL = "https://api-inference.huggingface.co/models/\(model)"
        
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        let enhancedPrompt = """
            masterpiece, best quality, amazing quality, very detailed, \
            beautiful lighting, cinematic composition, \(prompt), \
            detailed facial features, vibrant colors
            """
        
        let parameters: [String: Any] = [
            "inputs": enhancedPrompt,
            "parameters": [
                "negative_prompt": """
                    bad quality, worst quality, low quality, low resolution, \
                    bad anatomy, bad proportions, bad perspective, \
                    ugly, duplicate, morbid, mutilated, extra fingers, \
                    mutated hands, poorly drawn hands, poorly drawn face, \
                    mutation, deformed, blurry, dehydrated, bad artifacts, \
                    text, watermark, signature, nsfw
                    """,
                "num_inference_steps": 25,
                "guidance_scale": 7.5,
                "width": 512,
                "height": 768,
                "seed": Int.random(in: 1...2147483647)
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: parameters)
        request.httpBody = jsonData
        request.timeoutInterval = 120 // 2 minutes
        
        do {
            print("Sending request to Hugging Face API...")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("Received response with status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                // Check if the response is a valid image
                if data.count < 1000 {
                    print("Received small data response: \(data.count) bytes")
                    throw APIError.invalidImageData
                }
                print("Successfully received image data: \(data.count) bytes")
                return data
                
            case 401:
                throw APIError.unauthorized
            case 429:
                throw APIError.rateLimit
            case 503:
                throw APIError.modelLoading
            default:
                throw APIError.requestFailed(NSError(domain: "Server Error", code: httpResponse.statusCode))
            }
        } catch URLError.timedOut {
            throw APIError.timeout
        } catch {
            throw APIError.requestFailed(error)
        }
    }
    
    // Helper method to check API status
    func checkAPIStatus() async -> Bool {
        do {
            let testPrompt = "test"
            _ = try await generateImage(prompt: testPrompt, model: "AnimeModel.nineties.rawValue")
            return true
        } catch {
            print("API Status Check Failed: \(error.localizedDescription)")
            return false
        }
    }
}
