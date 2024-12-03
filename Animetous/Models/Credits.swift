import Foundation
import StoreKit

enum CreditPackage: String, CaseIterable, Identifiable {
    case small = "com.animetous.credits.50"
    case medium = "com.animetous.credits.100"
    case large = "com.animetous.credits.250"
    case xl = "com.animetous.credits.500"
    
    var id: String { rawValue }
    
    var credits: Int {
        switch self {
        case .small: return 50
        case .medium: return 100
        case .large: return 250
        case .xl: return 500
        }
    }
    
    var price: Decimal {
        switch self {
        case .small: return 1.99
        case .medium: return 3.99
        case .large: return 7.99
        case .xl: return 14.99
        }
    }
    
    var displayName: String {
        switch self {
        case .small: return "Starter Pack"
        case .medium: return "Popular Pack"
        case .large: return "Pro Pack"
        case .xl: return "Ultimate Pack"
        }
    }
}

class CreditsManager: ObservableObject {
    static let shared = CreditsManager()
    
    private let userDefaults = UserDefaults.standard
    private let creditsKey = "userCredits"
    private let welcomeBonusClaimedKey = "welcomeBonusClaimed"
    private let lastFreeClaimKey = "lastFreeClaim"
    
    @Published var credits: Int {
        didSet {
            userDefaults.set(credits, forKey: creditsKey)
        }
    }
    
    @Published var welcomeBonusClaimed: Bool {
        didSet {
            userDefaults.set(welcomeBonusClaimed, forKey: welcomeBonusClaimedKey)
        }
    }
    
    private init() {
        self.credits = userDefaults.integer(forKey: creditsKey)
        self.welcomeBonusClaimed = userDefaults.bool(forKey: welcomeBonusClaimedKey)
        if !welcomeBonusClaimed {
            claimWelcomeBonus()
        }
    }
    
    func canGenerateImage() -> Bool {
        return credits >= 3
    }
    
    func deductCreditsForGeneration() {
        if canGenerateImage() {
            credits -= 3
        }
    }
    
    func addCredits(_ amount: Int) {
        credits += amount
    }
    
    func claimWelcomeBonus() {
        guard !welcomeBonusClaimed else { return }
        credits += 20
        welcomeBonusClaimed = true
    }
    
    // Free claim methods
    func canClaimFreeCredits() -> Bool {
        let lastClaim = userDefaults.object(forKey: lastFreeClaimKey) as? Date ?? .distantPast
        return Date().timeIntervalSince(lastClaim) >= 24 * 3600 // 24 hours
    }
    
    func timeUntilNextClaim() -> TimeInterval {
        let lastClaim = userDefaults.object(forKey: lastFreeClaimKey) as? Date ?? .distantPast
        let nextClaimTime = lastClaim.addingTimeInterval(24 * 3600)
        return max(0, nextClaimTime.timeIntervalSinceNow)
    }
    
    func claimFreeCredits() {
        guard canClaimFreeCredits() else { return }
        credits += 6
        userDefaults.set(Date(), forKey: lastFreeClaimKey)
    }
}
