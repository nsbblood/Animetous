import SwiftUI

@MainActor
class AnimeGeneratorViewModel: ObservableObject {
    @Published var currentPrompt = ""
    @Published var selectedModel: AnimeModel = .stableAnimeXL
    @Published var images: [AnimeImage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let huggingFaceService = HuggingFaceService.shared
    
    func generateImage() async -> Bool {
        guard !currentPrompt.isEmpty else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let imageData = try await huggingFaceService.generateImageWithRetry(
                prompt: currentPrompt,
                model: selectedModel.rawValue
            )
            
            // Verify we got valid image data
            guard imageData.count > 1000 else {
                errorMessage = "Invalid image data received"
                return false
            }
            
            // Create and add the new image
            let newImage = AnimeImage(
                prompt: currentPrompt,
                imageData: imageData,
                modelUsed: selectedModel.rawValue
            )
            images.insert(newImage, at: 0)
            currentPrompt = ""
            return true
            
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
            return false
        }
    }
    
    func toggleFavorite(for image: AnimeImage) {
        if let index = images.firstIndex(where: { $0.id == image.id }) {
            images[index].isFavorite.toggle()
        }
    }
    
    func deleteImage(_ image: AnimeImage) {
        images.removeAll { $0.id == image.id }
    }
    
    var favoriteImages: [AnimeImage] {
        images.filter { $0.isFavorite }
    }
}
