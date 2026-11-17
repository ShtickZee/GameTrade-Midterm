import SwiftUI

struct ListingCardView: View {
    let listing: Listing

    private var platformColor: Color {
        switch listing.platform {
        case .ps5, .ps4: return Theme.playstation
        case .xbox: return Theme.xbox
        case .switchConsole: return Theme.nintendo
        }
    }

    private var discountPercentage: Int? {
        guard let was = listing.was, was > listing.price else { return nil }
        let diff = was - listing.price
        return Int((diff / was) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Product Image with Platform Badge Overlay
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let imageName = listing.images.first, !imageName.isEmpty {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .frame(height: 140)
                                .padding(8)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.surfaceElevated)
                                .frame(height: 140)
                                .overlay(
                                    Image(systemName: "gamecontroller.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(Theme.textMuted)
                                )
                        }
                    }
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Condition Badge on bottom-right of image
                    Text(listing.condition.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(6)
                }

                // Platform Badge on top-left of image
                HStack(spacing: 4) {
                    Circle()
                        .fill(platformColor)
                        .frame(width: 6, height: 6)
                    Text(listing.platform.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.85))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(platformColor.opacity(0.6), lineWidth: 1))
                .padding(6)
            }

            // Title
            Text(listing.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(2)
                .frame(minHeight: 38, alignment: .topLeading)

            // Steam-Style Price & Discount Row
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if let discount = discountPercentage {
                    // Steam green/blue discount pill
                    Text("-\(discount)%")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.neonGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 5))

                    if let was = listing.was {
                        Text("$\(Int(was))")
                            .font(.caption2)
                            .strikethrough()
                            .foregroundColor(Theme.textMuted)
                    }
                }

                Text("$\(Int(listing.price))")
                    .font(.headline.bold())
                    .foregroundColor(Theme.cyberBlue)

                Spacer()
            }

            // Seller Info & Location Row
            HStack(spacing: 4) {
                Text(listing.sellerName)
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)

                if listing.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.cyberBlue)
                }

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 9))
                    Text(listing.location)
                        .font(.system(size: 10))
                }
                .foregroundColor(Theme.textMuted)
            }
        }
        .padding(10)
        .gamingCard(cornerRadius: 16)
    }
}
