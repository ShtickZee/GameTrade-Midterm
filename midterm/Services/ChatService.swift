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
    private var conversationListener: ListenerRegistration?
    private var messageListener: ListenerRegistration?
    private var activeChatId: String? = nil
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    // MARK: - Current User

    /// The authenticated user's UID. Falls back to a local preview ID when not signed in.
    var currentUid: String {
        Auth.auth().currentUser?.uid ?? "local_preview_user"
    }

    // MARK: - Conversation Listener

    /// Attaches a real-time Firestore listener for conversations the current user is a participant in.
    func listenToConversations() {
        let uid = currentUid

        // If not authenticated, fall back to local store so the UI still shows mock data
        guard uid != "local_preview_user" else {
            conversations = LocalChatStore.shared.conversations
            isLoadingConversations = false
            return
        }

        isLoadingConversations = true
        lastError = nil

        conversationListener?.remove()
        conversationListener = db.collection("chats")
            .whereField("participantIds", arrayContains: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoadingConversations = false

                if let error = error {
                    print("⚠️ Firestore listenToConversations error: \(error.localizedDescription)")
                    self.lastError = error.localizedDescription
                    return
                }

                guard let snapshot = snapshot else { return }

                var loaded = snapshot.documents.compactMap {
                    ChatConversation.from(document: $0)
                }
                // Sort in memory by lastTimestamp descending so no composite index is required in Firebase Console
                loaded.sort { $0.lastTimestamp > $1.lastTimestamp }
                self.conversations = loaded
            }
    }

    func stopConversationListener() {
        conversationListener?.remove()
        conversationListener = nil
    }

    // MARK: - Message Listener

    /// Attaches a real-time Firestore listener for messages in a specific chat.
    func listenToMessages(chatId: String) {
        guard !chatId.isEmpty else { return }
        activeChatId = chatId
        isLoadingMessages = true
        lastError = nil

        // Fall back to local store when not authenticated
        guard currentUid != "local_preview_user" else {
            messages = LocalChatStore.shared.messagesByChat[chatId] ?? []
            markChatAsRead(chatId: chatId)
            isLoadingMessages = false
            return
        }

        messageListener?.remove()
        messageListener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoadingMessages = false

                if let error = error {
                    self.lastError = error.localizedDescription
                    return
                }

                guard let snapshot = snapshot else { return }

                var loaded = snapshot.documents.compactMap {
                    ChatMessage.from(document: $0)
                }
                loaded.sort { $0.timestamp < $1.timestamp }
                self.messages = loaded
                self.markChatAsRead(chatId: chatId)
            }
    }

    func stopListeningToMessages() {
        messageListener?.remove()
        messageListener = nil
        activeChatId = nil
    }

    func stopAllListeners() {
        stopConversationListener()
        stopListeningToMessages()
    }

    // MARK: - Get or Create Chat

    /// Looks for an existing conversation between the two users (optionally scoped to a listing).
    /// Creates one in Firestore if none exists, then returns the chat document ID.
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
        let uid = currentUid

        // Local fallback when unauthenticated
        guard uid != "local_preview_user" else {
            return LocalChatStore.shared.getOrCreateChat(
                currentUid: uid,
                currentUserName: currentUserName,
                currentUserHandle: currentUserHandle,
                otherUserId: otherUserId,
                otherUserName: otherUserName,
                otherUserHandle: otherUserHandle,
                listing: listing,
                initialMessage: initialMessage,
                initialOfferAmount: initialOfferAmount,
                initialTradeItemTitle: initialTradeItemTitle
            )
        }

        let safeOtherId = otherUserId.isEmpty ? "seller_unknown" : otherUserId
        let sortedPair = [uid, safeOtherId].sorted().joined(separator: "_")
        let chatId = listing != nil ? "\(sortedPair)_\(listing!.id)" : sortedPair

        let chatRef = db.collection("chats").document(chatId)
        let snapshot = try await chatRef.getDocument()

        if !snapshot.exists {
            // Create the chat document
            var chatData: [String: Any] = [
                "participantIds": [uid, safeOtherId],
                "participantNames": [
                    uid: currentUserName.isEmpty ? "You" : currentUserName,
                    safeOtherId: otherUserName.isEmpty ? "Seller" : otherUserName
                ],
                "participantHandles": [
                    uid: currentUserHandle.isEmpty ? "@trader" : currentUserHandle,
                    safeOtherId: otherUserHandle
                ],
                "lastMessage": initialMessage ?? (listing != nil ? "Interested in \(listing!.title)" : "Started a chat"),
                "lastTimestamp": FieldValue.serverTimestamp(),
                "lastSenderId": uid,
                "unreadCounts": [uid: 0, safeOtherId: 1]
            ]

            if let listing = listing {
                chatData["listingId"] = listing.id
                chatData["listingTitle"] = listing.title
                chatData["listingPrice"] = listing.price
                if let img = listing.images.first { chatData["listingImage"] = img }
            }

            try await chatRef.setData(chatData)
        }

        // Send initial message if provided
        if let offerAmount = initialOfferAmount {
            try await sendMessage(
                chatId: chatId,
                text: initialMessage ?? "Offered $\(Int(offerAmount))",
                recipientId: safeOtherId,
                messageType: .offer,
                offerAmount: offerAmount
            )
        } else if let tradeTitle = initialTradeItemTitle {
            try await sendMessage(
                chatId: chatId,
                text: initialMessage ?? "Proposed a trade: \(tradeTitle)",
                recipientId: safeOtherId,
                messageType: .trade,
                tradeItemTitle: tradeTitle
            )
        } else if let msg = initialMessage, !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try await sendMessage(
                chatId: chatId,
                text: msg,
                recipientId: safeOtherId,
                messageType: .text
            )
        }

        return chatId
    }

    // MARK: - Send Message

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

        let uid = currentUid

        // Local fallback when unauthenticated
        guard uid != "local_preview_user" else {
            let resolvedRecipient: String
            if let r = recipientId, !r.isEmpty {
                resolvedRecipient = r
            } else if let conv = LocalChatStore.shared.conversations.first(where: { $0.id == chatId }) {
                resolvedRecipient = conv.otherParticipantId(currentUid: uid)
            } else {
                resolvedRecipient = "seller"
            }
            LocalChatStore.shared.addMessage(
                chatId: chatId,
                text: trimmed,
                senderId: uid,
                recipientId: resolvedRecipient,
                messageType: messageType,
                offerAmount: offerAmount,
                tradeItemTitle: tradeItemTitle
            )
            conversations = LocalChatStore.shared.conversations
            messages = LocalChatStore.shared.messagesByChat[chatId] ?? []
            return
        }

        let resolvedRecipientId: String
        if let r = recipientId, !r.isEmpty {
            resolvedRecipientId = r
        } else {
            let snap = try await db.collection("chats").document(chatId).getDocument()
            let ids = snap.data()?["participantIds"] as? [String] ?? []
            resolvedRecipientId = ids.first(where: { $0 != uid }) ?? "unknown"
        }

        // Build the message document
        var msgData: [String: Any] = [
            "senderId": uid,
            "text": trimmed,
            "timestamp": FieldValue.serverTimestamp(),
            "messageType": messageType.rawValue
        ]
        if let amount = offerAmount { msgData["offerAmount"] = amount }
        if let title = tradeItemTitle { msgData["tradeItemTitle"] = title }

        // Write message + update conversation in a batch
        let batch = db.batch()

        let msgRef = db.collection("chats").document(chatId).collection("messages").document()
        batch.setData(msgData, forDocument: msgRef)

        let chatRef = db.collection("chats").document(chatId)
        batch.updateData([
            "lastMessage": trimmed,
            "lastTimestamp": FieldValue.serverTimestamp(),
            "lastSenderId": uid,
            "unreadCounts.\(resolvedRecipientId)": FieldValue.increment(Int64(1))
        ], forDocument: chatRef)

        try await batch.commit()
    }

    // MARK: - Mark as Read

    func markChatAsRead(chatId: String) {
        let uid = currentUid
        guard uid != "local_preview_user" else {
            LocalChatStore.shared.markAllRead(chatId: chatId, userId: uid)
            conversations = LocalChatStore.shared.conversations
            return
        }

        db.collection("chats").document(chatId).updateData([
            "unreadCounts.\(uid)": 0
        ]) { error in
            if let error = error {
                print("⚠️ markChatAsRead error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Delete Conversation

    /// Soft-delete: removes the conversation from the UI for this user.
    /// For a full delete you would also delete subcollection messages — skipped for safety.
    func deleteConversation(id: String) {
        guard currentUid != "local_preview_user" else {
            LocalChatStore.shared.deleteConversation(id: id)
            conversations = LocalChatStore.shared.conversations
            if activeChatId == id {
                messages = []
                activeChatId = nil
            }
            return
        }

        // Optimistically remove from local list
        conversations.removeAll { $0.id == id }
        if activeChatId == id {
            messages = []
            activeChatId = nil
        }

        // Remove current user from participantIds so their listener no longer picks it up
        db.collection("chats").document(id).updateData([
            "participantIds": FieldValue.arrayRemove([currentUid])
        ]) { error in
            if let error = error {
                print("⚠️ deleteConversation error: \(error.localizedDescription)")
            }
        }
    }
}
