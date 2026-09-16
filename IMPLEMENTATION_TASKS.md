# GameTrade Implementation Tasks - Missing Features

## Overview
This document outlines all missing screens, functionality, and components that need to be implemented in the SwiftUI iOS app (`/midterm` directory). Follow the prioritized order below for optimal development flow.

---

## 1. Listing Detail Screen (HIGH PRIORITY)

### Visual Behavior
- **Sliding Overlay**: When a product listing is clicked, a new screen should slide in from the **right side** over the current screen
- **Swipe-Back Gesture**: User can swipe from left edge to dismiss the screen smoothly
- **Animation**: Smooth, lag-free transition (use `NavigationStack` with `.fullScreenCover` or custom transition)
- **Back Button**: Include a back button in the top-left corner

### Layout Structure (Top to Bottom)
```
┌─────────────────────────────────┐
│  [← Back]                       │
│                                 │
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │   Image Carousel          │  │ ← Swipable if multiple images
│  │   (Full width, aspect 1:1)│  │
│  │   • Page dots indicator   │  │
│  │                           │  │
│  └───────────────────────────┘  │
│                                 │
│  Product Name                   │ ← Bold, large font
│  $XX.XX                         │ ← Prominent price display
│                                 │
│  Description                    │ ← Seller-provided text
│  (Multi-line, full width)       │
│                                 │
│  ─────────────────────────────  │ ← Divider
│                                 │
│  [Seller Profile Section]       │
│  ┌───────────────────────────┐  │
│  │ 👤 [Profile Pic]          │  │
│  │ Username ✓               │  │ ← Verification checkmark if verified
│  │ ★★★★☆ (4.2)              │  │ ← Star rating system
│  │ 📍 Location               │  │
│  └───────────────────────────┘  │
│                                 │
│  [Contact Seller] [Make Offer]  │ ← Action buttons
└─────────────────────────────────┘
```

### Required Components
- `ListingDetailView.swift` - Main view file
- Image carousel with swipe gesture (`TabView` with `PageTabViewStyle`)
- Star rating component (reusable)
- Verification badge icon
- Seller profile card component

### Data Model Requirements
Ensure `Listing` model includes:
```swift
var images: [String]        // Array of image URLs/local paths
var title: String
var price: Double
var description: String
var sellerID: String
var sellerName: String
var sellerAvatar: String
var sellerRating: Double
var isVerified: Bool
var location: String
```

---

## 2. Search Screen

### Visual Behavior
- **Slide-Up Animation**: Screen slides up from bottom when activated
- **Modal Presentation**: Use `.sheet()` modifier for presentation

### Layout Structure
```
┌─────────────────────────────────┐
│  🔍 Search Games...             │ ← Search bar (sticky top)
│                                 │
│  Listings Near You              │ ← Section header
│  ┌───┬───┬───┐                  │
│  │ 🎮│ 🎮│ 🎮│                  │ ← 3x3 Grid of product cards
│  ├───┼───┼───┤                  │   (Use LazyVGrid)
│  │ 🎮│ 🎮│ 🎮│                  │
│  ├───┼───┼───┤                  │
│  │ 🎮│ 🎮│ 🎮│                  │
│  └───┴───┴───┘                  │
│                                 │
│  Trending Searches              │ ← Optional section
│  #PS5 #XboxSeriesX #Switch      │
└─────────────────────────────────┘
```

### Required Components
- `SearchView.swift` - Main view file
- Search bar with live filtering
- 3x3 grid layout using `LazyVGrid(columns: [GridItem(.flexible())])`
- Product card placeholder component
- Recent searches / trending tags section

### Functionality
- Real-time search filtering by game title, console, genre
- Display template product cards initially (can use mock data)
- Tap on grid item → Navigate to Listing Detail Screen

---

## 3. Notifications Screen

### Layout Structure
```
┌─────────────────────────────────┐
│  Notifications                  │ ← Header
│                                 │
│  ┌───────────────────────────┐  │
│  │ 🔔 New offer on your PS5  │  │
│  │ 2 hours ago               │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 💬 User123 messaged you   │  │
│  │ 5 hours ago               │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ ✅ Your trade was accepted│  │
│  │ Yesterday                 │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

### Required Components
- `NotificationsView.swift` - Main view file
- Notification row component with:
  - Icon (offer, message, trade, system)
  - Title and subtitle
  - Timestamp
  - Read/unread indicator (dot)
- Swipe-to-delete or mark-as-read gesture

### Functionality
- List of notifications (use mock data for now)
- Tap notification → Navigate to relevant screen
- Mark as read functionality
- Clear all option

---

## 4. Edit Profile Screen (FULLY FUNCTIONAL)

### Layout Structure
```
┌─────────────────────────────────┐
│  Edit Profile            [Save] │
│                                 │
│  ┌───────────────────────────┐  │
│  │        [Profile Photo]    │  │ ← Tappable to change
│  │        📷 Change          │  │
│  └───────────────────────────┘  │
│                                 │
│  Full Name                      │
│  [John Doe____________]         │
│                                 │
│  Username                       │
│  [@johndoe__________]           │
│                                 │
│  Email                          │
│  [john@example.com___]          │
│                                 │
│  Phone Number                   │
│  [+1 234 567 8900____]          │
│                                 │
│  Location                       │
│  [New York, NY_______]          │
│                                 │
│  Bio                            │
│  [_________________]            │
│  [_________________]            │
└─────────────────────────────────┘
```

### Required Components
- `EditProfileView.swift` - Main view file
- Image picker integration (camera + photo library)
- Form fields with validation
- Save button with confirmation

### Image Upload Implementation
```swift
// Use UIImagePickerController wrapped in UIViewRepresentable
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(...) -> UIImagePickerController { ... }
    func updateUIViewController(...) { }
}

// In EditProfileView:
.sheet(isPresented: $showingImagePicker) {
    ImagePicker(selectedImage: $profileImage, sourceType: .photoLibrary)
}
```

### Functionality
- Load current user data from `AppState`
- Update all fields
- Upload/change profile photo (store locally or in AppState)
- Validate email format, phone number format
- Save changes persistently (UserDefaults or AppState)

---

## 5. Other Profile Screen (VIEW ONLY)

### Layout Structure
```
┌─────────────────────────────────┐
│  [← Back]                       │
│                                 │
│  ┌───────────────────────────┐  │
│  │   [Background Banner]     │  │
│  │                           │  │
│  │      [Profile Picture]    │  │ ← Centered, overlapping banner
│  └───────────────────────────┘  │
│                                 │
│        Sarah Johnson            │ ← Large bold name
│        ★★★★☆ (4.8)             │ ← Star rating
│                                 │
│  ─────────────────────────────  │
│                                 │
│  📧 sarah.j@email.com           │
│  📱 +1 234 567 8900             │
│  📍 Los Angeles, CA             │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  Reviews (3)                    │
│  ┌───────────────────────────┐  │
│  │ "Great seller! Fast ship" │  │
│  │ ★★★★☆ - Mike, 2 days ago  │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ "Item as described ✓"     │  │
│  │ ★★★★★ - Alex, 1 week ago  │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ "Smooth transaction"      │  │
│  │ ★★★★☆ - Chris, 2 weeks ago│  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

### Required Components
- `OtherProfileView.swift` - Main view file
- Reuse profile components from `ProfileView.swift`
- Remove all edit buttons
- Add review list component (3 hardcoded reviews for now)
- Star rating display component

### Data Requirements
Create `UserProfile` model or ensure existing model includes:
```swift
var name: String
var username: String
var avatar: String
var bannerImage: String
var rating: Double
var reviewCount: Int
var email: String
var phone: String
var location: String
var reviews: [Review]  // Array of review objects
```

### Review Model
```swift
struct Review: Identifiable {
    let id = UUID()
    let reviewerName: String
    let rating: Double
    let comment: String
    let date: String
}
```

---

## 6. Non-Functional Button Wiring

### Buttons That Need Implementation

#### In `MarketplaceView.swift`:
- [ ] Category filter chips → Filter listings by category
- [ ] Individual listing cards → Navigate to `ListingDetailView`
- [ ] Filter button (top-right) → Open `FiltersSheet`
- [ ] Add Listing button (FAB) → Open Sell Flow

#### In `DealsView.swift`:
- [ ] Deal cards → Navigate to `ListingDetailView`
- [ ] "View All" buttons → Show filtered list

#### In `OffersView.swift`:
- [ ] Offer accept button → Update offer status, show success
- [ ] Offer reject button → Update offer status
- [ ] Chat button → Navigate to chat screen (placeholder ok)
- [ ] Counter offer button → Open MakeOffer sheet

#### In `ProfileView.swift`:
- [ ] Edit Profile button → Navigate to `EditProfileView`
- [ ] Settings items → Navigate to respective screens or show toast
- [ ] Saved Items → Navigate to `SavedItemsView` (can be placeholder)
- [ ] My Listings → Navigate to user's listings
- [ ] Logout → Clear session, return to LoginView

#### In `ListingDetailView` (once created):
- [ ] Contact Seller → Open messaging interface
- [ ] Make Offer → Open MakeOffer sheet
- [ ] Seller profile → Navigate to `OtherProfileView`

### Implementation Notes
- Use `NavigationLink` for screen transitions
- Use `.sheet()` for modal presentations
- Update `AppState` for state changes (offers, saved items, etc.)
- Add `.onTapGesture` for custom interactions

---

## 7. Image Handling System

### Requirements
Implement a complete image upload and display system:

#### Components Needed:
1. **ImagePicker Component** (UIViewRepresentable wrapper)
   - Support camera capture
   - Support photo library selection
   - Return `UIImage` to parent view

2. **Image Upload Service** (Mock for now)
   - Store images locally in app documents directory
   - Or store in AppState as base64 strings for demo
   - Return image URL/path

3. **AsyncImage Loader**
   - Load images from URLs
   - Show loading placeholder
   - Handle errors gracefully

4. **Image Caching**
   - Cache loaded images to avoid re-fetching
   - Use `SDWebImage` or native `AsyncImage` with caching

### Implementation Example
```swift
// ImagePicker.swift
import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    let sourceType: UIImagePickerController.SourceType
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, 
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.selectedImage = info[.originalImage] as? UIImage
            parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// Usage in any view:
@State private var showingImagePicker = false
@State private var profileImage: UIImage?

Button("Change Photo") {
    showingImagePicker = true
}
.sheet(isPresented: $showingImagePicker) {
    ImagePicker(selectedImage: $profileImage, sourceType: .photoLibrary)
}
```

---

## Technical Specifications

### Navigation Architecture
- Use `NavigationStack` (iOS 16+) for all main navigation
- Use `.navigationDestination` for type-safe navigation
- Use `.sheet()` for modal presentations (filters, make offer, etc.)
- Use `.fullScreenCover` for immersive flows (sell flow, onboarding)
- Implement custom swipe-back gestures where needed

### Performance Standards
- Maintain 60fps animations (use `withAnimation(.spring())`)
- Optimize image loading (resize thumbnails for lists)
- Use `LazyVStack` and `LazyVGrid` for scrollable content
- Handle error states gracefully (empty states, loading indicators)

### File Structure
Create these new files in `/midterm/GameTrade/Views/`:
```
Views/
├── ListingDetailView.swift      ← NEW
├── SearchView.swift             ← NEW
├── NotificationsView.swift      ← NEW
├── EditProfileView.swift        ← NEW
├── OtherProfileView.swift       ← NEW
├── SavedItemsView.swift         ← OPTIONAL (placeholder)
├── Components/
│   ├── ImagePicker.swift        ← NEW
│   ├── StarRating.swift         ← NEW
│   ├── ProductCard.swift        ← NEW (reusable)
│   ├── NotificationRow.swift    ← NEW
│   └── ReviewCard.swift         ← NEW
```

### State Management
- Extend `AppState` class to include:
  - `selectedListing: Listing?`
  - `isEditingProfile: Bool`
  - `showingImagePicker: Bool`
  - `notifications: [Notification]`
  - `searchQuery: String`
  - Methods for updating profile, adding reviews, etc.

---

## Delivery Checklist

### Screens
- [ ] ListingDetailView with image carousel and seller info
- [ ] SearchView with 3x3 grid and search bar
- [ ] NotificationsView with notification list
- [ ] EditProfileView with photo upload
- [ ] OtherProfileView with reviews
- [ ] SavedItemsView (optional placeholder)

### Components
- [ ] ImagePicker (camera + library)
- [ ] StarRating component
- [ ] ProductCard component
- [ ] NotificationRow component
- [ ] ReviewCard component
- [ ] VerificationBadge component

### Functionality
- [ ] All category filter buttons wired
- [ ] All listing taps navigate to detail
- [ ] Offer accept/reject updates state
- [ ] Edit profile saves changes
- [ ] Profile photo upload works
- [ ] Back button on all detail screens
- [ ] Swipe-back gesture on all pushed screens
- [ ] Search filtering works
- [ ] Notifications can be marked as read

### Polish
- [ ] Smooth animations on all transitions
- [ ] Loading states for images
- [ ] Error handling for failed loads
- [ ] Empty states for empty lists
- [ ] Haptic feedback on important actions

---

## Testing Points

Before considering task complete, verify:

1. ✅ Listing detail slides in smoothly from right (no lag)
2. ✅ Image carousel swipes properly with page indicator
3. ✅ Back button returns to previous screen
4. ✅ Swipe-from-edge gesture dismisses detail screen
5. ✅ Search filters results in real-time
6. ✅ Profile photo can be changed from library/camera
7. ✅ Edit profile changes persist after save
8. ✅ All buttons navigate to correct screens
9. ✅ Star ratings display correctly (filled/empty stars)
10. ✅ Verification badge shows for verified sellers
11. ✅ Reviews display in OtherProfileView
12. ✅ Notifications can be interacted with

---

## Priority Order

**Phase 1 (Core Experience):**
1. ListingDetailView (most critical for marketplace)
2. Wire up listing taps in MarketplaceView
3. Image handling system

**Phase 2 (User Flows):**
4. EditProfileView with photo upload
5. OtherProfileView
6. Wire up profile navigation

**Phase 3 (Discovery):**
7. SearchView
8. Wire up search button

**Phase 4 (Engagement):**
9. NotificationsView
10. Wire up offer actions
11. Polish and animations

---

## Notes for Agent

- Reference existing code patterns in `/midterm/GameTrade/Views/`
- Match the design system (purple theme: `#5B2FD9`)
- Use SF Symbols for icons where possible
- Keep code modular and reusable
- Add comments for complex logic
- Test on both light and dark mode
- Ensure accessibility (VoiceOver labels, dynamic type)

**Base Branch**: Work from the current branch in `/midterm`
**Target**: Complete all Phase 1 & 2 items minimum for MVP
