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
                .fill(Theme.primary.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(Theme.primary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                if let price = conversation.listingPrice {
                    Text("Listed at $\(Int(price))")
                        .font(.caption.bold())
                        .foregroundColor(Theme.primary)
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
                    .background(Theme.primary.opacity(0.15))
                    .foregroundColor(Theme.primary)
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
                    .foregroundColor(Theme.primary)
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
                        : Theme.primary
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
                            ? Theme.primary
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
            .foregroundColor(isCurrentUser ? .white.opacity(0.85) : Theme.primary)

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
            ? Theme.primary
            : Theme.primary.opacity(0.12)
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
            .foregroundColor(isCurrentUser ? .white.opacity(0.85) : Theme.primary)

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
            ? Theme.primary
            : Theme.primary.opacity(0.12)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
