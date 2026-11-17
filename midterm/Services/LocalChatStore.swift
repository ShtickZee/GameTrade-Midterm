import Foundation
import Combine

@MainActor
final class LocalChatStore: ObservableObject {
    static let shared = LocalChatStore()

    @Published var conversations: [ChatConversation] = []
    @Published var messagesByChat: [String: [ChatMessage]] = [:]

    private init() {
        seedInitialData()
    }

    private func seedInitialData() {
        let now = Date()
        let twoHoursAgo = now.addingTimeInterval(-7200)
        let oneHourAgo = now.addingTimeInterval(-3600)
        let thirtyMinsAgo = now.addingTimeInterval(-1800)
        let yesterday = now.addingTimeInterval(-86400)
        let twoDaysAgo = now.addingTimeInterval(-172800)
        let threeDaysAgo = now.addingTimeInterval(-259200)

        // Chat 1: Jordan - PS5
        let jordanChatId = "chat_jordan_ps5"
        let jordanChat = ChatConversation(
            id: jordanChatId,
            participantIds: ["current_user", "jordan"],
            participantNames: ["current_user": "You", "jordan": "Jordan"],
            participantHandles: ["current_user": "@trader", "jordan": "@jordan_trades"],
            listingId: "L1",
            listingTitle: "PS5 Disc Edition — 1TB",
            listingPrice: 430,
            listingImage: "PS5",
            lastMessage: "Yes, HDMI 2.1, power cord, and Dualsense are all included!",
            lastTimestamp: thirtyMinsAgo,
            lastSenderId: "jordan",
            unreadCounts: ["current_user": 1, "jordan": 0]
        )

        let jordanMessages = [
            ChatMessage(
                id: "msg_j1",
                senderId: "jordan",
                text: "Hey! Let me know if you have questions about the PS5.",
                timestamp: twoHoursAgo,
                messageType: .text
            ),
            ChatMessage(
                id: "msg_j2",
                senderId: "current_user",
                text: "Hi Jordan, does it come with all original cords and box?",
                timestamp: oneHourAgo,
                messageType: .text
            ),
            ChatMessage(
                id: "msg_j3",
                senderId: "jordan",
                text: "Yes, HDMI 2.1, power cord, and Dualsense are all included!",
                timestamp: thirtyMinsAgo,
                messageType: .text
            )
        ]

        // Chat 2: Mia - Xbox Series X with an Offer
        let miaChatId = "chat_mia_xbox"
        let miaChat = ChatConversation(
            id: miaChatId,
            participantIds: ["current_user", "mia"],
            participantNames: ["current_user": "You", "mia": "Mia"],
            participantHandles: ["current_user": "@trader", "mia": "@mia.trades"],
            listingId: "L2",
            listingTitle: "Xbox Series X — 1TB",
            listingPrice: 350,
            listingImage: "xbox_1",
            lastMessage: "I can do $330 cash pickup in Makati.",
            lastTimestamp: yesterday,
            lastSenderId: "mia",
            unreadCounts: ["current_user": 1, "mia": 0]
        )

        let miaMessages = [
            ChatMessage(
                id: "msg_m1",
                senderId: "mia",
                text: "Hello! Let me know if you want to trade or buy.",
                timestamp: yesterday.addingTimeInterval(-3600),
                messageType: .text
            ),
            ChatMessage(
                id: "msg_m2",
                senderId: "current_user",
                text: "Would you accept $320 for the Series X?",
                timestamp: yesterday.addingTimeInterval(-1800),
                messageType: .text
            ),
            ChatMessage(
                id: "msg_m3",
                senderId: "mia",
                text: "I can do $330 cash pickup in Makati.",
                timestamp: yesterday,
                messageType: .offer,
                offerAmount: 330
            )
        ]

        // Chat 3: GameHaven - Switch OLED with Trade Proposal
        let gamehavenChatId = "chat_gamehaven_switch"
        let gamehavenChat = ChatConversation(
            id: gamehavenChatId,
            participantIds: ["current_user", "gamehaven"],
            participantNames: ["current_user": "You", "gamehaven": "GameHaven"],
            participantHandles: ["current_user": "@trader", "gamehaven": "@gamehaven_ph"],
            listingId: "L3",
            listingTitle: "Nintendo Switch OLED — White",
            listingPrice: 280,
            listingImage: "Nintendo_switch_2_Fullspecwithgames",
            lastMessage: "Sounds good, where can we meet?",
            lastTimestamp: yesterday.addingTimeInterval(-43200),
            lastSenderId: "current_user",
            unreadCounts: ["current_user": 0, "gamehaven": 0]
        )

        let gamehavenMessages = [
            ChatMessage(
                id: "msg_g1",
                senderId: "current_user",
                text: "Hi! Would you be open to a trade for a PS4 Pro plus cash?",
                timestamp: threeDaysAgo,
                messageType: .text
            ),
            ChatMessage(
                id: "msg_g2",
                senderId: "gamehaven",
                text: "Proposed trade: PS4 Pro 1TB + $50 cash",
                timestamp: twoDaysAgo,
                messageType: .trade,
                tradeItemTitle: "PS4 Pro 1TB + $50"
            ),
            ChatMessage(
                id: "msg_g3",
                senderId: "current_user",
                text: "Sounds good, where can we meet?",
                timestamp: yesterday.addingTimeInterval(-43200),
                messageType: .text
            )
        ]

        self.conversations = [jordanChat, miaChat, gamehavenChat]
        self.messagesByChat = [
            jordanChatId: jordanMessages,
            miaChatId: miaMessages,
            gamehavenChatId: gamehavenMessages
        ]
    }

    func getOrCreateChat(
        currentUid: String,
        currentUserName: String,
        currentUserHandle: String,
        otherUserId: String,
        otherUserName: String,
        otherUserHandle: String = "@seller",
        listing: Listing? = nil,
        initialMessage: String? = nil,
        initialOfferAmount: Double? = nil,
        initialTradeItemTitle: String? = nil
    ) -> String {
        let safeOtherId = otherUserId.isEmpty ? "seller_\(UUID().uuidString.prefix(4))" : otherUserId
        let sortedPair = [currentUid, safeOtherId].sorted().joined(separator: "_")
        let chatId = listing != nil ? "\(sortedPair)_\(listing!.id)" : sortedPair

        if let existing = conversations.first(where: { $0.id == chatId }) {
            if let offerAmount = initialOfferAmount {
                addMessage(
                    chatId: chatId,
                    text: initialMessage ?? "Offered $\(Int(offerAmount))",
                    senderId: currentUid,
                    recipientId: safeOtherId,
                    messageType: .offer,
                    offerAmount: offerAmount
                )
            } else if let tradeTitle = initialTradeItemTitle {
                addMessage(
                    chatId: chatId,
                    text: initialMessage ?? "Proposed a trade: \(tradeTitle)",
                    senderId: currentUid,
                    recipientId: safeOtherId,
                    messageType: .trade,
                    tradeItemTitle: tradeTitle
                )
            } else if let msg = initialMessage, !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                addMessage(
                    chatId: chatId,
                    text: msg,
                    senderId: currentUid,
                    recipientId: safeOtherId,
                    messageType: .text
                )
            }
            return existing.id
        }

        let newConversation = ChatConversation(
            id: chatId,
            participantIds: [currentUid, safeOtherId],
            participantNames: [
                currentUid: currentUserName.isEmpty ? "You" : currentUserName,
                safeOtherId: otherUserName.isEmpty ? "Seller" : otherUserName
            ],
            participantHandles: [
                currentUid: currentUserHandle.isEmpty ? "@trader" : currentUserHandle,
                safeOtherId: otherUserHandle
            ],
            listingId: listing?.id,
            listingTitle: listing?.title,
            listingPrice: listing?.price,
            listingImage: listing?.images.first,
            lastMessage: initialMessage ?? (listing != nil ? "Interested in \(listing!.title)" : "Started a chat"),
            lastTimestamp: Date(),
            lastSenderId: currentUid,
            unreadCounts: [currentUid: 0, safeOtherId: 1]
        )

        conversations.insert(newConversation, at: 0)
        messagesByChat[chatId] = []

        if let offerAmount = initialOfferAmount {
            addMessage(
                chatId: chatId,
                text: initialMessage ?? "Offered $\(Int(offerAmount))",
                senderId: currentUid,
                recipientId: safeOtherId,
                messageType: .offer,
                offerAmount: offerAmount
            )
        } else if let tradeTitle = initialTradeItemTitle {
            addMessage(
                chatId: chatId,
                text: initialMessage ?? "Proposed a trade: \(tradeTitle)",
                senderId: currentUid,
                recipientId: safeOtherId,
                messageType: .trade,
                tradeItemTitle: tradeTitle
            )
        } else if let msg = initialMessage, !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            addMessage(
                chatId: chatId,
                text: msg,
                senderId: currentUid,
                recipientId: safeOtherId,
                messageType: .text
            )
        }

        return chatId
    }

    func addMessage(
        chatId: String,
        text: String,
        senderId: String,
        recipientId: String,
        messageType: ChatMessageType = .text,
        offerAmount: Double? = nil,
        tradeItemTitle: String? = nil
    ) {
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            senderId: senderId,
            text: text,
            timestamp: Date(),
            messageType: messageType,
            offerAmount: offerAmount,
            tradeItemTitle: tradeItemTitle
        )

        if messagesByChat[chatId] == nil {
            messagesByChat[chatId] = []
        }
        messagesByChat[chatId]?.append(newMessage)

        if let index = conversations.firstIndex(where: { $0.id == chatId }) {
            var updated = conversations[index]
            updated.lastMessage = text
            updated.lastTimestamp = Date()
            updated.lastSenderId = senderId
            let currentUnread = updated.unreadCounts[recipientId] ?? 0
            updated.unreadCounts[recipientId] = currentUnread + 1
            conversations.remove(at: index)
            conversations.insert(updated, at: 0)
        }
    }

    func deleteConversation(id: String) {
        conversations.removeAll { $0.id == id }
        messagesByChat.removeValue(forKey: id)
    }

    func markAllRead(chatId: String, userId: String) {
        if let index = conversations.firstIndex(where: { $0.id == chatId }) {
            conversations[index].unreadCounts[userId] = 0
        }
    }
}
