import Foundation
import SwiftUI

struct AnimeImage: Identifiable, Codable {
    let id: UUID
    let prompt: String
    let imageData: Data
    let modelUsed: String
    var isFavorite: Bool
    let createdAt: Date
    
    init(id: UUID = UUID(), prompt: String, imageData: Data, modelUsed: String, isFavorite: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.prompt = prompt
        self.imageData = imageData
        self.modelUsed = modelUsed
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
}
