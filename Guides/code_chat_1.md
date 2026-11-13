# GameTrade: Firebase Chat Models, Service & AppState (`code_chat_1.md`)

---

## Section 1: `midterm/Chat/ChatModels.swift`
Create or replace `midterm/Chat/ChatModels.swift` with the following complete Swift code. Remove any older mock definitions of `Chat` or `ChatMessage` from other files.

```swift
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
```

---

## Section 2: `midterm/Chat/ChatService.swift`
Create a new file at `midterm/Chat/ChatService.swift` with the following complete implementation:

```swift
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
```

---

## Section 3: Additions to `midterm/AppState.swift`

### 3A. Add `.chatDetail(chatId: String)` to `enum StackScreen: Hashable`
In `midterm/AppState.swift`, update `StackScreen` so it matches:

```swift
enum StackScreen: Hashable {
    case listing(listingId: String)
    case otherProfile(userId: String)
    case chatDetail(chatId: String)
    case search
    case notifications
    case saved
    case editProfile
}
```

### 3B. Add `@Published var activeChatId` and `openOrCreateChat(...)` to `class AppState`
Inside `class AppState: ObservableObject` in `midterm/AppState.swift`, add this property and method:

```swift
    @Published var activeChatId: String? = nil

    @MainActor
    func openOrCreateChat(
        sellerId: String,
        sellerName: String,
        sellerHandle: String = "@seller",
        listing: Listing? = nil,
        initialMessage: String? = nil,
        initialOfferAmount: Double? = nil,
        initialTradeItemTitle: String? = nil
    ) {
        Task { @MainActor in
            do {
                let chatId = try await ChatService.shared.getOrCreateChat(
                    currentUserName: self.userName,
                    currentUserHandle: self.userHandle,
                    otherUserId: sellerId,
                    otherUserName: sellerName,
                    otherUserHandle: sellerHandle,
                    listing: listing,
                    initialMessage: initialMessage,
                    initialOfferAmount: initialOfferAmount,
                    initialTradeItemTitle: initialTradeItemTitle
                )
                self.activeSheet = nil
                self.activeChatId = chatId
                self.navigate(to: .chatDetail(chatId: chatId))
            } catch {
                print("🔥 Failed to open or create chat: \(error.localizedDescription)")
                self.showToast("Could not open chat: \(error.localizedDescription)")
            }
        }
    }
```