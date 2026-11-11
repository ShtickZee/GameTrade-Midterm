# Agent Execution Guide: Phase 1 & 2 — User Account Architecture & Security Hardening

## Role & Objective
You are an autonomous Xcode Swift AI Agent working inside the `GameTrade-Midterm` repository. Your objective is to upgrade the existing user authentication and local `@AppStorage` profile system into a secure, production-grade **Firebase Auth + Firestore + Firebase Storage** architecture with strict public/private data separation and cryptographic hashing.

Read this guide carefully and apply the exact code blocks provided in `Code.md` to the target files listed below.

---

## Architectural Overview & Security Mandate

1. **Zero Plaintext Credential Storage (CRITICAL FIX):**
   * Currently, `midterm/AppState.swift` defines `@AppStorage("storedPassword") var storedPassword: String = ""` and stores sensitive user details in unencrypted `UserDefaults` (`@AppStorage`).
   * **Action Required:** Remove `storedPassword` and `storedEmail` from `@AppStorage` immediately. `FirebaseAuth` automatically manages session tokens inside the encrypted iOS Keychain and hashes passwords server-side using scrypt. Never store passwords locally or in Firestore.

2. **Public vs. Private Firestore Collection Split:**
   * To prevent malicious users or packet sniffers from scraping emails, phone numbers, or exact locations when browsing `MarketplaceView` or `OtherProfileView`, user data is split into two distinct Firestore paths:
     * **Public Document (`users/{uid}`):** Stores `id`, `name` (optional/display name), `handle`, `bio`, `coarseLocation` (city/region label only, e.g., "Makati"), `avatarURL`, `role` (`"standard_user"`), `rating`, `reviewsCount`, `verified`, `listingsCount`, `soldCount`, and `createdAt`.
     * **Private Subcollection Document (`users/{uid}/private/sensitive`):** Stores `email`, `phoneNumber`, `emailHash` (SHA-256), `phoneHash` (SHA-256), `exactLocation` (private address/coordinates), and `updatedAt`.

3. **Client-Side Cryptographic Hashing (`CryptoKit`):**
   * Use Apple's native `CryptoKit` (`SHA256`) to generate deterministic, irreversible hashes of normalized emails and phone numbers, and to obfuscate location strings where necessary.

---

## Step-by-Step Implementation Instructions for the Agent

### Step 1: Verify Firebase SDK Dependencies
Ensure the Xcode project (`midterm.xcodeproj`) links the following Firebase Swift Package Manager (SPM) libraries:
* `FirebaseAuth` (Already installed)
* `FirebaseFirestore` (Required for database operations)
* `FirebaseStorage` (Required for profile photo uploads)

### Step 2: Create `midterm/SecurityUtils.swift` (New File)
* Create a new Swift file at `midterm/SecurityUtils.swift` and add it to the `midterm` target.
* Copy **Section 1** from `Code.md` into this file.
* **Purpose:** Provides `SHA256` hashing via `CryptoKit` for normalizing and hashing emails/phone numbers, input sanitization, and coarse location stripping so exact street addresses are never leaked to the public profile.

### Step 3: Update `midterm/Models.swift`
* Open `midterm/Models.swift`.
* Keep the existing `Platform`, `Condition`, `Listing`, `Seller`, and `Review` definitions intact so no existing views (`DealsHomeView`, `MarketplaceView`, `ListingCardView`, `OtherProfileView`) break.
* Append the new `UserRole`, `PublicUserProfile`, and `PrivateUserData` structs from **Section 2** of `Code.md` to the bottom of `midterm/Models.swift`.
* Notice that `Review` is also updated to conform to `Codable` while preserving its default `id` behavior.

### Step 4: Create `midterm/UserService.swift` (New File)
* Create a new Swift file at `midterm/UserService.swift` and add it to the `midterm` target.
* Copy **Section 3** from `Code.md` into this file.
* **Purpose:** Uses Firestore `WriteBatch` to atomically write `users/{uid}` (public) and `users/{uid}/private/sensitive` (private) in a single transaction, uploads compressed profile avatars to Firebase Storage (`avatars/{uid}/profile.jpg`), and fetches public/private profiles safely.

### Step 5: Refactor `midterm/AppState.swift`
* Open `midterm/AppState.swift` and replace its contents with **Section 4** from `Code.md`.
* **Key Changes Preserved & Upgraded:**
  * Preserves all existing `@Published` properties (`activeTab`, `navigationPath`, `activeSheet`, `shouldSetupProfile`, `offersBadge`, `sellPressed`, `showOfferSuccess`, `toastMessage`, `selectedListing`, `isEditingProfile`, `showingImagePicker`, `searchQuery`, `notifications`) and all existing navigation functions (`showToast`, `navigate`, `goBack`, `switchTab`) so zero existing SwiftUI views break.
  * Removes `@AppStorage("storedPassword")`.
  * Adds an `AuthStateDidChangeListener` so the user's authenticated session is restored securely from the iOS Keychain on app launch and automatically syncs their profile from Firestore.
  * Adds `saveUserProfileToFirebase(...)` which handles optional names, private phone/location storage, and optional profile image uploads.

### Step 6: Update `ProfileSetupView.swift` & `midterm/EditProfileView.swift`
* **Note on File Location:** Check whether `ProfileSetupView.swift` is in the project root (`/ProfileSetupView.swift`) or inside `/midterm`. Update the active `ProfileSetupView.swift` file in the Xcode target with **Section 5** from `Code.md`.
* Key change in `ProfileSetupView.swift`:
  * `Full Name` is now **optional** (per project specification). If left blank, it gracefully falls back to the user's `@username` for public display.
  * `Finish Signing Up` now calls `appState.saveUserProfileToFirebase(...)` with a loading indicator instead of only mutating local state.
* Update `midterm/EditProfileView.swift` with **Section 6** from `Code.md` so clicking **Save** persists changes to both the public and private Firestore documents and uploads any updated profile photo.

### Step 7: Deploy Firestore & Storage Security Rules
* Copy **Section 7** (`firestore.rules` and `storage.rules`) from `Code.md` into your Firebase Console (or local Firebase CLI configuration) to enforce server-side access control on `users/{uid}/private/sensitive`.

---

## Verification Checklist for the Agent
After applying all changes in `Code.md`, run an Xcode Build (`Cmd + B`) and verify:
1. No compilation errors in `DealsHomeView`, `MarketplaceView`, `OffersView`, `ProfileView`, `LoginView`, or `CreateAccountView`.
2. Creating a new account in `CreateAccountView` routes to `ProfileSetupView`, where `Full Name` is optional and `Username` is required.
3. Completing `ProfileSetupView` writes non-sensitive fields to `users/{uid}` and locks `email`, `phoneNumber`, and `exactLocation` inside `users/{uid}/private/sensitive`.