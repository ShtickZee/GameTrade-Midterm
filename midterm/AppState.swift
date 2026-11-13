import SwiftUI
import Combine
import FirebaseAuth

enum Tab: String {
    case deals, market, offers, profile
}

enum StackScreen: Hashable {
    case listing(listingId: String)
    case otherProfile(userId: String)
    case chatDetail(chatId: String)
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
    @Published var searchQuery: String = ""
    @Published var activeChatId: String? = nil

    @MainActor
    func openOrCreateChat(
        sellerId: String,
        sellerName: String,
        sellerHandle: String = "@seller",
        listing: Listing? = nil,
        initialMessage: String? = nil,
        initialOfferAmount: Double? = nil,
        initialTradeItemTitle: String? = nil
    ) {
        Task { @MainActor in
            do {
                let chatId = try await ChatService.shared.getOrCreateChat(
                    currentUserName: self.userName,
                    currentUserHandle: self.userHandle,
                    otherUserId: sellerId,
                    otherUserName: sellerName,
                    otherUserHandle: sellerHandle,
                    listing: listing,
                    initialMessage: initialMessage,
                    initialOfferAmount: initialOfferAmount,
                    initialTradeItemTitle: initialTradeItemTitle
                )
                self.activeSheet = nil
                self.activeChatId = chatId
                print("🔥 Debug: Navigating to chatDetail with chatId: \(chatId)")
                self.navigate(to: .chatDetail(chatId: chatId))
            } catch {
                print("🔥 Failed to open or create chat: \(error.localizedDescription)")
                self.showToast("Could not open chat: \(error.localizedDescription)")
            }
        }
    }
    @Published var showingImagePicker: Bool = false

    // Additional state
    @Published var offersBadge = true
    @Published var sellPressed = false
    @Published var showOfferSuccess = false
    @Published var toastMessage: String?

    // Listings
    @Published var listings: [Listing] = []
    
    func fetchListings() {
        ListingService.shared.fetchListings { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedListings):
                    self?.listings = fetchedListings
                case .failure(let error):
                    print("Error fetching listings: \(error.localizedDescription)")
                }
            }
        }
    }

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
        Task { @MainActor in
            ChatService.shared.stopAllListeners()
        }
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
