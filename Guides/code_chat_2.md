# GameTrade: Real-Time Chat Views & Screen Connections (`code_chat_2.md`)

---

## Section 1: `midterm/Chat/ChatListView.swift`
Replace the entire contents of `midterm/Chat/ChatListView.swift` with the following code:

```swift
import SwiftUI
import FirebaseAuth

struct ChatListView: View {
    @ObservedObject var appState: AppState
    @StateObject private var chatService = ChatService.shared

    // Default initializer so existing calls like `ChatListView()` without arguments still compile
    init(appState: AppState = AppState()) {
        self.appState = appState
    }

    var body: some View {
        VStack(spacing: 0) {
            if let error = chatService.lastError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Retry") {
                        chatService.listenToConversations()
                    }
                    .font(.caption.bold())
                    .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.85))
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
            }

            if chatService.isLoadingConversations && chatService.conversations.isEmpty {
                Spacer()
                ProgressView("Loading conversations...")
                    .tint(Color(red: 0.36, green: 0.18, blue: 0.85))
                Spacer()
            } else if chatService.conversations.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(chatService.conversations) { conversation in
                        NavigationLink {
                            ChatDetailView(chat: conversation, appState: appState)
                        } label: {
                            ChatConversationRow(
                                conversation: conversation,
                                currentUid: chatService.currentUid
                            )
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    chatService.listenToConversations()
                }
            }
        }
        .navigationTitle("Messages")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    startQuickTestChat()
                } label: {
                    Label("New Test Chat", systemImage: "plus.bubble.fill")
                        .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.85))
                }
            }
        }
        .onAppear {
            chatService.listenToConversations()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 54))
                .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.85).opacity(0.75))

            Text("No Messages Yet")
                .font(.title3)
                .fontWeight(.bold)

            Text("Tap 'Message Seller' on any console or game listing to start negotiating in real time.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            Button {
                startQuickTestChat()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Start Sample Seller Chat")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(red: 0.36, green: 0.18, blue: 0.85))
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            .padding(.top, 6)

            Spacer()
        }
    }

    private func startQuickTestChat() {
        Task { @MainActor in
            do {
                let sampleListing = Listing(
                    id: "sample_ps5_disc",
                    title: "PlayStation 5 Disc Edition + 2 Controllers",
                    price: 420,
                    was: 499,
                    platform: .ps5,
                    condition: .likeNew,
                    sellerID: "demo_seller_makati",
                    sellerName: "Marco Santos",
                    sellerAvatar: "M",
                    sellerRating: 4.9,
                    isVerified: true,
                    location: "Makati",
                    saved: false,
                    bundle: "Includes Spider-Man 2",
                    images: [],
                    description: "Complete with box and original HDMI 2.1 cable."
                )

                _ = try await chatService.getOrCreateChat(
                    currentUserName: appState.userName,
                    currentUserHandle: appState.userHandle,
                    otherUserId: sampleListing.sellerID,
                    otherUserName: sampleListing.sellerName,
                    otherUserHandle: "@marcotrades",
                    listing: sampleListing,
                    initialMessage: "Hi! Is this PS5 bundle still available?"
                )
            } catch {
                appState.showToast("Sign in first to create a Firestore chat.")
            }
        }
    }
}

struct ChatConversationRow: View {
    let conversation: ChatConversation
    let currentUid: String

    var body: some View {
        let otherName = conversation.otherParticipantName(currentUid: currentUid)
        let unread = conversation.unreadCount(for: currentUid)

        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.36, green: 0.18, blue: 0.85).opacity(0.15))
                    .frame(width: 52, height: 52)

                Text(String(otherName.prefix(1)).uppercased())
                    .font(.title3.bold())
                    .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.85))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherName)
                        .font(.subheadline)
                        .fontWeight(unread > 0 ? .bold : .semibold)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(conversation.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                if let listingTitle = conversation.listingTitle, !listingTitle.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.caption2)
                        Text(listingTitle)
                            .font(.caption)
                            .lineLimit(1)
                        if let price = conversation.listingPrice {
                            Text("• $\(Int(price))")
                                .font(.caption.bold())
                        }
                    }
                    .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.85))
                }

                HStack {
                    Text(conversation.lastMessage)
                        .font(.footnote)
                        .foregroundColor(unread > 0 ? .primary : .secondary)
                        .fontWeight(unread > 0 ? .semibold : .regular)
                        .lineLimit(1)

                    Spacer()

                    if unread > 0 {
                        Text("\(unread)")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color(red: 0.36, green: 0.18, blue: 0.85))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
```

---

## Section 2: `midterm/Chat/ChatDetailView.swift`
Replace the entire contents of `midterm/Chat/ChatDetailView.swift` with the following code:

```swift
import SwiftUI
import FirebaseAuth

struct ChatDetailView: View {
    let chatId: String
    var initialChat: ChatConversation?
    @ObservedObject var appState: AppState

    @StateObject private var chatService = ChatService.shared
    @State private var messageText: String = ""
    @State private var showingQuickOfferSheet: Bool = false
    @State private var quickOfferAmount: String = ""

    // Initializer 1: From a ChatConversation model (used by NavigationLink in ChatListView)
    init(chat: ChatConversation, appState: AppState = AppState()) {
        self.chatId = chat.id
        self.initialChat = chat
        self.appState = appState
    }

    // Initializer 2: From a chatId String (used by StackScreen.chatDetail(chatId:))
    init(chatId: String, appState: AppState = AppState()) {
        self.chatId = chatId
        self.initialChat = ChatService.shared.conversations.first(where: { $0.id == chatId })
        self.appState = appState
    }

    private var activeConversation: ChatConversation? {
        chatService.conversations.first(where: { $0.id == chatId }) ?? initialChat
    }

    private var otherPartnerName: String {
        activeConversation?.otherParticipantName(currentUid: chatService.currentUid) ?? "Seller"
    }

    private var otherPartnerId: String {
        activeConversation?.otherParticipantId(currentUid: chatService.currentUid) ?? ""
    }

    var body: some View {
        VStack(spacing: 0) {
            // Sticky Listing Context Header (if conversation is linked to a listing)
            if let conv = activeConversation, let title = conv.listingTitle, !title.isEmpty {
                listingHeaderBanner(conversation: conv, title: title)
            }

            // Messages Stream
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if chatService.messages.isEmpty && !chatService.isLoadingMessages {
                            Text("Send a message or offer below to start negotiating.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 24)
                        }

                        ForEach(chatService.messages) { message in
                            ChatMessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == chatService.currentUid
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: chatService.messages.count) { _ in
                    if let lastId = chatService.messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Message Input Bar
            inputBar
        }
        .navigationTitle(otherPartnerName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chatService.listenToMessages(chatId: chatId)
        }
        .onDisappear {
            chatService.stopListeningToMessages()
        }
        .sheet(isPresented: $showingQuickOfferSheet) {
            quickOfferSheetView
        }
    }

    private func listingHeaderBanner(conversation: ChatConversation, title: String) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.36, green: 0.18, blue: 0.85).opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.85))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                if let price = conversation.listingPrice {
                    Text("Listed at $\(Int(price))")
                        .font(.caption.bold())
                        .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.85))
                }
            }

            Spacer()

            Button {
                showingQuickOfferSheet = true
            } label: {
                Text("Make Offer")
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.36, green: 0.18, blue: 0.85).opacity(0.15))
                    .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.85))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button {
                showingQuickOfferSheet = true
            } label: {
                Image(systemName: "tag.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 0.36, green: 0.18, blue: 0.85))
            }

            TextField("Write a message...", text: $messageText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Button {
                sendCurrentMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(
                        messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.gray.opacity(0.4)
                        : Color(red: 0.36, green: 0.18, blue: 0.85)
                    )
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    private var quickOfferSheetView: some View {
        NavigationStack {
            Form {
                Section("Send an Offer Card in Chat") {
                    TextField("Offer Amount (USD)", text: $quickOfferAmount)
                        .keyboardType(.decimalPad)
                }

                Button("Send Offer to \(otherPartnerName)") {
                    if let amount = Double(quickOfferAmount), amount > 0 {
                        Task { @MainActor in
                            try? await chatService.sendMessage(
                                chatId: chatId,
                                text: "Offered $\(Int(amount))",
                                recipientId: otherPartnerId,
                                messageType: .offer,
                                offerAmount: amount
                            )
                            quickOfferAmount = ""
                            showingQuickOfferSheet = false
                        }
                    }
                }
                .disabled(Double(quickOfferAmount) == nil)
            }
            .navigationTitle("Make an Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingQuickOfferSheet = false
                    }
                }
            }
        }
        .presentationDetents([.height(260)])
    }

    private func sendCurrentMessage() {
        let textToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }
        messageText = ""

        Task { @MainActor in
            do {
                try await chatService.sendMessage(
                    chatId: chatId,
                    text: textToSend,
                    recipientId: otherPartnerId,
                    messageType: .text
                )
            } catch {
                appState.showToast("Failed to send: \(error.localizedDescription)")
            }
        }
    }
}

struct ChatMessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: 48) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if message.messageType == .offer, let amount = message.offerAmount {
                    offerCardView(amount: amount)
                } else if message.messageType == .trade, let tradeTitle = message.tradeItemTitle {
                    tradeCardView(tradeTitle: tradeTitle)
                } else {
                    Text(message.text)
                        .font(.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            isCurrentUser
                            ? Color(red: 0.36, green: 0.18, blue: 0.85)
                            : Color(.secondarySystemBackground)
                        )
                        .foregroundColor(isCurrentUser ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }

            if !isCurrentUser { Spacer(minLength: 48) }
        }
    }

    private func offerCardView(amount: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "tag.fill")
                Text("OFFICIAL OFFER")
                    .font(.caption2.bold())
            }
            .foregroundColor(isCurrentUser ? .white.opacity(0.85) : Color(red: 0.36, green: 0.18, blue: 0.85))

            Text("$\(Int(amount))")
                .font(.title2.bold())
                .foregroundColor(isCurrentUser ? .white : .primary)

            Text(message.text)
                .font(.caption)
                .foregroundColor(isCurrentUser ? .white.opacity(0.9) : .secondary)
        }
        .padding(14)
        .background(
            isCurrentUser
            ? Color(red: 0.36, green: 0.18, blue: 0.85)
            : Color(red: 0.36, green: 0.18, blue: 0.85).opacity(0.12)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func tradeCardView(tradeTitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("TRADE PROPOSAL")
                    .font(.caption2.bold())
            }
            .foregroundColor(isCurrentUser ? .white.opacity(0.85) : Color(red: 0.36, green: 0.18, blue: 0.85))

            Text(tradeTitle)
                .font(.subheadline.bold())
                .foregroundColor(isCurrentUser ? .white : .primary)

            Text(message.text)
                .font(.caption)
                .foregroundColor(isCurrentUser ? .white.opacity(0.9) : .secondary)
        }
        .padding(14)
        .background(
            isCurrentUser
            ? Color(red: 0.36, green: 0.18, blue: 0.85)
            : Color(red: 0.36, green: 0.18, blue: 0.85).opacity(0.12)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

---

## Section 3: Register `.chatDetail` Navigation Destination in `MainAppView.swift`
Locate `.navigationDestination(for: StackScreen.self)` in `midterm/MainAppView.swift` (or `ContentView.swift`) and add the `.chatDetail` case:

```swift
case .chatDetail(let chatId):
    ChatDetailView(chatId: chatId, appState: appState)
```

---

## Section 4: Connect Entry Points (`ListingDetailView.swift` & `OtherProfileView.swift`)

### 4A. Wire "Message Seller" in `midterm/ListingDetailView.swift`
In `midterm/ListingDetailView.swift`, find the button that messages the seller (or add one in the bottom action bar) and set its action to:

```swift
appState.openOrCreateChat(
    sellerId: listing.sellerID,
    sellerName: listing.sellerName,
    sellerHandle: "@\(listing.sellerName.lowercased().replacingOccurrences(of: " ", with: ""))",
    listing: listing,
    initialMessage: "Hi \(listing.sellerName), is your \(listing.title) still available?"
)
```

### 4B. Wire "Make Offer" / "Propose Trade" Sheet Confirmations (if applicable)
Where the user submits an offer amount (e.g., `offerAmount: Double`) or trade proposal on a `listing`:

```swift
appState.openOrCreateChat(
    sellerId: listing.sellerID,
    sellerName: listing.sellerName,
    listing: listing,
    initialOfferAmount: offerAmount
)
```

### 4C. Wire "Message" Button in `midterm/OtherProfileView.swift` (if present)
If `OtherProfileView.swift` has a button to message a seller directly:

```swift
appState.openOrCreateChat(
    sellerId: seller.id,
    sellerName: seller.name,
    sellerHandle: seller.handle ?? "@seller",
    initialMessage: "Hey \(seller.name)!"
)
```