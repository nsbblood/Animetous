import SwiftUI

struct WelcomeBonusView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var creditsManager = CreditsManager.shared
    @State private var showingAnimation = false
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
                .scaleEffect(showingAnimation ? 1.1 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: showingAnimation
                )
            
            Text("Welcome to Animetous!")
                .font(.title)
                .bold()
            
            Text("Here's your welcome bonus")
                .font(.title2)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("20 FREE CREDITS")
                    .font(.title3.bold())
                    .foregroundColor(.purple)
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(15)
            
            Text("Generate amazing anime art with your free credits")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                creditsManager.claimWelcomeBonus()
                dismiss()
            }) {
                Text("Claim Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.top)
        }
        .padding()
        .onAppear {
            showingAnimation = true
        }
    }
}
