import Foundation
import FirebaseFirestore

// Backward-compatible typealias so any existing view referencing `Chat` still compiles
typealias Chat = ChatConversation

enum ChatMessageType: String, Codable {
    case text = "text"
    case offer = "offer"
    case trade = "trade"
}

struct ChatConversation: Identifiable, Codable, Hashable {
    var id: String
    var participantIds: [String]
    var participantNames: [String: String]
    var participantHandles: [String: String]
    var listingId: String?
    var listingTitle: String?
    var listingPrice: Double?
    var listingImage: String?
    var lastMessage: String
    var lastTimestamp: Date
    var lastSenderId: String
    var unreadCounts: [String: Int]

    /// Returns the other participant's UID given the current logged-in UID
    func otherParticipantId(currentUid: String) -> String {
        participantIds.first(where: { $0 != currentUid }) ?? participantIds.first ?? "unknown_user"
    }

    /// Returns the display name of the other participant
    func otherParticipantName(currentUid: String) -> String {
        let otherId = otherParticipantId(currentUid: currentUid)
        if let name = participantNames[otherId], !name.trimmingCharacters(in: .whitespaces).isEmpty {
            return name
        }
        return "Trader"
    }

    /// Returns the @handle of the other participant
    func otherParticipantHandle(currentUid: String) -> String {
        let otherId = otherParticipantId(currentUid: currentUid)
        return participantHandles[otherId] ?? "@trader"
    }

    /// Returns the unread count for the current user
    func unreadCount(for currentUid: String) -> Int {
        unreadCounts[currentUid] ?? 0
    }

    /// Returns a human-readable relative time string for the conversation list
    var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastTimestamp, relativeTo: Date())
    }

    /// Constructs a ChatConversation safely from a Firestore DocumentSnapshot
    static func from(document: DocumentSnapshot) -> ChatConversation? {
        guard let data = document.data() else { return nil }

        let id = document.documentID
        let participantIds = data["participantIds"] as? [String] ?? []
        let participantNames = data["participantNames"] as? [String: String] ?? [:]
        let participantHandles = data["participantHandles"] as? [String: String] ?? [:]
        let listingId = data["listingId"] as? String
        let listingTitle = data["listingTitle"] as? String
        let listingPrice = data["listingPrice"] as? Double
        let listingImage = data["listingImage"] as? String
        let lastMessage = data["lastMessage"] as? String ?? "Started a conversation"
        let lastSenderId = data["lastSenderId"] as? String ?? ""
        let unreadCounts = data["unreadCounts"] as? [String: Int] ?? [:]

        let lastTimestamp: Date
        if let ts = data["lastTimestamp"] as? Timestamp {
            lastTimestamp = ts.dateValue()
        } else if let date = data["lastTimestamp"] as? Date {
            lastTimestamp = date
        } else {
            lastTimestamp = Date()
        }

        return ChatConversation(
            id: id,
            participantIds: participantIds,
            participantNames: participantNames,
            participantHandles: participantHandles,
            listingId: listingId,
            listingTitle: listingTitle,
            listingPrice: listingPrice,
            listingImage: listingImage,
            lastMessage: lastMessage,
            lastTimestamp: lastTimestamp,
            lastSenderId: lastSenderId,
            unreadCounts: unreadCounts
        )
    }
}

struct ChatMessage: Identifiable, Codable, Hashable {
    var id: String
    var senderId: String
    var text: String
    var timestamp: Date
    var messageType: ChatMessageType
    var offerAmount: Double?
    var tradeItemTitle: String?

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    static func from(document: DocumentSnapshot) -> ChatMessage? {
        guard let data = document.data() else { return nil }

        let id = document.documentID
        let senderId = data["senderId"] as? String ?? ""
        let text = data["text"] as? String ?? ""
        let rawType = data["messageType"] as? String ?? "text"
        let messageType = ChatMessageType(rawValue: rawType) ?? .text
        let offerAmount = data["offerAmount"] as? Double
        let tradeItemTitle = data["tradeItemTitle"] as? String

        let timestamp: Date
        if let ts = data["timestamp"] as? Timestamp {
            timestamp = ts.dateValue()
        } else if let date = data["timestamp"] as? Date {
            timestamp = date
        } else {
            timestamp = Date()
        }

        return ChatMessage(
            id: id,
            senderId: senderId,
            text: text,
            timestamp: timestamp,
            messageType: messageType,
            offerAmount: offerAmount,
            tradeItemTitle: tradeItemTitle
        )
    }
}
