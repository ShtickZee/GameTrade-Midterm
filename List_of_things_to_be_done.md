# List of Things to be Done

## Backend & Data
- [ ] **Integrate Firestore Database**:
  - Migrate local data models to Firestore collections (`Listings`, `Users`, `Reviews`).
  - Update `AppState` and models to fetch/push real-time data from Firestore.
- [ ] **Integrate Firebase Storage**:
  - Refactor image handling (profile photos, listing images) to use Firebase Storage instead of local storage.

## UI Implementation (Firebase-powered)
- [ ] **Implement Listing Detail Screen**:
  - Connect to Firestore to display real-time listing details and images from Firebase Storage.
- [ ] **Implement Edit Profile Screen**:
  - Connect to Firestore to save user data.
  - Connect to Firebase Storage for profile photo uploads.
- [ ] **Implement Search Screen**:
  - Connect to Firestore to enable real-time searching/filtering of listings.

## Final Polish & Design
- [ ] **UI Polish and Design System Alignment**:
  - Apply global theme (#5B2FD9) across all screens.
  - Ensure consistent typography, button styles, and spacing.
  - Implement smooth animations and transitions.
  - Final visual review of all screens.
