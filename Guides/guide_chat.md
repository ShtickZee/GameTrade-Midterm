# GameTrade: Real-Time Firebase Chat Implementation Guide (`guide_chat.md`)

## Directives for the Agentic Coder
**IMPORTANT:** Read this entire guide before modifying any files. Follow the steps in exact sequential order (`STEP 1` through `STEP 7`). Do **not** skip steps, do **not** invent custom variable names, and do **not** delete existing structs in `Models.swift` (`Platform`, `Condition`, `Listing`, `Seller`, `Review`).

---

## Architectural Overview
We are upgrading the static mock Chat system in `midterm/Chat` to a live, real-time **Cloud Firestore** chat engine that works with **FirebaseAuth** and **AppState**:
1. **Firestore Schema:**
   - `chats/{chatId}`: Stores conversation participants (`participantIds`), participant display names (`participantNames`), participant handles (`participantHandles`), optional linked listing info (`listingId`, `listingTitle`, `listingPrice`, `listingImage`), `lastMessage`, `lastTimestamp`, and `unreadCounts`.
   - `chats/{chatId}/messages/{messageId}`: Subcollection storing every message in chronological order (`senderId`, `text`, `timestamp`, `messageType`, `offerAmount`, `tradeItemTitle`).
2. **Deterministic Thread IDs:**
   - Every chat ID is computed deterministically using the sorted array of the two user UIDs plus the optional `listingId`. Tapping "Message Seller" on the same listing will always reopen the existing conversation instead of creating duplicates.

---

## Step-by-Step Execution Plan for the Agent

### STEP 1: Clean Up Old Mock Chat Models & Create `ChatModels.swift`
* **Source Code Reference:** Open `code_chat_1.md` -> **Section 1**.
* **Where to put it:**
  1. Look inside the `midterm/Chat/` directory.
  2. If there is an existing `Chat.swift`, `ChatMessage.swift`, or `ChatModels.swift` file inside `midterm/Chat/`, **replace** its model definitions with the contents of `midterm/Chat/ChatModels.swift` from `code_chat_1.md` (Section 1).
  3. If `Chat` and `ChatMessage` were previously declared at the bottom of `midterm/Models.swift` or inside `ChatListView.swift`, **remove** those old duplicate struct declarations so Xcode does not throw `"Invalid redeclaration of 'Chat'"` or `"Invalid redeclaration of 'ChatMessage'"`.
  4. Note that `ChatModels.swift` defines `ChatConversation` and `ChatMessage`, plus a `typealias Chat = ChatConversation` so any existing code referencing `Chat` continues to compile cleanly.

---

### STEP 2: Create `ChatService.swift`
* **Source Code Reference:** Open `code_chat_1.md` -> **Section 2**.
* **Where to put it:**
  1. Create a new file at `midterm/Chat/ChatService.swift`.
  2. Paste the entire contents of **Section 2** from `code_chat_1.md`.
* **What it connects to:**
  - Uses `FirebaseAuth` and `FirebaseFirestore`.
  - Exposes `ChatService.shared` as a `@MainActor final class ChatService: ObservableObject`.
  - Publishes `@Published var conversations: [ChatConversation]` for `ChatListView` and `@Published var messages: [ChatMessage]` for `ChatDetailView`.
  - Sorts conversations in memory by `lastTimestamp` descending so the app never crashes or shows an empty list if a Firestore composite index is still building.

---

### STEP 3: Update `AppState.swift` to Support Direct Chat Navigation & Messaging
* **Source Code Reference:** Open `code_chat_1.md` -> **Section 3**.
* **Where to put it:** Open `midterm/AppState.swift`.
* **Exact Modifications Required:**
  1. **Update `enum StackScreen: Hashable`:**
     Add `.chatDetail(chatId: String)` to `StackScreen`:
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
  2. **Add `@Published var activeChatId: String? = nil` inside `class AppState: ObservableObject`:**
     Place it right under `@Published var selectedListing: Listing?`.
  3. **Add the `openOrCreateChat(...)` helper method inside `class AppState`:**
     Copy the `openOrCreateChat` method from `code_chat_1.md` (Section 3B) and paste it inside `class AppState` right above `func login(...)`.
  4. **Clean up listeners on `logout()`:**
     Inside `func logout()`, right before `try Auth.auth().signOut()`, call:
     ```swift
     Task { @MainActor in
         ChatService.shared.stopAllListeners()
     }
     ```

---

### STEP 4: Replace `ChatListView.swift` with the Live Firestore Version
* **Source Code Reference:** Open `code_chat_2.md` -> **Section 1**.
* **Where to put it:** Open `midterm/Chat/ChatListView.swift` and replace the entire file with **Section 1** of `code_chat_2.md`.
* **How it connects:**
  - Accepts `@ObservedObject var appState: AppState`. (A default initializer `init(appState: AppState = AppState())` is also included so any existing zero-argument calls like `ChatListView()` in `OffersView.swift` or Previews will still compile without errors!).
  - Automatically starts `ChatService.shared.listenToConversations()` inside `.onAppear`.
  - Includes a built-in **"New Test Chat"** button in the top-right toolbar and empty state so the user can immediately test live Firestore chat creation even with a single account on the simulator.

---

### STEP 5: Replace `ChatDetailView.swift` with the Real-Time Messaging View
* **Source Code Reference:** Open `code_chat_2.md` -> **Section 2**.
* **Where to put it:** Open `midterm/Chat/ChatDetailView.swift` and replace the entire file with **Section 2** of `code_chat_2.md`.
* **How it connects:**
  - Can be initialized with either a `chatId: String` (`ChatDetailView(chatId: id, appState: appState)`) OR a `ChatConversation` object (`ChatDetailView(chat: conversation, appState: appState)`).
  - Streams live messages from `chats/{chatId}/messages` in real time using `ChatService.shared.listenToMessages(chatId:)`.
  - Renders special purple cards for `"offer"` and `"trade"` messages, a sticky listing banner at the top if the chat is tied to a console/game listing, and an auto-scrolling message list using `ScrollViewReader`.

---

### STEP 6: Register `.chatDetail` Route in `MainAppView.swift` (or Root NavigationStack)
* **Source Code Reference:** Open `code_chat_2.md` -> **Section 3**.
* **Where to put it:**
  1. Search the codebase for `.navigationDestination(for: StackScreen.self)` (usually located in `midterm/MainAppView.swift` or `midterm/ContentView.swift`).
  2. Inside the `switch screen` block of `.navigationDestination(for: StackScreen.self)`, add the `.chatDetail` case:
     ```swift
     case .chatDetail(let chatId):
         ChatDetailView(chatId: chatId, appState: appState)
     ```
  3. Open `midterm/OffersView.swift`. Ensure that wherever `ChatListView` is embedded, it passes `appState` if `appState` is in scope: `ChatListView(appState: appState)`.

---

### STEP 7: Connect "Message Seller" & "Make Offer" in `ListingDetailView.swift` and `OtherProfileView.swift`
* **Source Code Reference:** Open `code_chat_2.md` -> **Section 4**.
* **Where to put it:**
  1. Open `midterm/ListingDetailView.swift`.
  2. Find the **"Message Seller"** button (or chat icon button) and replace its action with the `appState.openOrCreateChat(...)` call shown in `code_chat_2.md` (Section 4A).
  3. If `ListingDetailView.swift` or `OffersView.swift` has a **"Make Offer"** or **"Propose Trade"** submit button, wire its action to `appState.openOrCreateChat(...)` with `initialOfferAmount` or `initialTradeItemTitle` as shown in `code_chat_2.md` (Section 4B).
  4. Open `midterm/OtherProfileView.swift`. If there is a **"Message"** button on the seller's profile, wire it to `appState.openOrCreateChat(...)` as shown in `code_chat_2.md` (Section 4C).

---

## Final Verification Checklist for the Agent
1. Build the project (`Cmd + B`). Ensure there are **zero** duplicate struct declarations for `Chat` or `ChatMessage`.
2. Ensure every `switch` statement over `StackScreen` handles `.chatDetail(let chatId)`.
3. Ensure `import FirebaseFirestore` and `import FirebaseAuth` are at the top of `ChatModels.swift`, `ChatService.swift`, and `AppState.swift`.