import SwiftUI

struct ChatDetailView: View {
    let chatId: String
    var initialChat: ChatConversation?
    @ObservedObject var appState: AppState

    @StateObject private var chatService = ChatService.shared
    @State private var messageText: String = ""
    @State private var showingQuickOfferSheet: Bool = false
    @State private var quickOfferAmount: String = ""

    init(chat: ChatConversation, appState: AppState = AppState()) {
        self.chatId = chat.id
        self.initialChat = chat
        self.appState = appState
    }

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

    private var otherPartnerHandle: String {
        activeConversation?.otherParticipantHandle(currentUid: chatService.currentUid) ?? "@trader"
    }

    private var otherPartnerId: String {
        activeConversation?.otherParticipantId(currentUid: chatService.currentUid) ?? ""
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Sticky Listing Context Header (if conversation is linked to a listing)
                if let conv = activeConversation, let title = conv.listingTitle, !title.isEmpty {
                    listingHeaderBanner(conversation: conv, title: title)
                }

                // Messages Stream with Date Separators
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            if chatService.messages.isEmpty && !chatService.isLoadingMessages {
                                VStack(spacing: 8) {
                                    Image(systemName: "hand.wave.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.orange)
                                    Text("Start negotiating with \(otherPartnerName)")
                                        .font(.headline)
                                        .foregroundColor(Theme.textPrimary)
                                    Text("Send a message or an offer card below.")
                                        .font(.caption)
                                        .foregroundColor(Theme.textSecondary)
                                }
                                .padding(.top, 40)
                            }

                            ForEach(Array(chatService.messages.enumerated()), id: \.element.id) { index, message in
                                if shouldShowDateSeparator(at: index) {
                                    DateSeparatorView(date: message.timestamp)
                                }

                                ChatMessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == chatService.currentUid,
                                    onAcceptOffer: { amount in
                                        handleAcceptOffer(amount: amount)
                                    },
                                    onDeclineOffer: { amount in
                                        handleDeclineOffer(amount: amount)
                                    },
                                    onAcceptTrade: { title in
                                        handleAcceptTrade(title: title)
                                    },
                                    onDeclineTrade: { title in
                                        handleDeclineTrade(title: title)
                                    }
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

                Divider().background(Theme.border)

                // Message Input Bar
                inputBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Theme.primary.opacity(0.15))
                            .frame(width: 34, height: 34)
                        Text(String(otherPartnerName.prefix(1)).uppercased())
                            .font(.subheadline.bold())
                            .foregroundColor(Theme.primary)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(otherPartnerName)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text(otherPartnerHandle)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
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

    private func shouldShowDateSeparator(at index: Int) -> Bool {
        if index == 0 { return true }
        let current = chatService.messages[index].timestamp
        let prev = chatService.messages[index - 1].timestamp
        return !Calendar.current.isDate(current, inSameDayAs: prev)
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
        .background(Theme.surface)
        .overlay(Divider().background(Theme.border), alignment: .bottom)
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
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Theme.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))

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
        .background(Theme.surface)
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
                            appState.showToast("Offer card sent!")
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

    private func handleAcceptOffer(amount: Double) {
        Task { @MainActor in
            try? await chatService.sendMessage(
                chatId: chatId,
                text: "✅ Accepted offer of $\(Int(amount))! Let's arrange pickup.",
                recipientId: otherPartnerId,
                messageType: .text
            )
            appState.showToast("Offer accepted!")
        }
    }

    private func handleDeclineOffer(amount: Double) {
        Task { @MainActor in
            try? await chatService.sendMessage(
                chatId: chatId,
                text: "❌ Sorry, I cannot accept the $\(Int(amount)) offer.",
                recipientId: otherPartnerId,
                messageType: .text
            )
            appState.showToast("Offer declined.")
        }
    }

    private func handleAcceptTrade(title: String) {
        Task { @MainActor in
            try? await chatService.sendMessage(
                chatId: chatId,
                text: "✅ Accepted trade proposal: \(title).",
                recipientId: otherPartnerId,
                messageType: .text
            )
            appState.showToast("Trade proposal accepted!")
        }
    }

    private func handleDeclineTrade(title: String) {
        Task { @MainActor in
            try? await chatService.sendMessage(
                chatId: chatId,
                text: "❌ Cannot proceed with the trade: \(title).",
                recipientId: otherPartnerId,
                messageType: .text
            )
            appState.showToast("Trade declined.")
        }
    }
}

struct ChatMessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    var onAcceptOffer: ((Double) -> Void)? = nil
    var onDeclineOffer: ((Double) -> Void)? = nil
    var onAcceptTrade: ((String) -> Void)? = nil
    var onDeclineTrade: ((String) -> Void)? = nil

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
                            : Theme.surfaceElevated
                        )
                        .foregroundColor(Theme.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isCurrentUser ? Color.clear : Theme.border, lineWidth: 1)
                        )
                }

                HStack(spacing: 4) {
                    Text(message.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if isCurrentUser {
                        // Delivery indicator
                        Text("••")
                            .font(.caption2.bold())
                            .foregroundColor(Theme.primary)
                    }
                }
                .padding(.horizontal, 4)
            }

            if !isCurrentUser { Spacer(minLength: 48) }
        }
    }

    private func offerCardView(amount: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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

            // Inline action buttons when received from other user
            if !isCurrentUser {
                Divider()
                HStack(spacing: 10) {
                    Button {
                        onDeclineOffer?(amount)
                    } label: {
                        Text("Decline")
                            .font(.caption.bold())
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.15))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }

                    Button {
                        onAcceptOffer?(amount)
                    } label: {
                        Text("Accept ✓")
                            .font(.caption.bold())
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Theme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
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
        VStack(alignment: .leading, spacing: 8) {
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

            // Inline action buttons when received from other user
            if !isCurrentUser {
                Divider()
                HStack(spacing: 10) {
                    Button {
                        onDeclineTrade?(tradeTitle)
                    } label: {
                        Text("Decline")
                            .font(.caption.bold())
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.15))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }

                    Button {
                        onAcceptTrade?(tradeTitle)
                    } label: {
                        Text("Accept ✓")
                            .font(.caption.bold())
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Theme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
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
