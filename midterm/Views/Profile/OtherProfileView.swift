import SwiftUI
import FirebaseFirestore

struct OtherProfileView: View {
    let userId: String
    var initialUserName: String? = nil
    var initialRating: Double? = nil
    var initialBio: String? = nil
    var reviews: [Review] = []

    @ObservedObject var appState: AppState

    @State private var profile: PublicUserProfile? = nil
    @State private var isLoading: Bool = true
    @State private var selectedTab: Int = 0 // 0: Listings, 1: Reviews, 2: About

    init(
        userId: String,
        userName: String? = nil,
        rating: Double? = nil,
        bio: String? = nil,
        reviews: [Review] = [],
        appState: AppState = AppState()
    ) {
        self.userId = userId
        self.initialUserName = userName
        self.initialRating = rating
        self.initialBio = bio
        self.reviews = reviews
        self.appState = appState
    }

    private var displayName: String {
        if let p = profile, !p.displayName.isEmpty {
            return p.displayName
        }
        if let name = initialUserName, !name.isEmpty {
            return name
        }
        return defaultName(for: userId)
    }

    private var userHandle: String {
        profile?.handle ?? defaultHandle(for: userId)
    }

    private var userRating: Double {
        profile?.rating ?? initialRating ?? 4.8
    }

    private var userBio: String {
        profile?.bio.isEmpty == false ? profile!.bio : (initialBio ?? "Passionate gamer and console collector.")
    }

    private var userLocation: String {
        profile?.coarseLocation.isEmpty == false ? profile!.coarseLocation : "Makati, PH"
    }

    private var userListings: [Listing] {
        appState.listings.filter { $0.sellerID == userId }
    }

    private var userReviews: [Review] {
        if !reviews.isEmpty { return reviews }
        return defaultReviews(for: userId)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Hero Profile Banner
                    headerBanner

                    // Profile Info & Action Buttons
                    profileDetailsSection
                        .padding(.top, 46)
                        .padding(.horizontal, 16)

                    // Tab Picker (Listings / Reviews / About)
                    Picker("Profile Section", selection: $selectedTab) {
                        Text("Listings (\(userListings.count))").tag(0)
                        Text("Reviews (\(userReviews.count))").tag(1)
                        Text("About").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    // Tab Content
                    Group {
                        switch selectedTab {
                        case 0:
                            listingsSection
                        case 1:
                            reviewsSection
                        case 2:
                            aboutSection
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProfile()
            if appState.listings.isEmpty {
                appState.fetchListings()
            }
        }
    }

    // MARK: - Header Banner

    private var headerBanner: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Theme.primary.opacity(0.8), Theme.indigo, Theme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(0.2))
            )

            // Overlapping Avatar Circle
            ZStack {
                Circle()
                    .fill(Theme.surfaceElevated)
                    .frame(width: 86, height: 86)
                    .overlay(
                        Text(String(displayName.prefix(1)).uppercased())
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Theme.primary)
                    )
                    .overlay(Circle().stroke(Theme.background, lineWidth: 4))
                    .shadow(color: Theme.primary.opacity(0.3), radius: 8)

                // Online indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Theme.background, lineWidth: 2.5))
                    .offset(x: 28, y: 28)
            }
            .offset(y: 43)
        }
    }

    // MARK: - Profile Details & Action Buttons

    private var profileDetailsSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Text(displayName)
                    .font(.title3.bold())
                    .foregroundColor(Theme.textPrimary)

                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Theme.cyberBlue)
                    .font(.subheadline)
            }

            Text(userHandle)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)

            // Rating & Location Pill
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", userRating))
                        .font(.caption.bold())
                        .foregroundColor(Theme.textPrimary)
                    Text("(\(userReviews.count))")
                        .font(.caption2)
                        .foregroundColor(Theme.textMuted)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Theme.surfaceElevated)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.border, lineWidth: 1))

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(Theme.primary)
                        .font(.caption)
                    Text(userLocation)
                        .font(.caption.weight(.medium))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Theme.surfaceElevated)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
            }
            .padding(.top, 2)

            Text(userBio)
                .font(.footnote)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 4)

            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    appState.openOrCreateChat(
                        sellerId: userId,
                        sellerName: displayName,
                        sellerHandle: userHandle,
                        initialMessage: "Hi \(displayName)! I'm interested in your listings."
                    )
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Message")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Theme.buttonGradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Theme.primary.opacity(0.35), radius: 6)
                }

                Button {
                    if let firstListing = userListings.first {
                        appState.openOrCreateChat(
                            sellerId: userId,
                            sellerName: displayName,
                            sellerHandle: userHandle,
                            listing: firstListing,
                            initialMessage: "Hi \(displayName), would you consider $\(Int(firstListing.price * 0.9)) for \(firstListing.title)?",
                            initialOfferAmount: firstListing.price * 0.9
                        )
                    } else {
                        appState.openOrCreateChat(
                            sellerId: userId,
                            sellerName: displayName,
                            sellerHandle: userHandle,
                            initialMessage: "Hi \(displayName), I'd like to make an offer on your items."
                        )
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "tag.fill")
                        Text("Make Offer")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Theme.surfaceElevated)
                    .foregroundColor(Theme.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                }
            }
            .padding(.top, 12)
        }
    }

    // MARK: - Listings Section (with consistent ListingCardView + Chat on Item button)

    private var listingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if userListings.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.textMuted)
                    Text("No Active Listings")
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.textPrimary)
                    Text("\(displayName) doesn't have any items for sale or trade right now.")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
                    ForEach(userListings) { listing in
                        VStack(spacing: 8) {
                            NavigationLink(value: StackScreen.listing(listingId: listing.id)) {
                                ListingCardView(listing: listing)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // Dedicated "Chat on Item" Button
                            Button {
                                appState.openOrCreateChat(
                                    sellerId: userId,
                                    sellerName: displayName,
                                    sellerHandle: userHandle,
                                    listing: listing,
                                    initialMessage: "Hi \(displayName), is this \(listing.title) still available?"
                                )
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "bubble.left.fill")
                                        .font(.caption2)
                                    Text("Chat")
                                        .font(.caption.bold())
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                                .background(Theme.primary.opacity(0.15))
                                .foregroundColor(Theme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.primary.opacity(0.3), lineWidth: 1))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Reviews Section

    private var reviewsSection: some View {
        VStack(spacing: 12) {
            ForEach(userReviews) { review in
                ReviewCard(
                    reviewerName: review.reviewerName,
                    rating: review.rating,
                    comment: review.comment,
                    date: review.date
                )
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Trader Stats")
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)

                HStack(spacing: 12) {
                    statBox(title: "Completed Trades", value: "24", icon: "arrow.triangle.2.circlepath")
                    statBox(title: "Response Time", value: "< 15 mins", icon: "bolt.fill")
                    statBox(title: "Member Since", value: "2024", icon: "calendar")
                }
            }
            .padding(14)
            .background(Theme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))

            VStack(alignment: .leading, spacing: 8) {
                Text("Trust & Verification")
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)

                VStack(spacing: 8) {
                    trustRow(icon: "checkmark.shield.fill", color: Theme.neonGreen, title: "Identity Verified", subtitle: "Government ID verified with GameTrade")
                    trustRow(icon: "phone.fill", color: Theme.cyberBlue, title: "Phone Verified", subtitle: "Confirmed mobile number on file")
                    trustRow(icon: "hand.thumbsup.fill", color: Theme.primary, title: "Top Rated Seller", subtitle: "Consistently rated 4.8+ stars by community")
                }
            }
            .padding(14)
            .background(Theme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
        }
    }

    private func statBox(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Theme.primary)
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(Theme.textPrimary)
            Text(title)
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func trustRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(Theme.textPrimary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }
            Spacer()
        }
    }

    // MARK: - Dynamic Data Fetching

    private func loadProfile() {
        // First check if this is a real Firebase UID
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), snapshot?.exists == true {
                let loaded = PublicUserProfile(
                    id: self.userId,
                    name: data["name"] as? String,
                    handle: data["handle"] as? String ?? self.defaultHandle(for: self.userId),
                    bio: data["bio"] as? String ?? "",
                    coarseLocation: data["coarseLocation"] as? String ?? "Makati",
                    avatarURL: data["avatarURL"] as? String,
                    role: .standardUser,
                    rating: data["rating"] as? Double ?? 4.9,
                    reviewsCount: data["reviewsCount"] as? Int ?? 3,
                    verified: data["verified"] as? Bool ?? true,
                    listingsCount: data["listingsCount"] as? Int ?? self.userListings.count,
                    soldCount: data["soldCount"] as? Int ?? 5,
                    createdAt: data["createdAt"] as? Double ?? 0
                )
                DispatchQueue.main.async {
                    self.profile = loaded
                    self.isLoading = false
                }
            } else {
                // Graceful fallback to pre-seeded mock profile
                DispatchQueue.main.async {
                    self.profile = self.mockProfile(for: self.userId)
                    self.isLoading = false
                }
            }
        }
    }

    private func defaultName(for id: String) -> String {
        switch id {
        case "jordan": return "Jordan"
        case "mia": return "Mia"
        case "gamehaven": return "GameHaven"
        case "alfye": return "Alfye Reyes"
        case "alex": return "Alex"
        default: return "Trader"
        }
    }

    private func defaultHandle(for id: String) -> String {
        switch id {
        case "jordan": return "@jordan_trades"
        case "mia": return "@mia.trades"
        case "gamehaven": return "@gamehaven_ph"
        case "alfye": return "@alfye_gaming"
        case "alex": return "@alex_retro"
        default: return "@trader"
        }
    }

    private func mockProfile(for id: String) -> PublicUserProfile {
        PublicUserProfile(
            id: id,
            name: defaultName(for: id),
            handle: defaultHandle(for: id),
            bio: {
                switch id {
                case "jordan": return "Passionate PlayStation fan. Upgrading my setup!"
                case "mia": return "Xbox enthusiast and competitive Halo player."
                case "gamehaven": return "Retro and next-gen gaming boutique in BGC."
                case "alfye": return "Collector of rare DualSense controllers and consoles."
                default: return "Casual gamer and verified GameTrade community member."
                }
            }(),
            coarseLocation: {
                switch id {
                case "jordan": return "Quezon City"
                case "mia": return "Makati"
                case "gamehaven": return "BGC, Taguig"
                case "alfye": return "Quezon City"
                default: return "Metro Manila"
                }
            }(),
            avatarURL: nil,
            role: .standardUser,
            rating: 4.8,
            reviewsCount: 6,
            verified: true,
            listingsCount: userListings.count,
            soldCount: 8,
            createdAt: Date().timeIntervalSince1970
        )
    }

    private func defaultReviews(for id: String) -> [Review] {
        [
            Review(reviewerName: "Marco S.", rating: 5, comment: "Super fast deal and console was exactly as described!", date: "Yesterday"),
            Review(reviewerName: "Kenji R.", rating: 5, comment: "Punctual meet-up in Makati. Smooth transaction.", date: "3 days ago"),
            Review(reviewerName: "Sarah J.", rating: 4, comment: "Great communication throughout the trade.", date: "1 week ago")
        ]
    }
}
