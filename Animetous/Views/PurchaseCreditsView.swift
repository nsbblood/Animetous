import SwiftUI
import StoreKit

struct PurchaseCreditsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var creditsManager = CreditsManager.shared
    @State private var selectedPackage: CreditPackage?
    @State private var showingPurchaseError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Balance
                    VStack {
                        Text("Current Balance")
                            .font(.headline)
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(creditsManager.credits) Credits")
                                .font(.title2.bold())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Credit Packages
                    VStack(spacing: 15) {
                        ForEach(CreditPackage.allCases) { package in
                            Button(action: {
                                selectedPackage = package
                                // Here you would implement the actual purchase logic
                                // using StoreKit
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(package.displayName)
                                            .font(.headline)
                                        Text("\(package.credits) Credits")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$\(String(format: "%.2f", package.price as NSDecimalNumber)))")
                                        .font(.title3.bold())
                                        .foregroundColor(.purple)
                                }
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Info Section
                    VStack(spacing: 10) {
                        InfoRow(icon: "star.fill", text: "3 credits per image generation")
                        InfoRow(icon: "checkmark.circle.fill", text: "High-quality AI models")
                        InfoRow(icon: "arrow.triangle.2.circlepath", text: "Credits never expire")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Get Credits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Purchase Error", isPresented: $showingPurchaseError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(text)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
