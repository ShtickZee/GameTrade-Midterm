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
    let title: String
    let price: Double
    let was: Double?
    let platform: Platform
    let condition: Condition
    let sellerId: String
    let location: String
    let saved: Bool
    let bundle: String?
    let images: [String]?
    let description: String?
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
