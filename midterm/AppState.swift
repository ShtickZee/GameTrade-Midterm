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
    // Auth state
    @AppStorage("isAuthenticated") var isAuthenticated = false
    @AppStorage("onboarded") var onboarded = false
    @AppStorage("storedEmail") var storedEmail: String = ""
    @AppStorage("storedPassword") var storedPassword: String = ""
    
    // User Profile Data (Persistent via AppStorage)
    @AppStorage("userName") var userName: String = "Alex Reyes"
    @AppStorage("userHandle") var userHandle: String = "@alextrades"
    @AppStorage("userEmail") var userEmail: String = "alex@example.com"
    @AppStorage("userPhone") var userPhone: String = "+1 234 567 8900"
    @AppStorage("userLocation") var userLocation: String = "Makati"
    @AppStorage("userBio") var userBio: String = "Casual gamer and trader."
    
    // Persistent profile image storage
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
    
    // Additional state
    @Published var offersBadge = true
    @Published var sellPressed = false
    @Published var showOfferSuccess = false
    @Published var toastMessage: String?
    
    // New state for requirements
    @Published var selectedListing: Listing?
    @Published var isEditingProfile: Bool = false
    @Published var showingImagePicker: Bool = false
    @Published var searchQuery: String = ""
    
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
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else {
                self.isAuthenticated = true
                completion(nil)
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else {
                self.isAuthenticated = true
                self.shouldSetupProfile = true
                completion(nil)
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            onboarded = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
