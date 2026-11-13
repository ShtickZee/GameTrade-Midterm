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
                        .foregroundColor(Theme.primary)
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
                .foregroundColor(Theme.primary.opacity(0.75))

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
                .background(Theme.primary)
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
