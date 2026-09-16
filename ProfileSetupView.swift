import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var username = ""
    @State private var location = ""
    @State private var phone = ""
    @State private var bio = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        Form {
            Section("Profile Photo") {
                HStack {
                    Spacer()
                    Button {
                        showingImagePicker = true
                    } label: {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Text(name.isEmpty ? "?" : String(name.prefix(1)))
                                .font(.system(size: 40, weight: .bold))
                                .frame(width: 100, height: 100)
                                .background(Color.purple.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
            }
            
            Section("Basic Information") {
                TextField("Full Name", text: $name)
                TextField("Username", text: $username)
                TextField("Location", text: $location)
                TextField("Phone", text: $phone)
                TextField("Bio", text: $bio, axis: .vertical)
                    .lineLimit(3...5)
            }
            
            Button("Finish Signing Up") {
                appState.userName = name
                appState.userHandle = "@\(username)"
                appState.userLocation = location
                appState.userPhone = phone
                appState.userBio = bio
                appState.profileImage = selectedImage
                
                // Finalize setup
                appState.shouldSetupProfile = false
                appState.isAuthenticated = true
                appState.onboarded = false // Redirects to onboarding
            }
            .disabled(name.isEmpty || username.isEmpty)
        }
        .navigationTitle("Setup Profile")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
    }
}
