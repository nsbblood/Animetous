import Foundation

enum Language: String, CaseIterable, Identifiable {
    case english = "English"
    case mandarin = "Mandarin Chinese"
    case hindi = "Hindi"
    case spanish = "Spanish"
    case french = "French"
    case arabic = "Arabic"
    case bengali = "Bengali"
    case portuguese = "Portuguese"
    case russian = "Russian"
    case urdu = "Urdu"
    case indonesian = "Indonesian"
    case german = "German"
    case japanese = "Japanese"
    case swahili = "Swahili"
    case marathi = "Marathi"
    case telugu = "Telugu"
    case turkish = "Turkish"
    case tamil = "Tamil"
    case vietnamese = "Vietnamese"
    case korean = "Korean"
    
    var id: String { self.rawValue }
}

enum ExportType: String, CaseIterable, Identifiable {
    case jpeg = "JPEG"
    case png = "PNG"
    case heic = "HEIC"
    
    var id: String { self.rawValue }
}

class AppSettings: ObservableObject {
    @Published var selectedLanguage: Language = .english
    @Published var selectedExportType: ExportType = .jpeg
    @Published var isDarkMode: Bool = false
    
    static let shared = AppSettings()
    
    private init() {
        // Load saved settings here if needed
    }
}
