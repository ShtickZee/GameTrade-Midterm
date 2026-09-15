import SwiftUI

struct EditProfileView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var profileImage: UIImage? = nil
    
    // Use @State for local editing, then commit to appState on save
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""
    
    init(appState: AppState) {
        self.appState = appState
        // Initialize state from appState
        _name = State(initialValue: appState.userName)
        _username = State(initialValue: appState.userHandle.replacingOccurrences(of: "@", with: ""))
        _email = State(initialValue: appState.userEmail)
        _phone = State(initialValue: appState.userPhone)
        _location = State(initialValue: appState.userLocation)
        _bio = State(initialValue: appState.userBio)
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
                            .overlay(Text(String(name.prefix(1))).font(.title).foregroundColor(.purple))
                            .overlay(Circle().stroke(Color.purple, lineWidth: 2))
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .onTapGesture {
                    appState.showingImagePicker = true
                }
            }
            
            Section(header: Text("Account Details").foregroundColor(.purple)) {
                LabeledTextField(label: "Username", text: $username)
                LabeledTextField(label: "Full Name", text: $name)
                LabeledTextField(label: "Email", text: $email)
                LabeledTextField(label: "Phone Number", text: $phone)
            }
            
            Section(header: Text("Profile Info").foregroundColor(.purple)) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                }
                LabeledTextField(label: "Location", text: $location)
            }
        }
        .navigationTitle("Edit Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Save to AppState
                    appState.userName = name
                    appState.userHandle = "@\(username)"
                    appState.userEmail = email
                    appState.userPhone = phone
                    appState.userLocation = location
                    appState.userBio = bio
                    
                    dismiss()
                }
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
