import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image Carousel (supports both asset images and remote URLs)
                    TabView {
                        ForEach(listing.images, id: \.self) { imageRef in
                            Group {
                                if imageRef.hasPrefix("http://") || imageRef.hasPrefix("https://") {
                                    AsyncImage(url: URL(string: imageRef)) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Theme.surfaceElevated)
                                            .overlay(ProgressView().tint(Theme.primary))
                                    }
                                } else {
                                    Image(imageRef)
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color.black.opacity(0.4))
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 320)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
                    .padding(.horizontal)

                    // Product Details
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(listing.platform.rawValue)
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.indigo)
                                .clipShape(Capsule())

                            Text(listing.condition.rawValue)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.cyberBlue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.surfaceElevated)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.border, lineWidth: 1))

                            Spacer()

                            if let was = listing.was, was > listing.price {
                                Text("Save $\(Int(was - listing.price))")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Theme.neonGreen)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Theme.neonGreen.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }

                        Text(listing.title)
                            .font(.title2.bold())
                            .foregroundColor(Theme.textPrimary)

                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("$\(Int(listing.price))")
                                .font(.system(size: 30, weight: .heavy))
                                .foregroundColor(Theme.cyberBlue)

                            if let was = listing.was {
                                Text("$\(Int(was))")
                                    .font(.title3)
                                    .strikethrough()
                                    .foregroundColor(Theme.textMuted)
                            }
                        }

                        Text(listing.description)
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)

                    // Seller Section (Steam / Gamer Card)
                    NavigationLink(value: StackScreen.otherProfile(userId: listing.sellerID)) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Theme.primary.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                Text(String(listing.sellerName.prefix(1)).uppercased())
                                    .font(.headline.bold())
                                    .foregroundColor(Theme.primary)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(listing.sellerName)
                                        .font(.subheadline.bold())
                                        .foregroundColor(Theme.textPrimary)

                                    if listing.isVerified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(Theme.cyberBlue)
                                            .font(.caption)
                                    }
                                }

                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption2)
                                    Text(String(format: "%.1f Rating", listing.sellerRating))
                                        .font(.caption2)
                                        .foregroundColor(Theme.textSecondary)

                                    Text("•")
                                        .font(.caption2)
                                        .foregroundColor(Theme.textMuted)

                                    Text(listing.location)
                                        .font(.caption2)
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(Theme.textMuted)
                                .font(.caption)
                        }
                        .padding(14)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal)
                    }

                    // Action Buttons (Steam / Cyber High Contrast)
                    HStack(spacing: 14) {
                        Button("Message") {
                            appState.openOrCreateChat(
                                sellerId: listing.sellerID,
                                sellerName: listing.sellerName,
                                sellerHandle: "@\(listing.sellerName.lowercased().replacingOccurrences(of: " ", with: ""))",
                                listing: listing,
                                initialMessage: "Hi \(listing.sellerName), is your \(listing.title) still available?"
                            )
                        }
                        .secondaryButtonStyle()

                        Button("Make Offer") {
                            appState.openOrCreateChat(
                                sellerId: listing.sellerID,
                                sellerName: listing.sellerName,
                                listing: listing,
                                initialOfferAmount: listing.price
                            )
                        }
                        .primaryButtonStyle()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(Theme.textPrimary)
                        .padding(8)
                        .background(Theme.surfaceElevated)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Theme.border, lineWidth: 1))
                }
            }
        }
    }
}
