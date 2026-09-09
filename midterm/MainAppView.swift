import SwiftUI

struct MainAppView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.activeTab) {
            DealsHomeView(appState: appState)
                .tabItem {
                    Label("Deals", systemImage: "house")
                }
                .tag(Tab.deals)
            
            MarketplaceView(appState: appState)
                .tabItem {
                    Label("Market", systemImage: "cart")
                }
                .tag(Tab.market)
            
            OffersView(appState: appState)
                .tabItem {
                    Label("Offers", systemImage: "arrow.left.arrow.right")
                }
                .tag(Tab.offers)
            
            ProfileView(appState: appState)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        .sheet(item: $appState.activeSheet) { sheetType in
            switch sheetType {
            case .makeOffer(let listingId):
                Text("Make Offer for \(listingId)")
            case .proposeTrade(let listingId):
                Text("Propose Trade for \(listingId)")
            case .filters:
                Text("Filters")
            case .sell:
                Text("Sell Flow")
            }
        }
    }
}
