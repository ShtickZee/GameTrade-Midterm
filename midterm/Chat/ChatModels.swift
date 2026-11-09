import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let senderId: String
    let text: String
    let timestamp: Date
    var isFromCurrentUser: Bool
}

struct Chat: Identifiable {
    let id = UUID()
    let otherUserId: String
    let otherUserName: String
    let lastMessage: String
    let lastMessageTimestamp: Date
    var messages: [ChatMessage]
}
