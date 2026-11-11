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
    @State private var errorMessage = ""

    private var avatarInitial: String {
        if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return String(name.prefix(1)).uppercased()
        } else if !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return String(username.prefix(1)).uppercased()
        }
        return "?"
    }

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
                            Text(avatarInitial)
                                .font(.system(size: 40, weight: .bold))
                                .frame(width: 100, height: 100)
                                .background(Color.purple.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
            }

            Section("Public Profile Information") {
                TextField("Full Name (Optional)", text: $name)
                TextField("Username (Required)", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Bio", text: $bio, axis: .vertical)
                    .lineLimit(3...5)
            }

            Section(
                header: Text("Private Contact & Location"),
                footer: Text("Your phone number and exact location are encrypted and stored privately. Other traders only see your general city/region.")
            ) {
                TextField("Location (e.g., Makati)", text: $location)
                TextField("Phone Number", text: $phone)
                    .keyboardType(.phonePad)
            }

            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Button {
                errorMessage = ""
                appState.saveUserProfileToFirebase(
                    name: name,
                    username: username,
                    phone: phone,
                    rawLocation: location,
                    bio: bio,
                    selectedImage: selectedImage
                ) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        appState.shouldSetupProfile = false
                        appState.isAuthenticated = true
                        appState.onboarded = false // Redirects to onboarding
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    if appState.isSavingProfile {
                        ProgressView()
                            .padding(.trailing, 8)
                    }
                    Text(appState.isSavingProfile ? "Securing Account..." : "Finish Signing Up")
                        .bold()
                    Spacer()
                }
            }
            .disabled(
                username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                appState.isSavingProfile
            )
        }
        .navigationTitle("Setup Profile")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
    }
}
