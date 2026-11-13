import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class ChatService: ObservableObject {
    static let shared = ChatService()

    @Published var conversations: [ChatConversation] = []
    @Published var messages: [ChatMessage] = []
    @Published var isLoadingConversations: Bool = false
    @Published var isLoadingMessages: Bool = false
    @Published var lastError: String? = nil

    private let db = Firestore.firestore()
    private var conversationsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?

    private init() {}

    /// Current authenticated user's UID (or fallback for local previewing)
    var currentUid: String {
        Auth.auth().currentUser?.uid ?? "local_preview_user"
    }

    /// Generates a deterministic chat document ID so two users talking about the same listing always share one chat room
    func makeDeterministicChatId(uid1: String, uid2: String, listingId: String?) -> String {
        let sortedPair = [uid1, uid2].sorted().joined(separator: "_")
        if let listingId = listingId, !listingId.isEmpty {
            return "\(sortedPair)_\(listingId)"
        }
        return sortedPair
    }

    // MARK: - 1. Real-Time Conversations List Listener

    func listenToConversations() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.lastError = "Sign in to view your live messages."
            return
        }

        conversationsListener?.remove()
        isLoadingConversations = true
        lastError = nil

        // Note: We query by participantIds arrayContains and sort in memory so it works immediately
        // even before a composite index finishes building in the Firebase Console.
        conversationsListener = db.collection("chats")
            .whereField("participantIds", arrayContains: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isLoadingConversations = false

                    if let error = error {
                        print("🔥 [ChatService] Error listening to chats: \(error.localizedDescription)")
                        self.lastError = error.localizedDescription
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self.conversations = []
                        return
                    }

                    let fetched = documents.compactMap { ChatConversation.from(document: $0) }
                    self.conversations = fetched.sorted(by: { $0.lastTimestamp > $1.lastTimestamp })
                }
            }
    }

    // MARK: - 2. Real-Time Messages Listener for a Single Chat Room

    func listenToMessages(chatId: String) {
        guard !chatId.isEmpty else { return }

        messagesListener?.remove()
        isLoadingMessages = true
        lastError = nil

        messagesListener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isLoadingMessages = false

                    if let error = error {
                        print("🔥 [ChatService] Error listening to messages: \(error.localizedDescription)")
                        self.lastError = error.localizedDescription
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self.messages = []
                        return
                    }

                    self.messages = documents.compactMap { ChatMessage.from(document: $0) }
                    self.markChatAsRead(chatId: chatId)
                }
            }
    }

    func stopListeningToMessages() {
        messagesListener?.remove()
        messagesListener = nil
    }

    func stopAllListeners() {
        conversationsListener?.remove()
        conversationsListener = nil
        messagesListener?.remove()
        messagesListener = nil
        conversations = []
        messages = []
    }

    // MARK: - 3. Create or Fetch a Conversation Thread

    func getOrCreateChat(
        currentUserName: String,
        currentUserHandle: String,
        otherUserId: String,
        otherUserName: String,
        otherUserHandle: String = "@seller",
        listing: Listing? = nil,
        initialMessage: String? = nil,
        initialOfferAmount: Double? = nil,
        initialTradeItemTitle: String? = nil
    ) async throws -> String {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ChatService", code: 401, userInfo: [NSLocalizedDescriptionKey: "You must be logged in to start a chat."])
        }

        // Ensure we have two distinct participant IDs even if testing on one account
        let safeOtherId = (otherUserId == currentUid || otherUserId.isEmpty) ? "demo_seller_\(listing?.id ?? "store")" : otherUserId
        let chatId = makeDeterministicChatId(uid1: currentUid, uid2: safeOtherId, listingId: listing?.id)
        let chatRef = db.collection("chats").document(chatId)

        let snapshot = try await chatRef.getDocument()

        if !snapshot.exists {
            var chatData: [String: Any] = [
                "participantIds": [currentUid, safeOtherId],
                "participantNames": [
                    currentUid: currentUserName.isEmpty ? "Gamer" : currentUserName,
                    safeOtherId: otherUserName.isEmpty ? "Seller" : otherUserName
                ],
                "participantHandles": [
                    currentUid: currentUserHandle.isEmpty ? "@gamer" : currentUserHandle,
                    safeOtherId: otherUserHandle
                ],
                "lastMessage": initialMessage ?? (listing != nil ? "Interested in \(listing!.title)" : "Started a chat"),
                "lastTimestamp": FieldValue.serverTimestamp(),
                "lastSenderId": currentUid,
                "unreadCounts": [
                    currentUid: 0,
                    safeOtherId: 0
                ]
            ]

            if let listing = listing {
                chatData["listingId"] = listing.id
                chatData["listingTitle"] = listing.title
                chatData["listingPrice"] = listing.price
                chatData["listingImage"] = listing.images.first ?? ""
            }

            try await chatRef.setData(chatData)
        } else {
            // Keep current user's latest display name synced
            try? await chatRef.updateData([
                "participantNames.\(currentUid)": currentUserName,
                "participantHandles.\(currentUid)": currentUserHandle
            ])
        }

        // If an initial message, offer, or trade proposal was provided, send it immediately
        if let offerAmount = initialOfferAmount {
            let offerText = initialMessage ?? "Offered $\(Int(offerAmount)) for \(listing?.title ?? "this item")"
            try await sendMessage(
                chatId: chatId,
                text: offerText,
                recipientId: safeOtherId,
                messageType: .offer,
                offerAmount: offerAmount
            )
        } else if let tradeTitle = initialTradeItemTitle, !tradeTitle.isEmpty {
            let tradeText = initialMessage ?? "Proposed a trade: \(tradeTitle)"
            try await sendMessage(
                chatId: chatId,
                text: tradeText,
                recipientId: safeOtherId,
                messageType: .trade,
                tradeItemTitle: tradeTitle
            )
        } else if let text = initialMessage, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try await sendMessage(
                chatId: chatId,
                text: text,
                recipientId: safeOtherId,
                messageType: .text
            )
        }

        return chatId
    }

    // MARK: - 4. Send a Message Atomically Using WriteBatch

    func sendMessage(
        chatId: String,
        text: String,
        recipientId: String? = nil,
        messageType: ChatMessageType = .text,
        offerAmount: Double? = nil,
        tradeItemTitle: String? = nil
    ) async throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard let senderId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ChatService", code: 401, userInfo: [NSLocalizedDescriptionKey: "You must be logged in to send messages."])
        }

        let chatRef = db.collection("chats").document(chatId)
        let messageRef = chatRef.collection("messages").document()

        var messageData: [String: Any] = [
            "senderId": senderId,
            "text": trimmed,
            "timestamp": FieldValue.serverTimestamp(),
            "messageType": messageType.rawValue
        ]

        if let offerAmount = offerAmount {
            messageData["offerAmount"] = offerAmount
        }
        if let tradeItemTitle = tradeItemTitle {
            messageData["tradeItemTitle"] = tradeItemTitle
        }

        // Determine recipient UID to increment their unread counter
        let resolvedRecipientId: String
        if let recipientId = recipientId, !recipientId.isEmpty {
            resolvedRecipientId = recipientId
        } else if let existingConv = conversations.first(where: { $0.id == chatId }) {
            resolvedRecipientId = existingConv.otherParticipantId(currentUid: senderId)
        } else {
            resolvedRecipientId = ""
        }

        let batch = db.batch()
        batch.setData(messageData, forDocument: messageRef)

        var chatUpdate: [String: Any] = [
            "lastMessage": trimmed,
            "lastTimestamp": FieldValue.serverTimestamp(),
            "lastSenderId": senderId
        ]

        if !resolvedRecipientId.isEmpty {
            chatUpdate["unreadCounts.\(resolvedRecipientId)"] = FieldValue.increment(Int64(1))
        }

        batch.updateData(chatUpdate, forDocument: chatRef)
        try await batch.commit()
    }

    // MARK: - 5. Reset Unread Count When Viewing Chat

    func markChatAsRead(chatId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let chatRef = db.collection("chats").document(chatId)
        chatRef.updateData([
            "unreadCounts.\(uid)": 0
        ]) { _ in }
    }
}
