//
//  ContentView.swift
//  Animetous
//
//  Created by enes arikan on 2.12.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AnimeGeneratorViewModel()
    @StateObject private var settings = AppSettings.shared
    @StateObject private var creditsManager = CreditsManager.shared
    @State private var selectedTab = 0
    @State private var showingWelcomeBonus = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            UserProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(.purple)
        .onAppear {
            if !creditsManager.welcomeBonusClaimed {
                showingWelcomeBonus = true
            }
        }
        .sheet(isPresented: $showingWelcomeBonus) {
            WelcomeBonusView()
        }
    }
}

struct ImageCard: View {
    @ObservedObject var viewModel: AnimeGeneratorViewModel
    let image: AnimeImage
    @Binding var selectedImage: AnimeImage?
    
    var body: some View {
        if let uiImage = UIImage(data: image.imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .cornerRadius(10)
                .overlay(
                    Button(action: {
                        viewModel.toggleFavorite(for: image)
                    }) {
                        Image(systemName: image.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(image.isFavorite ? .red : .white)
                            .padding(8)
                            .background(Circle().fill(Color.black.opacity(0.6)))
                    }
                    .padding(8),
                    alignment: .topTrailing
                )
                .onTapGesture {
                    selectedImage = image
                }
        }
    }
}

struct ImageDetailView: View {
    @ObservedObject var viewModel: AnimeGeneratorViewModel
    let image: AnimeImage
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let uiImage = UIImage(data: image.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
                
                Text("Prompt: \(image.prompt)")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Text("Model: \(image.modelUsed)")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Image Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.toggleFavorite(for: image)
                        }) {
                            Label(
                                image.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: image.isFavorite ? "heart.fill" : "heart"
                            )
                        }
                        
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Delete Image", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteImage(image)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this image? This action cannot be undone.")
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

enum AnimeModel: String, CaseIterable, Identifiable {
    case stableAnimeXL = "stabilityai/sdxl-turbo"
    case stableAnime = "stabilityai/stable-diffusion-xl-base-1.0"
    case stableAnimev2 = "stabilityai/stable-diffusion-2-1-base"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .stableAnimeXL: return "SDXL Turbo"
        case .stableAnime: return "Stable Diffusion XL"
        case .stableAnimev2: return "Stable Diffusion 2.1"
        }
    }
    
    var description: String {
        switch self {
        case .stableAnimeXL: return "Ultra-fast generation with great quality"
        case .stableAnime: return "High-quality base model with excellent detail"
        case .stableAnimev2: return "Balanced model with great consistency"
        }
    }
}

struct ModelSelectionCard: View {
    let model: AnimeModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            Text(model.displayName)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(model.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 160)
        .background(isSelected ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
        )
        .onTapGesture(perform: action)
    }
}

struct ModelSelectorView: View {
    let selectedModel: AnimeModel
    let onModelSelected: (AnimeModel) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Art Style")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(AnimeModel.allCases) { model in
                        ModelSelectionCard(
                            model: model,
                            isSelected: model == selectedModel,
                            action: { onModelSelected(model) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CreditsDisplayView: View {
    @ObservedObject var creditsManager: CreditsManager
    let onPurchase: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(creditsManager.credits) Credits")
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(15)
            
            Spacer()
            
            Button(action: onPurchase) {
                Text("Get Credits")
                    .font(.subheadline.bold())
                    .foregroundColor(.purple)
            }
        }
        .padding(.horizontal)
    }
}

struct GenerateButtonView: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Generate")
                Text("(3 Credits)")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.purple : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(!isEnabled)
        .padding(.horizontal)
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: AnimeGeneratorViewModel
    @StateObject private var creditsManager = CreditsManager.shared
    @State private var selectedImage: AnimeImage?
    @State private var selectedModel: AnimeModel = .stableAnimeXL
    @State private var showingPurchaseView = false
    @State private var showingInsufficientCredits = false
    @State private var generationError: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ModelSelectorView(
                    selectedModel: selectedModel,
                    onModelSelected: { 
                        selectedModel = $0
                        viewModel.selectedModel = $0
                    }
                )
                
                CreditsDisplayView(
                    creditsManager: creditsManager,
                    onPurchase: { showingPurchaseView = true }
                )
                
                VStack(spacing: 15) {
                    TextField("Enter your prompt...", text: $viewModel.currentPrompt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    GenerateButtonView(
                        isEnabled: creditsManager.canGenerateImage() && !viewModel.currentPrompt.isEmpty && !viewModel.isLoading,
                        action: {
                            if creditsManager.canGenerateImage() {
                                Task {
                                    do {
                                        viewModel.isLoading = true
                                        // First try to generate the image
                                        let success = await viewModel.generateImage()
                                        if success {
                                            // Only deduct credits if generation was successful
                                            creditsManager.deductCreditsForGeneration()
                                        }
                                    } catch {
                                        generationError = error.localizedDescription
                                        showingError = true
                                    }
                                    viewModel.isLoading = false
                                }
                            } else {
                                showingInsufficientCredits = true
                            }
                        }
                    )
                }
                
                if viewModel.isLoading {
                    ProgressView("Generating your image...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(viewModel.images) { image in
                            ImageCard(viewModel: viewModel, image: image, selectedImage: $selectedImage)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Animetous")
            .sheet(isPresented: $showingPurchaseView) {
                PurchaseCreditsView()
            }
            .alert("Generation Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(generationError ?? "An unknown error occurred")
            }
            .alert("Insufficient Credits", isPresented: $showingInsufficientCredits) {
                Button("Cancel", role: .cancel) { }
                Button("Get Credits") {
                    showingPurchaseView = true
                }
            } message: {
                Text("You need at least 3 credits to generate an image. Would you like to purchase more credits?")
            }
            .sheet(item: $selectedImage) { image in
                ImageDetailView(viewModel: viewModel, image: image)
            }
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .bold()
                    
                    Text("Last updated: December 2024")
                        .foregroundColor(.gray)
                    
                    Text("Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information.")
                    
                    // Add more privacy policy content here
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Privacy Policy")
        }
    }
}

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.title)
                    .bold()
                
                Text("Last updated: December 2024")
                    .foregroundColor(.gray)
                
                Text("By using our app, you agree to these terms of service.")
                
                // Add more terms of service content here
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
    }
}

struct CreditsView: View {
    var body: some View {
        List {
            Section(header: Text("Development")) {
                Text("Created by Your Name")
                Text("Design by Your Designer")
            }
            
            Section(header: Text("Technologies")) {
                Text("SwiftUI")
                Text("Hugging Face API")
            }
            
            Section(header: Text("Special Thanks")) {
                Text("Open Source Contributors")
                Text("Beta Testers")
            }
        }
        .navigationTitle("Credits")
    }
}

struct SettingsView: View {
    @StateObject private var settings = AppSettings.shared
    @State private var showingPrivacyPolicy = false
    @State private var showingDeleteConfirmation = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Preferences")) {
                    Picker("Language", selection: $settings.selectedLanguage) {
                        ForEach(Language.allCases) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                    
                    Toggle("Dark Mode", isOn: $settings.isDarkMode)
                }
                
                Section(header: Text("Data Management")) {
                    Picker("Export Format", selection: $settings.selectedExportType) {
                        ForEach(ExportType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Support")) {
                    Button(action: {
                        if let url = URL(string: "mailto:hi@dainty.app") {
                            openURL(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.purple)
                            Text("Contact")
                            Spacer()
                            Text("hi@dainty.app")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Account")) {
                    Button("Delete Profile") {
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Legal")) {
                    Button("Privacy Policy") {
                        showingPrivacyPolicy = true
                    }
                    
                    NavigationLink("Terms of Service") {
                        TermsView()
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Delete Profile", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Implement delete functionality
                }
            } message: {
                Text("Are you sure you want to delete your profile? This action cannot be undone.")
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
}

#Preview {
    ContentView()
}
