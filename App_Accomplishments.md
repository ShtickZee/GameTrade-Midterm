# App Accomplishments

## Core Functionality
- [x] **Project Initialization**: Basic SwiftUI project structure established.
- [x] **Firebase Setup**:
  - Initialized Firebase in `midtermApp.swift`.
  - Configured `AppDelegate` for Firebase.
- [x] **Authentication**:
  - Integrated `FirebaseAuth` for user registration and sign-in.
  - Refactored `LoginView` and `CreateAccountView` to use Firebase Auth.
  - Updated `AppState` to handle authentication states (login, sign-up, logout).

## Screens & UI
- [x] **Notifications Screen**:
  - Implemented dynamic notification list using `AppState`.
  - Created structured `Notification` model.
- [x] **Other Profile Screen**:
  - Completed view-only profile screen for other users.
  - Displayed ratings and review list using `ReviewCard` component.
- [x] **Chat System**:
  - Implemented `ChatListView` for conversation overview.
  - Implemented `ChatDetailView` for real-time messaging interface.
  - Created `Chat` and `ChatMessage` models.

## Components
- [x] **NotificationRow**: Refactored to support read/unread states and dynamic data.
- [x] **ReviewCard**: Integrated into Other Profile view.
