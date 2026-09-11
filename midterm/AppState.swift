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
    
    var id: String {
        switch self {
        case .makeOffer: return "make-offer"
        case .proposeTrade: return "propose-trade"
        case .filters: return "filters"
        case .sell: return "sell"
        }
    }
}

class AppState: ObservableObject {
    // Auth state
    @AppStorage("isAuthenticated") var isAuthenticated = false
    @AppStorage("onboarded") var onboarded = false
    
    @Published var activeTab: Tab = .deals
    @Published var navigationPath = NavigationPath()
    @Published var activeSheet: SheetType?
    
    // Additional state mapped from App.tsx
    @Published var offersBadge = true
    @Published var sellPressed = false
    @Published var showOfferSuccess = false
    @Published var toastMessage: String?
    
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
