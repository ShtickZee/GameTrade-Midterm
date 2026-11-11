import SwiftUI

struct EditProfileView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var profileImage: UIImage? = nil

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""
    @State private var errorMessage: String = ""

    init(appState: AppState) {
        self.appState = appState
        _name = State(initialValue: appState.userName)
        _username = State(initialValue: appState.userHandle.replacingOccurrences(of: "@", with: ""))
        _email = State(initialValue: appState.userEmail)
        _phone = State(initialValue: appState.userPhone)
        _location = State(initialValue: appState.userLocation)
        _bio = State(initialValue: appState.userBio)
        _profileImage = State(initialValue: appState.profileImage)
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.purple, lineWidth: 2))
                    } else {
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String((name.isEmpty ? username : name).prefix(1)).uppercased())
                                    .font(.title)
                                    .foregroundColor(.purple)
                            )
                            .overlay(Circle().stroke(Color.purple, lineWidth: 2))
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .onTapGesture {
                    appState.showingImagePicker = true
                }
            }

            Section(header: Text("Public Profile").foregroundColor(.purple)) {
                LabeledTextField(label: "Username", text: $username)
                LabeledTextField(label: "Full Name (Optional)", text: $name)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                }
            }

            Section(
                header: Text("Private Vault (Only Visible to You)").foregroundColor(.purple),
                footer: Text("Your exact location, phone number, and email are stored in your private Firestore vault.")
            ) {
                LabeledTextField(label: "Email", text: $email)
                    .disabled(true)
                LabeledTextField(label: "Phone Number", text: $phone)
                LabeledTextField(label: "Exact Location", text: $location)
            }

            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(appState.isSavingProfile ? "Saving..." : "Save") {
                    errorMessage = ""
                    appState.saveUserProfileToFirebase(
                        name: name,
                        username: username,
                        phone: phone,
                        rawLocation: location,
                        bio: bio,
                        selectedImage: profileImage
                    ) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                        } else {
                            appState.showToast("Profile securely updated")
                            dismiss()
                        }
                    }
                }
                .disabled(appState.isSavingProfile || username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .foregroundColor(.purple)
            }
        }
        .sheet(isPresented: $appState.showingImagePicker) {
            ImagePicker(selectedImage: $profileImage, sourceType: .photoLibrary)
        }
    }
}

struct LabeledTextField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            TextField(label, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 4)
    }
}
