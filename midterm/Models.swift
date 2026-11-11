import Foundation

enum Platform: String, Codable {
    case ps5 = "PS5"
    case ps4 = "PS4"
    case xbox = "XBOX"
    case switchConsole = "SWITCH"
}

enum Condition: String, Codable {
    case likeNew = "Like New"
    case good = "Good"
    case fair = "Fair"
    case forParts = "For Parts"
}

struct Listing: Identifiable, Codable {
    let id: String
    var title: String
    var price: Double
    var was: Double?
    var platform: Platform
    var condition: Condition
    var sellerID: String
    var sellerName: String
    var sellerAvatar: String
    var sellerRating: Double
    var isVerified: Bool
    var location: String
    var saved: Bool
    var bundle: String?
    var images: [String]
    var description: String
}

struct Seller: Identifiable, Codable {
    let id: String
    let name: String
    let handle: String?
    let rating: Double
    let reviews: Int
    let verified: Bool
    let officialStore: Bool
    let topSeller: Bool
    let listingsCount: Int
    let soldCount: Int
    let responseTime: String?
    let avatar: String?
}

struct Review: Identifiable, Codable {
    var id = UUID()
    let reviewerName: String
    let rating: Double
    let comment: String
    let date: String
}

// MARK: - Phase 1 User Account & Privacy Split Models

enum UserRole: String, Codable {
    case standardUser = "standard_user"
}

/// Stored at `users/{uid}` — Safe to be read by any authenticated user browsing the marketplace.
/// Contains NO email, NO phone number, and NO exact street address/coordinates.
struct PublicUserProfile: Identifiable, Codable {
    let id: String                 // Matches FirebaseAuth uid
    var name: String?              // Optional full/display name
    var handle: String             // e.g. "@alextrades"
    var bio: String
    var coarseLocation: String     // City/Region only (e.g. "Makati")
    var avatarURL: String?         // Firebase Storage download URL
    var role: UserRole
    var rating: Double
    var reviewsCount: Int
    var verified: Bool
    var listingsCount: Int
    var soldCount: Int
    var createdAt: TimeInterval

    /// Computed display name that falls back to handle if optional name is nil or empty
    var displayName: String {
        if let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return handle
    }
}

/// Stored at `users/{uid}/private/sensitive` — Strictly locked down via Firestore Security Rules
/// so ONLY `request.auth.uid == uid` can ever read or write this document.
struct PrivateUserData: Codable {
    let uid: String
    var email: String
    var emailHash: String          // SHA-256 digest via CryptoKit
    var phoneNumber: String
    var phoneHash: String          // SHA-256 digest via CryptoKit
    var exactLocation: String      // Full private location string / coordinates
    var updatedAt: TimeInterval
}
