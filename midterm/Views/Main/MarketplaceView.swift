import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.primary : Theme.surfaceElevated)
                .foregroundColor(isSelected ? Theme.textPrimary : Theme.textSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Theme.primary : Theme.border, lineWidth: 1)
                )
                .shadow(color: isSelected ? Theme.primary.opacity(0.3) : Color.clear, radius: 6)
        }
    }
}

struct MarketplaceView: View {
    @ObservedObject var appState: AppState

    let listings = [
        Listing(id: "L1", title: "PS5 Disc Edition — 1TB", price: 430, was: 499, platform: .ps5, condition: .likeNew, sellerID: "jordan", sellerName: "Jordan", sellerAvatar: "person", sellerRating: 4.5, isVerified: true, location: "Quezon City", saved: false, bundle: nil, images: ["PS5"], description: "Great condition PS5 with Dualsense."),
        Listing(id: "L2", title: "Xbox Series X — 1TB", price: 350, was: 420, platform: .xbox, condition: .good, sellerID: "mia", sellerName: "Mia", sellerAvatar: "person", sellerRating: 4.2, isVerified: false, location: "Makati", saved: true, bundle: nil, images: ["xbox_1"], description: "Used for 6 months, includes cables."),
        Listing(id: "L3", title: "Nintendo Switch OLED — White", price: 280, was: 320, platform: .switchConsole, condition: .likeNew, sellerID: "gamehaven", sellerName: "GameHaven", sellerAvatar: "person", sellerRating: 4.8, isVerified: true, location: "BGC", saved: false, bundle: nil, images: ["Nintendo_switch_2_Fullspecwithgames"], description: "Brand new OLED console with dock."),
        Listing(id: "L4", title: "PS5 Dualsense Wireless", price: 65, was: 75, platform: .ps5, condition: .likeNew, sellerID: "alfye", sellerName: "Alfye Reyes", sellerAvatar: "person", sellerRating: 4.9, isVerified: true, location: "Quezon City", saved: false, bundle: nil, images: ["dualsense_controller"], description: "Teal chroma DualSense controller in box."),
        Listing(id: "L5", title: "PS4 Pro 1TB Console", price: 150, was: 180, platform: .ps4, condition: .fair, sellerID: "alex", sellerName: "Alex", sellerAvatar: "person", sellerRating: 4.0, isVerified: false, location: "Pasig", saved: false, bundle: nil, images: ["PS5_Slim_W_Controller"], description: "Good working condition, tested.")
    ]

    @State private var searchText = ""
    @State private var selectedPlatform: Platform? = nil

    var filteredListings: [Listing] {
        listings.filter { listing in
            let matchesSearch = searchText.isEmpty || listing.title.localizedCaseInsensitiveContains(searchText)
            let platformToMatch = appState.selectedMarketPlatform ?? selectedPlatform
            let matchesPlatform = platformToMatch == nil || listing.platform == platformToMatch
            return matchesSearch && matchesPlatform
        }
    }

    var body: some View {
        NavigationStack(path: $appState.marketNavPath) {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header Bar
                        HStack {
                            Text("Marketplace")
                                .font(.title2.bold())
                                .foregroundColor(Theme.textPrimary)

                            Spacer()

                            Button {
                                appState.activeSheet = .chatList
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "message.fill")
                                        .font(.title3)
                                        .foregroundColor(Theme.primary)
                                        .padding(8)
                                        .background(Theme.surfaceElevated)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Theme.border, lineWidth: 1))

                                    if appState.totalUnreadMessages > 0 {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 10, height: 10)
                                            .offset(x: 2, y: -2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Search Bar + Add Listing Button
                        HStack(spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Theme.textMuted)
                                TextField("Search consoles, discs...", text: $searchText)
                                    .foregroundColor(Theme.textPrimary)
                                    .accentColor(Theme.cyberBlue)
                            }
                            .padding(10)
                            .background(Theme.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))

                            Button {
                                appState.activeSheet = .sell
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.caption.bold())
                                    Text("Sell")
                                        .font(.caption.bold())
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 11)
                                .background(Theme.buttonGradient)
                                .foregroundColor(Theme.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Theme.primary.opacity(0.35), radius: 6)
                            }
                        }
                        .padding(.horizontal)

                        // Platform Filter Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                FilterChip(title: "All", isSelected: selectedPlatform == nil) {
                                    selectedPlatform = nil
                                }
                                FilterChip(title: "PlayStation", isSelected: selectedPlatform == .ps5 || selectedPlatform == .ps4) {
                                    selectedPlatform = selectedPlatform == .ps5 ? nil : .ps5
                                }
                                FilterChip(title: "Xbox", isSelected: selectedPlatform == .xbox) {
                                    selectedPlatform = selectedPlatform == .xbox ? nil : .xbox
                                }
                                FilterChip(title: "Switch", isSelected: selectedPlatform == .switchConsole) {
                                    selectedPlatform = selectedPlatform == .switchConsole ? nil : .switchConsole
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Featured Steam-Style Store Drop Banner
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "1E1B4B"), Color(hex: "312E81"), Color(hex: "1E293B")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Theme.border, lineWidth: 1)
                                )

                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(Theme.cyberBlue)
                                        Text("VERIFIED SELLERS")
                                            .font(.system(size: 10, weight: .heavy))
                                            .foregroundColor(Theme.cyberBlue)
                                    }

                                    Text("Guaranteed Working Hardware")
                                        .font(.subheadline.bold())
                                        .foregroundColor(Theme.textPrimary)

                                    Text("Every console backed by 48-hour trade protection.")
                                        .font(.caption2)
                                        .foregroundColor(Theme.textSecondary)
                                        .lineLimit(2)
                                }
                                .padding(.leading, 18)

                                Spacer()

                                Image("xbox_controller_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .padding(.trailing, 16)
                            }
                        }
                        .frame(height: 100)
                        .padding(.horizontal)

                        // Listings Section Header
                        HStack {
                            Text("\(filteredListings.count) Available Listings")
                                .font(.subheadline.bold())
                                .foregroundColor(Theme.textPrimary)

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.caption2)
                                Text("Popular")
                                    .font(.caption)
                            }
                            .foregroundColor(Theme.textSecondary)
                        }
                        .padding(.horizontal)

                        // Listings Grid (Steam 2-Column Product Grid)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 16) {
                            ForEach(filteredListings) { listing in
                                NavigationLink(value: StackScreen.listing(listingId: listing.id)) {
                                    ListingCardView(listing: listing)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: StackScreen.self) { screen in
                switch screen {
                case .listing(let id):
                    if let listing = listings.first(where: { $0.id == id }) {
                        ListingDetailView(listing: listing)
                            .environmentObject(appState)
                    } else {
                        Text("Listing not found")
                    }
                case .otherProfile(let userId):
                    OtherProfileView(userId: userId, appState: appState)
                        .environmentObject(appState)
                case .chatDetail(let chatId):
                    ChatDetailView(chatId: chatId, appState: appState)
                        .environmentObject(appState)
                default:
                    Text("Screen not implemented")
                }
            }
        }
    }
}
