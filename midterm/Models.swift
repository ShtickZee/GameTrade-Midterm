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

struct Review: Identifiable {
    let id = UUID()
    let reviewerName: String
    let rating: Double
    let comment: String
    let date: String
}
