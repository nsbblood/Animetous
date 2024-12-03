import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: AnimeGeneratorViewModel
    @StateObject private var creditsManager = CreditsManager.shared
    @State private var selectedSegment = 0
    @State private var selectedImage: AnimeImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Credits Display
                    VStack {
                        Text("\(creditsManager.credits)")
                            .font(.system(size: 48, weight: .bold))
                        Text("Credits Available")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Free Claim Section
                    FreeClaimView(creditsManager: creditsManager)
                    
                    // Generated Images Section
                    Picker("View", selection: $selectedSegment) {
                        Text("Recent").tag(0)
                        Text("Favorites").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(selectedSegment == 0 ? viewModel.images : viewModel.favoriteImages) { image in
                            ImageCard(viewModel: viewModel, image: image, selectedImage: $selectedImage)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(item: $selectedImage) { image in
                ImageDetailView(viewModel: viewModel, image: image)
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(viewModel: AnimeGeneratorViewModel())
    }
}
