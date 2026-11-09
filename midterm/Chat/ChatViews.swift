import SwiftUI

struct ChatListView: View {
    @ObservedObject var appState: AppState
    
    // Mock data for now
    @State private var chats: [Chat] = [
        Chat(otherUserId: "user1", otherUserName: "Sarah Johnson", lastMessage: "Is the PS5 still available?", lastMessageTimestamp: Date(), messages: []),
        Chat(otherUserId: "user2", otherUserName: "Mike Smith", lastMessage: "Accepted your offer!", lastMessageTimestamp: Date().addingTimeInterval(-3600), messages: [])
    ]
    
    var body: some View {
        List(chats) { chat in
            NavigationLink(destination: ChatDetailView(chat: chat)) {
                HStack {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(Text(String(chat.otherUserName.prefix(1))))
                    
                    VStack(alignment: .leading) {
                        Text(chat.otherUserName)
                            .fontWeight(.semibold)
                        Text(chat.lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }
        }
        .navigationTitle("Messages")
    }
}

struct ChatDetailView: View {
    let chat: Chat
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(senderId: "other", text: "Is the PS5 still available?", timestamp: Date(), isFromCurrentUser: false),
        ChatMessage(senderId: "me", text: "Yes, it is!", timestamp: Date(), isFromCurrentUser: true)
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isFromCurrentUser { Spacer() }
                            Text(message.text)
                                .padding(10)
                                .background(message.isFromCurrentUser ? Color.purple : Color.gray.opacity(0.2))
                                .foregroundColor(message.isFromCurrentUser ? .white : .black)
                                .cornerRadius(12)
                            if !message.isFromCurrentUser { Spacer() }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            HStack {
                TextField("Message...", text: $messageText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                
                Button("Send") {
                    // Send message logic here
                    messageText = ""
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(chat.otherUserName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
