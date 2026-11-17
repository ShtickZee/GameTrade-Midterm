import SwiftUI
import Combine

struct CategoryItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let platform: Platform?
}

struct DealsHomeView: View {
    @ObservedObject var appState: AppState

    // Dynamic Mobbin-style Promo Banners
    let promoBanners: [PromoBannerItem] = [
        PromoBannerItem(
            id: "banner_ps5",
            badge: "⚡️ SPRING RESET SALE",
            title: "Trade in old console,\nlevel up to PS5",
            subtitle: "Get up to $250 trade value towards PS5 Slim",
            ctaText: "Trade PS5",
            imageName: "PS5_Slim_W_Controller",
            targetPlatform: .ps5,
            targetListingId: "L1",
            gradientHexes: ["7C3AED", "4338CA", "0284C7"]
        ),
        PromoBannerItem(
            id: "banner_xbox",
            badge: "🔥 VERIFIED STORE DROP",
            title: "Xbox Series X 1TB\nNow Available",
            subtitle: "Tested & certified by community hardware sellers",
            ctaText: "Explore Xbox",
            imageName: "xbox_series_s_1",
            targetPlatform: .xbox,
            targetListingId: "L2",
            gradientHexes: ["065F46", "047857", "10B981"]
        ),
        PromoBannerItem(
            id: "banner_switch",
            badge: "✨ HARDWARE SPOTLIGHT",
            title: "Nintendo Switch OLED\nFull Bundle",
            subtitle: "Comes with travel case & top multiplayer games",
            ctaText: "View Switch",
            imageName: "Nintendo_switch_2_Fullspecwithgames",
            targetPlatform: .switchConsole,
            targetListingId: "L3",
            gradientHexes: ["991B1B", "DC2626", "F43F5E"]
        )
    ]

    // Dynamic Steam-Style Flash Deals
    let flashDeals: [FlashDealCardItem] = [
        FlashDealCardItem(
            id: "deal_1",
            listingId: "L1",
            title: "PS5 Disc Edition — 1TB",
            platform: .ps5,
            currentPrice: 430,
            originalPrice: 499,
            imageName: "PS5",
            stockRemaining: 2,
            totalStock: 5
        ),
        FlashDealCardItem(
            id: "deal_2",
            listingId: "L2",
            title: "Xbox Series X — 1TB",
            platform: .xbox,
            currentPrice: 350,
            originalPrice: 420,
            imageName: "xbox_1",
            stockRemaining: 1,
            totalStock: 4
        ),
        FlashDealCardItem(
            id: "deal_3",
            listingId: "L3",
            title: "Switch OLED — White Bundle",
            platform: .switchConsole,
            currentPrice: 280,
            originalPrice: 320,
            imageName: "Nintendo_switch_2_Fullspecwithgames",
            stockRemaining: 3,
            totalStock: 6
        ),
        FlashDealCardItem(
            id: "deal_4",
            listingId: "L4",
            title: "PS5 DualSense Wireless",
            platform: .ps5,
            currentPrice: 65,
            originalPrice: 75,
            imageName: "dualsense_controller",
            stockRemaining: 4,
            totalStock: 8
        ),
        FlashDealCardItem(
            id: "deal_5",
            listingId: "L5",
            title: "PS4 Pro 1TB Console",
            platform: .ps4,
            currentPrice: 150,
            originalPrice: 180,
            imageName: "PS5_Slim_W_Controller",
            stockRemaining: 1,
            totalStock: 10
        )
    ]

    let categories: [CategoryItem] = [
        CategoryItem(title: "PlayStation", icon: "gamecontroller.fill", color: Theme.playstation, platform: .ps5),
        CategoryItem(title: "Xbox", icon: "xbox.logo", color: Theme.xbox, platform: .xbox),
        CategoryItem(title: "Switch", icon: "gamecontroller.fill", color: Theme.nintendo, platform: .switchConsole),
        CategoryItem(title: "Controllers", icon: "gamecontroller", color: Theme.cyberBlue, platform: nil),
        CategoryItem(title: "Bundles", icon: "shippingbox.fill", color: Theme.primary, platform: nil),
        CategoryItem(title: "Deals", icon: "bolt.fill", color: Color.orange, platform: nil),
        CategoryItem(title: "Stores", icon: "building.2.fill", color: Theme.neonGreen, platform: nil),
        CategoryItem(title: "Gear", icon: "headphones", color: Theme.textSecondary, platform: nil)
    ]

    @State private var promoIndex = 0
    let promoTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    @State private var timeRemaining = 2 * 3600 + 14 * 60 + 32
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d : %02d : %02d", hours, minutes, secs)
    }

    var body: some View {
        NavigationStack(path: $appState.dealsNavPath) {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header & Search
                        VStack(spacing: 14) {
                            HStack {
                                HStack(spacing: 4) {
                                    Text("Game")
                                        .font(.title2.bold())
                                        .foregroundColor(Theme.textPrimary)
                                    Text("Trade!")
                                        .font(.title2.bold())
                                        .foregroundColor(Theme.primary)
                                    Text("⚡️")
                                }

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

                            // Search Bar
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Theme.textSecondary)
                                Text("Search PS5, Xbox Series X, Switch...")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textMuted)
                                Spacer()
                            }
                            .padding(12)
                            .background(Theme.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
                            .padding(.horizontal)
                            .onTapGesture {
                                appState.activeSheet = .search
                            }
                        }

                        // Mobbin-Style Peeking Promo Carousel
                        VStack(spacing: 12) {
                            TabView(selection: $promoIndex) {
                                ForEach(Array(promoBanners.enumerated()), id: \.element.id) { index, banner in
                                    PromoHeroCard(banner: banner) {
                                        handleBannerAction(banner)
                                    }
                                    .tag(index)
                                    .padding(.horizontal, 16)
                                }
                            }
                            .frame(height: 175)
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .onReceive(promoTimer) { _ in
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    promoIndex = (promoIndex + 1) % promoBanners.count
                                }
                            }

                            // Story Progress Bar Indicators
                            HStack(spacing: 6) {
                                ForEach(0..<promoBanners.count, id: \.self) { i in
                                    Capsule()
                                        .fill(i == promoIndex ? Theme.cyberBlue : Theme.surfaceElevated)
                                        .frame(width: i == promoIndex ? 28 : 10, height: 4)
                                        .animation(.spring(response: 0.3), value: promoIndex)
                                        .onTapGesture {
                                            withAnimation { promoIndex = i }
                                        }
                                }
                            }
                        }

                        // Categories Grid (Actionable with Deep Linking)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Browse by category")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 14) {
                                ForEach(categories) { cat in
                                    Button {
                                        if let platform = cat.platform {
                                            appState.selectedMarketPlatform = platform
                                            appState.switchTab(.market)
                                        }
                                    } label: {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(Theme.surfaceElevated)
                                                    .frame(width: 56, height: 56)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .stroke(Theme.border, lineWidth: 1)
                                                    )
                                                Image(systemName: cat.icon)
                                                    .font(.title3)
                                                    .foregroundColor(cat.color)
                                            }

                                            Text(cat.title)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(Theme.textSecondary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Steam-Style Flash Deals Section (Interactive Deal Cards)
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                HStack(spacing: 6) {
                                    Text("⚡️")
                                    Text("Flash Deals")
                                        .font(.headline.bold())
                                        .foregroundColor(Theme.textPrimary)
                                }

                                Spacer()

                                HStack(spacing: 6) {
                                    Image(systemName: "timer")
                                        .font(.caption)
                                    Text(formatTime(timeRemaining))
                                        .font(.system(.caption, design: .monospaced).bold())
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Theme.surfaceElevated)
                                .foregroundColor(Theme.cyberBlue)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.cyberBlue.opacity(0.4), lineWidth: 1))
                                .onReceive(countdownTimer) { _ in
                                    if timeRemaining > 0 { timeRemaining -= 1 }
                                }
                            }
                            .padding(.horizontal, 16)

                            // Horizontal Scrolling Steam Deal Cards
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(flashDeals) { deal in
                                        Button {
                                            appState.navigate(to: .listing(listingId: deal.listingId))
                                        } label: {
                                            FlashDealCardView(deal: deal)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
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

    private func handleBannerAction(_ banner: PromoBannerItem) {
        if let platform = banner.targetPlatform {
            appState.selectedMarketPlatform = platform
            appState.switchTab(.market)
        } else if let listingId = banner.targetListingId {
            appState.navigate(to: .listing(listingId: listingId))
        }
    }
}

// MARK: - Mobbin-Style Promo Hero Card

struct PromoHeroCard: View {
    let banner: PromoBannerItem
    let action: () -> Void

    private var cardGradient: LinearGradient {
        let colors = banner.gradientHexes.map { Color(hex: $0) }
        return LinearGradient(
            colors: colors.isEmpty ? [Theme.primary, Theme.indigo] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(banner.badge)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Capsule())

                    Text(banner.title)
                        .font(.headline.bold())
                        .foregroundColor(Color.white)
                        .lineLimit(2)

                    Text(banner.subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.85))
                        .lineLimit(1)

                    Button(action: action) {
                        HStack(spacing: 4) {
                            Text(banner.ctaText)
                                .font(.system(size: 12, weight: .bold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: Color.black.opacity(0.25), radius: 4)
                    }
                    .padding(.top, 4)
                }
                .padding(.leading, 20)

                Spacer()

                Image(banner.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 105, height: 105)
                    .shadow(color: Color.black.opacity(0.4), radius: 8)
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 165)
    }
}

// MARK: - Steam-Style Flash Deal Card

struct FlashDealCardView: View {
    let deal: FlashDealCardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image with Floating Discount & Platform Pills
            ZStack(alignment: .topLeading) {
                Image(deal.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 110)
                    .padding(6)
                    .background(Color.black.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Discount percentage pill
                Text("-\(deal.discountPercentage)%")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.neonGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(6)
            }

            // Title
            Text(deal.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
                .frame(width: 140, alignment: .leading)

            // Price Row
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("$\(Int(deal.currentPrice))")
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.cyberBlue)

                Text("$\(Int(deal.originalPrice))")
                    .font(.caption2)
                    .strikethrough()
                    .foregroundColor(Theme.textMuted)
            }

            // Urgency Indicator & Progress Bar
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(deal.stockRemaining <= 2 ? "🔥 Only \(deal.stockRemaining) left" : "\(deal.stockRemaining) in stock")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(deal.stockRemaining <= 2 ? Color.orange : Theme.textSecondary)
                    Spacer()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.surfaceElevated)
                            .frame(height: 4)

                        Capsule()
                            .fill(deal.stockRemaining <= 2 ? Color.orange : Theme.cyberBlue)
                            .frame(width: geo.size.width * CGFloat(deal.claimedRatio), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(width: 140)
        }
        .padding(10)
        .background(Theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }
}
