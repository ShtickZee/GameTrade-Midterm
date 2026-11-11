import Foundation
import CryptoKit

enum SecurityUtils {
    /// Generates a lowercase SHA-256 hex digest using Apple's native CryptoKit.
    /// Used for creating irreversible lookup hashes of normalized emails and phone numbers.
    static func sha256(_ input: String) -> String {
        let normalized = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let data = Data(normalized.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Normalizes a phone number to digits and leading '+' before hashing.
    static func normalizePhone(_ phone: String) -> String {
        let allowed = CharacterSet(charactersIn: "+0123456789")
        return phone.unicodeScalars.filter { allowed.contains($0) }.map(String.init).joined()
    }

    /// Extracts only a coarse city/region label for public display so exact street addresses
    /// or private coordinates are never exposed on public listings or profiles.
    /// Example: "123 Ayala Ave, Makati, Metro Manila" -> "Makati, Metro Manila"
    static func extractCoarseLocation(from rawLocation: String) -> String {
        let trimmed = rawLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Undisclosed" }
        
        let parts = trimmed
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if parts.count >= 2 {
            return parts.suffix(2).joined(separator: ", ")
        }
        return parts.first ?? "Undisclosed"
    }
}
