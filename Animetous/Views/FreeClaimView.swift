import SwiftUI

struct FreeClaimView: View {
    @ObservedObject var creditsManager: CreditsManager
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Daily Free Credits")
                .font(.headline)
            
            if creditsManager.canClaimFreeCredits() {
                Button(action: {
                    creditsManager.claimFreeCredits()
                    timeRemaining = creditsManager.timeUntilNextClaim()
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Claim 6 Free Credits!")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                VStack(spacing: 8) {
                    Text("Next claim available in:")
                        .foregroundColor(.secondary)
                    
                    Text(timeString(from: timeRemaining))
                        .font(.title2.monospacedDigit())
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
        .onAppear {
            timeRemaining = creditsManager.timeUntilNextClaim()
        }
        .onReceive(timer) { _ in
            timeRemaining = creditsManager.timeUntilNextClaim()
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    FreeClaimView(creditsManager: CreditsManager.shared)
}
