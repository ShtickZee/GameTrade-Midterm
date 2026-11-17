import SwiftUI

struct ChatListView: View {
    @ObservedObject var appState: AppState
    @StateObject private var chatService = ChatService.shared
    @State private var showingNewChatSheet = false

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
                    .foregroundColor(Theme.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
            }

            if chatService.isLoadingConversations && chatService.conversations.isEmpty {
                Spacer()
                ProgressView("Loading conversations...")
                    .tint(Theme.primary)
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    chatService.deleteConversation(id: conversation.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Theme.background)
                .refreshable {
                    chatService.listenToConversations()
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Messages")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if appState.activeSheet != nil {
                    Button("Done") {
                        appState.activeSheet = nil
                    }
                    .foregroundColor(Theme.primary)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingNewChatSheet = true
                } label: {
                    Label("New Conversation", systemImage: "square.and.pencil")
                        .foregroundColor(Theme.primary)
                }
            }
        }
        .sheet(isPresented: $showingNewChatSheet) {
            NewChatSheetView(appState: appState)
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
                .foregroundColor(Theme.primary.opacity(0.75))

            Text("No Messages Yet")
                .font(.title3)
                .fontWeight(.bold)

            Text("Tap the new chat icon above to message another registered user, or tap 'Message Seller' on any listing.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            Button {
                showingNewChatSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.bubble.fill")
                    Text("Start New Chat")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.primary)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            .padding(.top, 6)

            Spacer()
        }
    }
}

// MARK: - New Chat Sheet (Directly Connect with other Test Users)

struct NewChatSheetView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var registeredUsers: [PublicUserProfile] = []
    @State private var isLoadingUsers: Bool = true
    @State private var manualUserId: String = ""
    @State private var manualUserName: String = ""
    @State private var initialMessage: String = "Hello!"
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Registered Users in Firebase
                Section {
                    if isLoadingUsers {
                        HStack {
                            Spacer()
                            ProgressView("Searching for other test accounts...")
                                .tint(Theme.primary)
                            Spacer()
                        }
                    } else if registeredUsers.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("No other registered accounts found in Firestore yet.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Text("Create a second account (e.g. on another device/simulator or after signing out) to see it here.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    } else {
                        ForEach(registeredUsers) { user in
                            Button {
                                startChatWithUser(user)
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Theme.primary.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Text(String(user.displayName.prefix(1)).uppercased())
                                            .font(.subheadline.bold())
                                            .foregroundColor(Theme.primary)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(user.displayName)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary)
                                        Text(user.handle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Select a Registered Account")
                } footer: {
                    Text("Other test accounts that have signed up in your Firebase project.")
                }

                // Section 2: Direct Manual User ID Input
                Section("Or Message by User ID (UID)") {
                    TextField("Recipient User ID (Firebase UID)", text: $manualUserId)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    TextField("Recipient Name (Optional)", text: $manualUserName)

                    TextField("Initial Message", text: $initialMessage)

                    Button {
                        startManualChat()
                    } label: {
                        Text("Start Chat with UID")
                            .frame(maxWidth: .infinity)
                            .font(.subheadline.bold())
                    }
                    .disabled(manualUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                // Section 3: Demo Mock Listing
                Section("Offline Demo") {
                    Button("Start Sample Demo Chat (Marco Santos)") {
                        startSampleDemoChat()
                    }
                }
            }
            .navigationTitle("New Conversation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadUsers()
            }
        }
    }

    private func loadUsers() {
        isLoadingUsers = true
        UserService.shared.fetchAllRegisteredUsers { result in
            DispatchQueue.main.async {
                self.isLoadingUsers = false
                switch result {
                case .success(let users):
                    self.registeredUsers = users
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    private func startChatWithUser(_ user: PublicUserProfile) {
        dismiss()
        appState.openOrCreateChat(
            sellerId: user.id,
            sellerName: user.displayName,
            sellerHandle: user.handle,
            initialMessage: "Hi \(user.displayName)!"
        )
    }

    private func startManualChat() {
        let trimmedId = manualUserId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedId.isEmpty else { return }
        dismiss()
        appState.openOrCreateChat(
            sellerId: trimmedId,
            sellerName: manualUserName.isEmpty ? "Trader" : manualUserName,
            sellerHandle: "@trader",
            initialMessage: initialMessage.isEmpty ? "Hello!" : initialMessage
        )
    }

    private func startSampleDemoChat() {
        dismiss()
        let sampleListing = Listing(
            id: "sample_ps5_disc_\(Int.random(in: 100...999))",
            title: "PlayStation 5 Disc Edition + 2 Controllers",
            price: 420,
            was: 499,
            platform: .ps5,
            condition: .likeNew,
            sellerID: "demo_seller_\(Int.random(in: 10...99))",
            sellerName: "Marco Santos",
            sellerAvatar: "M",
            sellerRating: 4.9,
            isVerified: true,
            location: "Makati",
            saved: false,
            bundle: "Includes Spider-Man 2",
            images: ["PS5"],
            description: "Complete with box and original HDMI 2.1 cable."
        )

        appState.openOrCreateChat(
            sellerId: sampleListing.sellerID,
            sellerName: sampleListing.sellerName,
            sellerHandle: "@marcotrades",
            listing: sampleListing,
            initialMessage: "Hi Marco! Is this PS5 bundle still available?"
        )
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
                    .fill(Theme.primary.opacity(0.15))
                    .frame(width: 52, height: 52)

                Text(String(otherName.prefix(1)).uppercased())
                    .font(.title3.bold())
                    .foregroundColor(Theme.primary)
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
                    .foregroundColor(Theme.primary)
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
                            .background(Theme.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
