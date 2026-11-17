import SwiftUI

struct OfferItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let listingId: String
    let otherUserId: String
    let otherUserName: String
    let offerAmount: Double?
    let tradeItem: String?
}

struct OfferCardView: View {
    let offer: OfferItem
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                // Profile Avatar of the other trader
                NavigationLink(value: StackScreen.otherProfile(userId: offer.otherUserId)) {
                    ZStack {
                        Circle()
                            .fill(Theme.primary.opacity(0.18))
                            .frame(width: 46, height: 46)
                        Text(String(offer.otherUserName.prefix(1)).uppercased())
                            .font(.subheadline.bold())
                            .foregroundColor(Theme.primary)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(offer.title)
                            .font(.subheadline.bold())
                            .foregroundColor(Theme.textPrimary)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(Theme.cyberBlue)
                    }

                    Text(offer.subtitle)
                        .font(.footnote)
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Text(offer.status)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(statusColor.opacity(0.4), lineWidth: 1))
            }

            // Action Buttons
            HStack(spacing: 10) {
                Button("Decline") {
                    appState.showToast("Offer declined")
                }
                .font(.caption.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(Theme.surface)
                .foregroundColor(Theme.textSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))

                Button {
                    appState.openOrCreateChat(
                        sellerId: offer.otherUserId,
                        sellerName: offer.otherUserName,
                        sellerHandle: "@\(offer.title)",
                        initialMessage: "Hi \(offer.otherUserName), about your offer for \(offer.title)..."
                    )
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.left.fill")
                        Text("Chat & Negotiate")
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(Theme.buttonGradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: Theme.primary.opacity(0.35), radius: 6)
                }
            }
        }
        .padding(14)
        .background(Theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }

    private var statusColor: Color {
        switch offer.status.lowercased() {
        case "new offer": return Theme.neonGreen
        case "pending": return Theme.cyberBlue
        case "accepted": return Theme.neonGreen
        case "countered": return .orange
        default: return Theme.cyberBlue
        }
    }
}

struct OffersView: View {
    @ObservedObject var appState: AppState
    @State private var selectedTab = 0 // 0: Incoming, 1: Sent
    @State private var offerSearchText: String = ""
    @State private var showingTraderSearchSheet: Bool = false

    private let incomingOffers: [OfferItem] = [
        OfferItem(
            title: "mia.trades",
            subtitle: "Wants to trade: Xbox Series S + $40 on PS4 Pro 1TB",
            status: "Pending",
            listingId: "L5",
            otherUserId: "mia",
            otherUserName: "Mia",
            offerAmount: nil,
            tradeItem: "Xbox Series S + $40"
        ),
        OfferItem(
            title: "jordan_trades",
            subtitle: "Offered $400 cash pickup for PS5 Disc Edition",
            status: "New Offer",
            listingId: "L1",
            otherUserId: "jordan",
            otherUserName: "Jordan",
            offerAmount: 400,
            tradeItem: nil
        )
    ]

    private let sentOffers: [OfferItem] = [
        OfferItem(
            title: "gamehaven_ph",
            subtitle: "Offered $260 on Nintendo Switch OLED — White",
            status: "Countered",
            listingId: "L3",
            otherUserId: "gamehaven",
            otherUserName: "GameHaven",
            offerAmount: 260,
            tradeItem: nil
        ),
        OfferItem(
            title: "alfye_gaming",
            subtitle: "Offered $55 cash on PS5 DualSense Wireless",
            status: "Pending",
            listingId: "L4",
            otherUserId: "alfye",
            otherUserName: "Alfye Reyes",
            offerAmount: 55,
            tradeItem: nil
        ),
        OfferItem(
            title: "alex_retro",
            subtitle: "Offered trade: Nintendo 3DS XL on PS4 Pro",
            status: "Pending",
            listingId: "L5",
            otherUserId: "alex",
            otherUserName: "Alex",
            offerAmount: nil,
            tradeItem: "Nintendo 3DS XL"
        )
    ]

    private var currentList: [OfferItem] {
        selectedTab == 0 ? incomingOffers : sentOffers
    }

    private var filteredOffers: [OfferItem] {
        let q = offerSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            return currentList
        }
        return currentList.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.subtitle.localizedCaseInsensitiveContains(q) ||
            $0.status.localizedCaseInsensitiveContains(q) ||
            $0.otherUserName.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        NavigationStack(path: $appState.offersNavPath) {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Offer Search Bar
                        offerSearchBarView

                        // Discover Traders to Offer Banner
                        discoverTradersBanner

                        // Segmented Tab Picker
                        Picker("Offers", selection: $selectedTab) {
                            Text("Incoming (\(incomingOffers.count))").tag(0)
                            Text("Sent (\(sentOffers.count))").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        // Offers List
                        if filteredOffers.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tag.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(Theme.textMuted)
                                Text("No offers found")
                                    .font(.subheadline.bold())
                                    .foregroundColor(Theme.textPrimary)
                                Text(offerSearchText.isEmpty ? "You don't have any offers in this category." : "No offers match '\(offerSearchText)'")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(filteredOffers) { offer in
                                    OfferCardView(offer: offer, appState: appState)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Offers & Trades")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingTraderSearchSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "person.badge.plus")
                            Text("New Offer")
                                .font(.caption.bold())
                        }
                        .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingTraderSearchSheet) {
                TraderOfferDiscoverySheet(appState: appState)
            }
            .navigationDestination(for: StackScreen.self) { screen in
                switch screen {
                case .chatDetail(let chatId):
                    ChatDetailView(chatId: chatId, appState: appState)
                        .environmentObject(appState)
                case .listing(let id):
                    if let listing = appState.listings.first(where: { $0.id == id }) {
                        ListingDetailView(listing: listing)
                            .environmentObject(appState)
                    } else {
                        Text("Listing not found")
                    }
                case .otherProfile(let userId):
                    OtherProfileView(userId: userId, appState: appState)
                        .environmentObject(appState)
                default:
                    Text("Screen not implemented")
                }
            }
        }
    }

    // MARK: - Search Bar

    private var offerSearchBarView: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.textSecondary)

            TextField("Filter offers by trader, item, or status...", text: $offerSearchText)
                .foregroundColor(Theme.textPrimary)
                .autocorrectionDisabled()

            if !offerSearchText.isEmpty {
                Button {
                    offerSearchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.textMuted)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
    }

    // MARK: - Discover Banner

    private var discoverTradersBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(Theme.primary)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Search Traders to Make Offers")
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)
                Text("Find verified console sellers and send direct offers or trade proposals.")
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Button {
                showingTraderSearchSheet = true
            } label: {
                Text("Find")
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Theme.buttonGradient)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .background(Theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
    }
}

// MARK: - Trader Offer Discovery Sheet

struct TraderOfferDiscoverySheet: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var registeredUsers: [PublicUserProfile] = []
    @State private var isLoadingUsers: Bool = true

    private var mockTraders: [PublicUserProfile] {
        [
            PublicUserProfile(id: "jordan", name: "Jordan", handle: "@jordan_trades", bio: "PS5 enthusiast", coarseLocation: "Quezon City", avatarURL: nil, role: .standardUser, rating: 4.9, reviewsCount: 12, verified: true, listingsCount: 1, soldCount: 14, createdAt: 0),
            PublicUserProfile(id: "mia", name: "Mia", handle: "@mia.trades", bio: "Xbox Series X trader", coarseLocation: "Makati", avatarURL: nil, role: .standardUser, rating: 4.8, reviewsCount: 9, verified: true, listingsCount: 1, soldCount: 8, createdAt: 0),
            PublicUserProfile(id: "gamehaven", name: "GameHaven", handle: "@gamehaven_ph", bio: "Switch OLED & Retro boutique", coarseLocation: "BGC", avatarURL: nil, role: .storefront, rating: 4.9, reviewsCount: 45, verified: true, listingsCount: 1, soldCount: 62, createdAt: 0),
            PublicUserProfile(id: "alfye", name: "Alfye Reyes", handle: "@alfye_gaming", bio: "Rare DualSense & PS5 gear", coarseLocation: "Quezon City", avatarURL: nil, role: .standardUser, rating: 4.9, reviewsCount: 18, verified: true, listingsCount: 1, soldCount: 15, createdAt: 0),
            PublicUserProfile(id: "alex", name: "Alex", handle: "@alex_retro", bio: "PS4 & Switch bundles", coarseLocation: "Pasig", avatarURL: nil, role: .standardUser, rating: 4.7, reviewsCount: 6, verified: false, listingsCount: 1, soldCount: 5, createdAt: 0)
        ]
    }

    private var allTraders: [PublicUserProfile] {
        var list = mockTraders
        for u in registeredUsers {
            if !list.contains(where: { $0.id == u.id }) {
                list.insert(u, at: 0)
            }
        }
        return list
    }

    private var filteredTraders: [PublicUserProfile] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return allTraders }
        return allTraders.filter {
            $0.displayName.localizedCaseInsensitiveContains(q) ||
            $0.handle.localizedCaseInsensitiveContains(q) ||
            $0.coarseLocation.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Field
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.textSecondary)
                        TextField("Search traders by username, handle, or city...", text: $searchText)
                            .foregroundColor(Theme.textPrimary)
                            .autocorrectionDisabled()

                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(Theme.textMuted)
                            }
                        }
                    }
                    .padding(12)
                    .background(Theme.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 12)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredTraders) { trader in
                                let traderListings = appState.listings.filter { $0.sellerID == trader.id }

                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Theme.primary.opacity(0.18))
                                                .frame(width: 44, height: 44)
                                            Text(String(trader.displayName.prefix(1)).uppercased())
                                                .font(.headline.bold())
                                                .foregroundColor(Theme.primary)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 4) {
                                                Text(trader.displayName)
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(Theme.textPrimary)
                                                if trader.verified {
                                                    Image(systemName: "checkmark.seal.fill")
                                                        .font(.caption2)
                                                        .foregroundColor(Theme.cyberBlue)
                                                }
                                            }

                                            Text(trader.handle)
                                                .font(.caption)
                                                .foregroundColor(Theme.textSecondary)

                                            HStack(spacing: 6) {
                                                Text("\(String(format: "%.1f", trader.rating)) ★")
                                                    .font(.caption2.bold())
                                                    .foregroundColor(.yellow)
                                                Text("•")
                                                    .foregroundColor(Theme.textMuted)
                                                Text(trader.coarseLocation)
                                                    .font(.caption2)
                                                    .foregroundColor(Theme.textMuted)
                                            }
                                        }

                                        Spacer()

                                        Button {
                                            dismiss()
                                            appState.navigate(to: .otherProfile(userId: trader.id))
                                        } label: {
                                            Text("Profile")
                                                .font(.caption.bold())
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Theme.surface)
                                                .foregroundColor(Theme.textPrimary)
                                                .clipShape(Capsule())
                                                .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
                                        }
                                    }

                                    // If trader has listings, show them
                                    if !traderListings.isEmpty {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Active Listings:")
                                                .font(.caption2.bold())
                                                .foregroundColor(Theme.textMuted)

                                            ForEach(traderListings) { item in
                                                HStack {
                                                    Text(item.title)
                                                        .font(.caption)
                                                        .foregroundColor(Theme.textPrimary)
                                                        .lineLimit(1)
                                                    Spacer()
                                                    Text("$\(Int(item.price))")
                                                        .font(.caption.bold())
                                                        .foregroundColor(Theme.neonGreen)

                                                    Button("Make Offer") {
                                                        dismiss()
                                                        appState.openOrCreateChat(
                                                            sellerId: trader.id,
                                                            sellerName: trader.displayName,
                                                            sellerHandle: trader.handle,
                                                            listing: item,
                                                            initialMessage: "Hi \(trader.displayName), I'd like to offer $\(Int(item.price * 0.9)) for \(item.title).",
                                                            initialOfferAmount: item.price * 0.9
                                                        )
                                                    }
                                                    .font(.caption2.bold())
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Theme.primary)
                                                    .foregroundColor(.white)
                                                    .clipShape(Capsule())
                                                }
                                                .padding(8)
                                                .background(Theme.surface)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            }
                                        }
                                    } else {
                                        // Direct Chat to propose custom trade
                                        Button {
                                            dismiss()
                                            appState.openOrCreateChat(
                                                sellerId: trader.id,
                                                sellerName: trader.displayName,
                                                sellerHandle: trader.handle,
                                                initialMessage: "Hi \(trader.displayName), I'd like to propose a trade or offer."
                                            )
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "bubble.left.fill")
                                                Text("Send Trade Proposal in Chat")
                                            }
                                            .font(.caption.bold())
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Theme.primary.opacity(0.15))
                                            .foregroundColor(Theme.primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                }
                                .padding(12)
                                .background(Theme.surfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Find Traders to Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.primary)
                }
            }
            .onAppear {
                loadRegisteredUsers()
            }
        }
    }

    private func loadRegisteredUsers() {
        UserService.shared.fetchAllRegisteredUsers { result in
            DispatchQueue.main.async {
                self.isLoadingUsers = false
                if case .success(let users) = result {
                    self.registeredUsers = users
                }
            }
        }
    }
}
