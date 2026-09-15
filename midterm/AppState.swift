import SwiftUI
import Combine

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
    
    // User Profile Data (Persistent via AppStorage)
    @AppStorage("userName") var userName: String = "Alex Reyes"
    @AppStorage("userHandle") var userHandle: String = "@alextrades"
    @AppStorage("userEmail") var userEmail: String = "alex@example.com"
    @AppStorage("userPhone") var userPhone: String = "+1 234 567 8900"
    @AppStorage("userLocation") var userLocation: String = "Makati"
    @AppStorage("userBio") var userBio: String = "Casual gamer and trader."
    
    @Published var activeTab: Tab = .deals
    @Published var navigationPath = NavigationPath()
    @Published var activeSheet: SheetType?
    
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
    struct Notification: Identifiable {
        let id = UUID()
        let title: String
        let time: String
    }
    @Published var notifications: [Notification] = [
        Notification(title: "New offer on your PS5", time: "2 hours ago"),
        Notification(title: "User123 messaged you", time: "5 hours ago")
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
    
    func logout() {
        isAuthenticated = false
        onboarded = false
    }
}
