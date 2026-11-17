import SwiftUI

struct SearchView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var searchMode: Int = 0 // 0: Listings, 1: Traders
    @State private var registeredTraders: [PublicUserProfile] = []
    @State private var isLoadingTraders: Bool = false

    // Known mock sellers for instant discovery
    private var mockTraders: [PublicUserProfile] {
        [
            PublicUserProfile(
                id: "jordan",
                name: "Jordan",
                handle: "@jordan_trades",
                bio: "Passionate PlayStation fan. Upgrading my setup!",
                coarseLocation: "Quezon City",
                avatarURL: nil,
                role: .standardUser,
                rating: 4.9,
                reviewsCount: 12,
                verified: true,
                listingsCount: appState.listings.filter { $0.sellerID == "jordan" }.count,
                soldCount: 14,
                createdAt: 0
            ),
            PublicUserProfile(
                id: "mia",
                name: "Mia",
                handle: "@mia.trades",
                bio: "Xbox enthusiast and competitive Halo player.",
                coarseLocation: "Makati",
                avatarURL: nil,
                role: .standardUser,
                rating: 4.8,
                reviewsCount: 9,
                verified: true,
                listingsCount: appState.listings.filter { $0.sellerID == "mia" }.count,
                soldCount: 8,
                createdAt: 0
            ),
            PublicUserProfile(
                id: "gamehaven",
                name: "GameHaven",
                handle: "@gamehaven_ph",
                bio: "Retro and next-gen gaming boutique in BGC.",
                coarseLocation: "BGC, Taguig",
                avatarURL: nil,
                role: .storefront,
                rating: 4.9,
                reviewsCount: 45,
                verified: true,
                listingsCount: appState.listings.filter { $0.sellerID == "gamehaven" }.count,
                soldCount: 62,
                createdAt: 0
            ),
            PublicUserProfile(
                id: "alfye",
                name: "Alfye Reyes",
                handle: "@alfye_gaming",
                bio: "Collector of rare DualSense controllers and consoles.",
                coarseLocation: "Quezon City",
                avatarURL: nil,
                role: .standardUser,
                rating: 4.9,
                reviewsCount: 18,
                verified: true,
                listingsCount: appState.listings.filter { $0.sellerID == "alfye" }.count,
                soldCount: 15,
                createdAt: 0
            ),
            PublicUserProfile(
                id: "alex",
                name: "Alex",
                handle: "@alex_retro",
                bio: "Retro PlayStation and Nintendo console deals.",
                coarseLocation: "Pasig",
                avatarURL: nil,
                role: .standardUser,
                rating: 4.7,
                reviewsCount: 6,
                verified: false,
                listingsCount: appState.listings.filter { $0.sellerID == "alex" }.count,
                soldCount: 5,
                createdAt: 0
            )
        ]
    }

    private var allTraders: [PublicUserProfile] {
        var list = mockTraders
        for reg in registeredTraders {
            if !list.contains(where: { $0.id == reg.id }) {
                list.insert(reg, at: 0)
            }
        }
        return list
    }

    private var filteredListings: [Listing] {
        let q = appState.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            return appState.listings
        }
        return appState.listings.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.platform.rawValue.localizedCaseInsensitiveContains(q) ||
            $0.description.localizedCaseInsensitiveContains(q)
        }
    }

    private var filteredTraders: [PublicUserProfile] {
        let q = appState.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            return allTraders
        }
        return allTraders.filter {
            $0.displayName.localizedCaseInsensitiveContains(q) ||
            $0.handle.localizedCaseInsensitiveContains(q) ||
            $0.coarseLocation.localizedCaseInsensitiveContains(q) ||
            $0.bio.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    searchBarView
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 10)

                    // Mode Switcher: Listings vs Traders
                    Picker("Search Mode", selection: $searchMode) {
                        Text("Listings (\(filteredListings.count))").tag(0)
                        Text("Traders (\(filteredTraders.count))").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    Divider().background(Theme.border)

                    // Results
                    ScrollView {
                        if searchMode == 0 {
                            listingsResultsView
                        } else {
                            tradersResultsView
                        }
                    }
                }
            }
            .navigationTitle("Search & Discover")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.primary)
                }
            }
            .onAppear {
                if appState.listings.isEmpty {
                    appState.fetchListings()
                }
                loadRegisteredTraders()
            }
        }
    }

    // MARK: - Search Bar

    private var searchBarView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.textSecondary)

            TextField(
                searchMode == 0 ? "Search consoles, games, accessories..." : "Search traders by name, handle, city...",
                text: $appState.searchQuery
            )
            .foregroundColor(Theme.textPrimary)
            .autocorrectionDisabled()

            if !appState.searchQuery.isEmpty {
                Button {
                    appState.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.textMuted)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
    }

    // MARK: - Listings Results

    private var listingsResultsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            if filteredListings.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.textMuted)
                    Text("No listings match '\(appState.searchQuery)'")
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.textPrimary)
                    Text("Try searching for 'PS5', 'Xbox', 'Switch', or 'DualSense'.")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
                    ForEach(filteredListings) { listing in
                        ListingCardView(listing: listing)
                            .onTapGesture {
                                dismiss()
                                appState.navigate(to: .listing(listingId: listing.id))
                            }
                    }
                }
                .padding(16)
            }
        }
    }

    // MARK: - Traders Results

    private var tradersResultsView: some View {
        VStack(spacing: 12) {
            if filteredTraders.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.textMuted)
                    Text("No traders found")
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.textPrimary)
                    Text("Try another username, handle, or location.")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                ForEach(filteredTraders) { trader in
                    TraderRowCard(trader: trader, appState: appState, onDismiss: {
                        dismiss()
                    })
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .padding(.bottom, 24)
    }

    private func loadRegisteredTraders() {
        isLoadingTraders = true
        UserService.shared.fetchAllRegisteredUsers { result in
            DispatchQueue.main.async {
                self.isLoadingTraders = false
                if case .success(let users) = result {
                    self.registeredTraders = users
                }
            }
        }
    }
}

// MARK: - Trader Row Card

struct TraderRowCard: View {
    let trader: PublicUserProfile
    @ObservedObject var appState: AppState
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Avatar with gamer initial
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Text(String(trader.displayName.prefix(1)).uppercased())
                        .font(.title3.bold())
                        .foregroundColor(Theme.primary)
                }

                // Info
                VStack(alignment: .leading, spacing: 3) {
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

                    HStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 10))
                            Text(String(format: "%.1f", trader.rating))
                                .font(.caption2.bold())
                                .foregroundColor(Theme.textPrimary)
                        }

                        HStack(spacing: 2) {
                            Image(systemName: "mappin")
                                .foregroundColor(Theme.primary)
                                .font(.system(size: 10))
                            Text(trader.coarseLocation)
                                .font(.caption2)
                                .foregroundColor(Theme.textMuted)
                        }

                        if trader.listingsCount > 0 {
                            Text("• \(trader.listingsCount) items")
                                .font(.caption2.bold())
                                .foregroundColor(Theme.neonGreen)
                        }
                    }
                }

                Spacer()
            }

            // Action Buttons
            HStack(spacing: 10) {
                Button {
                    onDismiss()
                    appState.navigate(to: .otherProfile(userId: trader.id))
                } label: {
                    Text("View Profile")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Theme.surface)
                        .foregroundColor(Theme.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border, lineWidth: 1))
                }

                Button {
                    onDismiss()
                    appState.openOrCreateChat(
                        sellerId: trader.id,
                        sellerName: trader.displayName,
                        sellerHandle: trader.handle,
                        initialMessage: "Hi \(trader.displayName)! Connecting via GameTrade."
                    )
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.fill")
                        Text("Chat")
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Theme.buttonGradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(14)
        .background(Theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }
}
