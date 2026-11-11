# Phase 1 & 2 Swift Code & Security Rules (`GameTrade-Midterm`)

---

## Section 1: Create `midterm/SecurityUtils.swift`

```swift
import Foundation
import CryptoKit

enum SecurityUtils {
    /// Generates a lowercase SHA-256 hex digest using Apple's native CryptoKit.
    /// Used for creating irreversible lookup hashes of normalized emails and phone numbers.
    static func sha256(_ input: String) -> String {
        let normalized = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let data = Data(normalized.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Normalizes a phone number to digits and leading '+' before hashing.
    static func normalizePhone(_ phone: String) -> String {
        let allowed = CharacterSet(charactersIn: "+0123456789")
        return phone.unicodeScalars.filter { allowed.contains($0) }.map(String.init).joined()
    }

    /// Extracts only a coarse city/region label for public display so exact street addresses
    /// or private coordinates are never exposed on public listings or profiles.
    /// Example: "123 Ayala Ave, Makati, Metro Manila" -> "Makati, Metro Manila"
    static func extractCoarseLocation(from rawLocation: String) -> String {
        let trimmed = rawLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Undisclosed" }
        
        let parts = trimmed
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if parts.count >= 2 {
            return parts.suffix(2).joined(separator: ", ")
        }
        return parts.first ?? "Undisclosed"
    }
}
```

---

## Section 2: Update `midterm/Models.swift`

Replace the contents of `midterm/Models.swift` with the following (preserves all existing models while adding the Firestore User models):

```swift
import Foundation

enum Platform: String, Codable {
    case ps5 = "PS5"
    case ps4 = "PS4"
    case xbox = "XBOX"
    case switchConsole = "SWITCH"
}

enum Condition: String, Codable {
    case likeNew = "Like New"
    case good = "Good"
    case fair = "Fair"
    case forParts = "For Parts"
}

struct Listing: Identifiable, Codable {
    let id: String
    var title: String
    var price: Double
    var was: Double?
    var platform: Platform
    var condition: Condition
    var sellerID: String
    var sellerName: String
    var sellerAvatar: String
    var sellerRating: Double
    var isVerified: Bool
    var location: String
    var saved: Bool
    var bundle: String?
    var images: [String]
    var description: String
}

struct Seller: Identifiable, Codable {
    let id: String
    let name: String
    let handle: String?
    let rating: Double
    let reviews: Int
    let verified: Bool
    let officialStore: Bool
    let topSeller: Bool
    let listingsCount: Int
    let soldCount: Int
    let responseTime: String?
    let avatar: String?
}

struct Review: Identifiable, Codable {
    var id = UUID()
    let reviewerName: String
    let rating: Double
    let comment: String
    let date: String
}

// MARK: - Phase 1 User Account & Privacy Split Models

enum UserRole: String, Codable {
    case standardUser = "standard_user"
}

/// Stored at `users/{uid}` — Safe to be read by any authenticated user browsing the marketplace.
/// Contains NO email, NO phone number, and NO exact street address/coordinates.
struct PublicUserProfile: Identifiable, Codable {
    let id: String                 // Matches FirebaseAuth uid
    var name: String?              // Optional full/display name
    var handle: String             // e.g. "@alextrades"
    var bio: String
    var coarseLocation: String     // City/Region only (e.g. "Makati")
    var avatarURL: String?         // Firebase Storage download URL
    var role: UserRole
    var rating: Double
    var reviewsCount: Int
    var verified: Bool
    var listingsCount: Int
    var soldCount: Int
    var createdAt: TimeInterval

    /// Computed display name that falls back to handle if optional name is nil or empty
    var displayName: String {
        if let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return handle
    }
}

/// Stored at `users/{uid}/private/sensitive` — Strictly locked down via Firestore Security Rules
/// so ONLY `request.auth.uid == uid` can ever read or write this document.
struct PrivateUserData: Codable {
    let uid: String
    var email: String
    var emailHash: String          // SHA-256 digest via CryptoKit
    var phoneNumber: String
    var phoneHash: String          // SHA-256 digest via CryptoKit
    var exactLocation: String      // Full private location string / coordinates
    var updatedAt: TimeInterval
}
```

---

## Section 3: Create `midterm/UserService.swift`

```swift
import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class UserService {
    static let shared = UserService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    // MARK: - Atomic Public + Private Profile Save
    
    /// Saves the user's public profile to `users/{uid}` and private sensitive fields to
    /// `users/{uid}/private/sensitive` using an atomic Firestore WriteBatch.
    func saveUserProfile(
        uid: String,
        name: String?,
        handle: String,
        email: String,
        phone: String,
        rawLocation: String,
        bio: String,
        profileImage: UIImage?,
        existingAvatarURL: String?,
        completion: @escaping (Result<(PublicUserProfile, PrivateUserData), Error>) -> Void
    ) {
        let proceedWithSave: (String?) -> Void = { [weak self] uploadedAvatarURL in
            guard let self = self else { return }
            
            let cleanName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
            let optionalName: String? = (cleanName?.isEmpty == false) ? cleanName : nil
            
            let formattedHandle: String = {
                let stripped = handle.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "@", with: "")
                return stripped.isEmpty ? "@trader_\(uid.prefix(5))" : "@\(stripped)"
            }()
            
            let coarseLocation = SecurityUtils.extractCoarseLocation(from: rawLocation)
            let normalizedPhone = SecurityUtils.normalizePhone(phone)
            let now = Date().timeIntervalSince1970
            
            let publicProfile = PublicUserProfile(
                id: uid,
                name: optionalName,
                handle: formattedHandle,
                bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
                coarseLocation: coarseLocation,
                avatarURL: uploadedAvatarURL ?? existingAvatarURL,
                role: .standardUser,
                rating: 5.0,
                reviewsCount: 0,
                verified: true,
                listingsCount: 0,
                soldCount: 0,
                createdAt: now
            )
            
            let privateData = PrivateUserData(
                uid: uid,
                email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                emailHash: SecurityUtils.sha256(email),
                phoneNumber: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                phoneHash: normalizedPhone.isEmpty ? "" : SecurityUtils.sha256(normalizedPhone),
                exactLocation: rawLocation.trimmingCharacters(in: .whitespacesAndNewlines),
                updatedAt: now
            )
            
            let publicRef = self.db.collection("users").document(uid)
            let privateRef = publicRef.collection("private").document("sensitive")
            
            let batch = self.db.batch()
            
            let publicDict: [String: Any] = [
                "id": publicProfile.id,
                "name": publicProfile.name as Any,
                "handle": publicProfile.handle,
                "bio": publicProfile.bio,
                "coarseLocation": publicProfile.coarseLocation,
                "avatarURL": publicProfile.avatarURL as Any,
                "role": publicProfile.role.rawValue,
                "rating": publicProfile.rating,
                "reviewsCount": publicProfile.reviewsCount,
                "verified": publicProfile.verified,
                "listingsCount": publicProfile.listingsCount,
                "soldCount": publicProfile.soldCount,
                "createdAt": publicProfile.createdAt
            ]
            
            let privateDict: [String: Any] = [
                "uid": privateData.uid,
                "email": privateData.email,
                "emailHash": privateData.emailHash,
                "phoneNumber": privateData.phoneNumber,
                "phoneHash": privateData.phoneHash,
                "exactLocation": privateData.exactLocation,
                "updatedAt": privateData.updatedAt
            ]
            
            batch.setData(publicDict, forDocument: publicRef, merge: true)
            batch.setData(privateDict, forDocument: privateRef, merge: true)
            
            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success((publicProfile, privateData)))
                }
            }
        }
        
        if let image = profileImage {
            uploadAvatar(uid: uid, image: image) { result in
                switch result {
                case .success(let url):
                    proceedWithSave(url)
                case .failure:
                    // Even if image upload fails (e.g., Storage not yet enabled), still save profile data
                    proceedWithSave(existingAvatarURL)
                }
            }
        } else {
            proceedWithSave(existingAvatarURL)
        }
    }
    
    // MARK: - Fetch Current Authenticated User (Public + Private)
    
    func fetchCurrentUserProfile(
        uid: String,
        completion: @escaping (PublicUserProfile?, PrivateUserData?) -> Void
    ) {
        let publicRef = db.collection("users").document(uid)
        let privateRef = publicRef.collection("private").document("sensitive")
        
        let group = DispatchGroup()
        var fetchedPublic: PublicUserProfile?
        var fetchedPrivate: PrivateUserData?
        
        group.enter()
        publicRef.getDocument { snapshot, _ in
            defer { group.leave() }
            guard let data = snapshot?.data() else { return }
            fetchedPublic = PublicUserProfile(
                id: data["id"] as? String ?? uid,
                name: data["name"] as? String,
                handle: data["handle"] as? String ?? "@trader",
                bio: data["bio"] as? String ?? "",
                coarseLocation: data["coarseLocation"] as? String ?? "Undisclosed",
                avatarURL: data["avatarURL"] as? String,
                role: UserRole(rawValue: data["role"] as? String ?? "standard_user") ?? .standardUser,
                rating: data["rating"] as? Double ?? 5.0,
                reviewsCount: data["reviewsCount"] as? Int ?? 0,
                verified: data["verified"] as? Bool ?? false,
                listingsCount: data["listingsCount"] as? Int ?? 0,
                soldCount: data["soldCount"] as? Int ?? 0,
                createdAt: data["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970
            )
        }
        
        group.enter()
        privateRef.getDocument { snapshot, _ in
            defer { group.leave() }
            guard let data = snapshot?.data() else { return }
            fetchedPrivate = PrivateUserData(
                uid: data["uid"] as? String ?? uid,
                email: data["email"] as? String ?? "",
                emailHash: data["emailHash"] as? String ?? "",
                phoneNumber: data["phoneNumber"] as? String ?? "",
                phoneHash: data["phoneHash"] as? String ?? "",
                exactLocation: data["exactLocation"] as? String ?? "",
                updatedAt: data["updatedAt"] as? TimeInterval ?? Date().timeIntervalSince1970
            )
        }
        
        group.notify(queue: .main) {
            completion(fetchedPublic, fetchedPrivate)
        }
    }
    
    // MARK: - Upload Avatar to Firebase Storage
    
    private func uploadAvatar(
        uid: String,
        image: UIImage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.65) else {
            completion(.failure(NSError(domain: "GameTrade", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image."])))
            return
        }
        
        let avatarRef = storage.reference().child("avatars/\(uid)/profile.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        avatarRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            avatarRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                }
            }
        }
    }
}
```

---

## Section 4: Refactor `midterm/AppState.swift`

Replace `midterm/AppState.swift` with the following implementation:

```swift
import SwiftUI
import Combine
import FirebaseAuth

enum Tab: String {
    case deals, market, offers, profile
}

enum StackScreen: Hashable {
    case listing(listingId: String)
    case otherProfile(userId: String)
    case search
    case notifications
    case saved
    case editProfile
}

enum SheetType: Identifiable {
    case makeOffer(listingId: String)
    case proposeTrade(listingId: String)
    case filters
    case sell
    case search

    var id: String {
        switch self {
        case .makeOffer: return "make-offer"
        case .proposeTrade: return "propose-trade"
        case .filters: return "filters"
        case .sell: return "sell"
        case .search: return "search"
        }
    }
}

class AppState: ObservableObject {
    // Auth state (No plaintext passwords stored in AppStorage!)
    @AppStorage("isAuthenticated") var isAuthenticated = false
    @AppStorage("onboarded") var onboarded = false

    // Current User UID & Avatar URL
    @Published var currentUserId: String = ""
    @Published var userAvatarURL: String? = nil

    // User Profile Data (Synced with Firestore Public + Private documents)
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userHandle") var userHandle: String = "@trader"
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("userPhone") var userPhone: String = ""
    @AppStorage("userLocation") var userLocation: String = ""
    @AppStorage("userCoarseLocation") var userCoarseLocation: String = ""
    @AppStorage("userBio") var userBio: String = "Casual gamer and trader."

    // Persistent profile image cache for instant UI rendering
    @AppStorage("userProfileImageData") var userProfileImageData: Data = Data()

    var profileImage: UIImage? {
        get { UIImage(data: userProfileImageData) }
        set { userProfileImageData = newValue?.jpegData(compressionQuality: 0.5) ?? Data() }
    }

    @Published var activeTab: Tab = .deals
    @Published var navigationPath = NavigationPath()
    @Published var activeSheet: SheetType?

    // Sign-up flow navigation
    @Published var shouldSetupProfile: Bool = false
    @Published var isSavingProfile: Bool = false

    // Additional state
    @Published var offersBadge = true
    @Published var sellPressed = false
    @Published var showOfferSuccess = false
    @Published var toastMessage: String?

    // State for requirements
    @Published var selectedListing: Listing?
    @Published var isEditingProfile: Bool = false
    @Published var showingImagePicker: Bool = false
    @Published var searchQuery: String = ""

    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    // Mock notifications
    enum NotificationType {
        case offer, message, trade, system
    }

    struct Notification: Identifiable {
        let id = UUID()
        let type: NotificationType
        let title: String
        let time: String
        var isRead: Bool
    }

    @Published var notifications: [Notification] = [
        Notification(type: .offer, title: "New offer on your PS5", time: "2 hours ago", isRead: false),
        Notification(type: .message, title: "User123 messaged you", time: "5 hours ago", isRead: false),
        Notification(type: .trade, title: "Your trade was accepted", time: "Yesterday", isRead: true)
    ]

    init() {
        // Remove any legacy plaintext password key from UserDefaults if it existed previously
        UserDefaults.standard.removeObject(forKey: "storedPassword")
        UserDefaults.standard.removeObject(forKey: "storedEmail")
        registerAuthStateListener()
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    private func registerAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let user = user {
                    self.currentUserId = user.uid
                    self.userEmail = user.email ?? self.userEmail
                    if !self.shouldSetupProfile {
                        self.isAuthenticated = true
                    }
                    self.syncUserProfileFromFirestore(uid: user.uid)
                } else {
                    self.currentUserId = ""
                    self.isAuthenticated = false
                }
            }
        }
    }

    func syncUserProfileFromFirestore(uid: String) {
        UserService.shared.fetchCurrentUserProfile(uid: uid) { [weak self] publicProfile, privateData in
            guard let self = self else { return }
            if let pub = publicProfile {
                self.userName = pub.displayName
                self.userHandle = pub.handle
                self.userBio = pub.bio
                self.userCoarseLocation = pub.coarseLocation
                self.userAvatarURL = pub.avatarURL
                if self.userLocation.isEmpty {
                    self.userLocation = pub.coarseLocation
                }
            }
            if let priv = privateData {
                if !priv.email.isEmpty { self.userEmail = priv.email }
                self.userPhone = priv.phoneNumber
                if !priv.exactLocation.isEmpty {
                    self.userLocation = priv.exactLocation
                }
            }
        }
    }

    func saveUserProfileToFirebase(
        name: String?,
        username: String,
        phone: String,
        rawLocation: String,
        bio: String,
        selectedImage: UIImage?,
        completion: @escaping (Error?) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(NSError(domain: "GameTrade", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user session found."]))
            return
        }

        let emailToSave = currentUser.email ?? userEmail
        isSavingProfile = true

        UserService.shared.saveUserProfile(
            uid: currentUser.uid,
            name: name,
            handle: username,
            email: emailToSave,
            phone: phone,
            rawLocation: rawLocation,
            bio: bio,
            profileImage: selectedImage,
            existingAvatarURL: userAvatarURL
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isSavingProfile = false
                switch result {
                case .success(let (pub, priv)):
                    self.userName = pub.displayName
                    self.userHandle = pub.handle
                    self.userBio = pub.bio
                    self.userCoarseLocation = pub.coarseLocation
                    self.userAvatarURL = pub.avatarURL
                    self.userEmail = priv.email
                    self.userPhone = priv.phoneNumber
                    self.userLocation = priv.exactLocation
                    if let selectedImage = selectedImage {
                        self.profileImage = selectedImage
                    }
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.toastMessage = nil
        }
    }

    func navigate(to screen: StackScreen) {
        navigationPath.append(screen)
    }

    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func switchTab(_ tab: Tab) {
        activeTab = tab
        navigationPath = NavigationPath()
        if tab == .offers {
            offersBadge = false
        }
    }

    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: trimmedEmail, password: password) { [weak self] result, error in
            if let error = error {
                completion(error)
            } else if let user = result?.user {
                self?.currentUserId = user.uid
                self?.userEmail = user.email ?? trimmedEmail
                self?.isAuthenticated = true
                self?.syncUserProfileFromFirestore(uid: user.uid)
                completion(nil)
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().createUser(withEmail: trimmedEmail, password: password) { [weak self] result, error in
            if let error = error {
                completion(error)
            } else if let user = result?.user {
                self?.currentUserId = user.uid
                self?.userEmail = user.email ?? trimmedEmail
                self?.shouldSetupProfile = true
                completion(nil)
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            onboarded = false
            currentUserId = ""
            userPhone = ""
            userLocation = ""
            userProfileImageData = Data()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
```

---

## Section 5: Update `ProfileSetupView.swift`

Replace `ProfileSetupView.swift` with the following implementation (supports optional Full Name, private phone/location notice, and atomic Firestore persistence):

```swift
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
```

---

## Section 6: Update `midterm/EditProfileView.swift`

Replace `midterm/EditProfileView.swift` with the following implementation so profile edits sync directly to the public and private Firestore paths:

```swift
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
```

---

## Section 7: Firebase Security Rules (`firestore.rules` & `storage.rules`)

Apply these rules in your Firebase Console under **Firestore Database -> Rules** and **Storage -> Rules** so malicious users can never read `users/{uid}/private/sensitive`.

### `firestore.rules`
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // Public User Profiles: Any signed-in user can view public trader info,
    // but only the owner can create or update their public profile.
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create, update: if isOwner(userId)
        && (!('email' in request.resource.data))
        && (!('phoneNumber' in request.resource.data))
        && (!('exactLocation' in request.resource.data));
      allow delete: if isOwner(userId);

      // Private Sensitive Vault: Strictly locked to the account owner ONLY.
      // Malicious users or other traders can NEVER read or query this subcollection.
      match /private/{docId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

### `storage.rules`
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}/profile.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```