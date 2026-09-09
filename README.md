# GameTrade

GameTrade! Is a midterm project created as an E commerce application to solve the buy and sell market that is very big nowadays, allowing both buyers and sellers a marketplace where they are able to use the apps features to their full advantage instead of relying on something like Ebay or shoppee, GameTrade focuses on consoles such as PS4 and PS5, Nintendo Switch 1 and 2, XBOX and its consoles and the resell of physical game discs for all consoles.

## Current Functionality

The application is currently implemented as a SwiftUI project with a corresponding React/TypeScript UI prototype.

### Core Features

- **Onboarding Flow**: Manages initial user onboarding state.
- **Main App Navigation**: Uses a tab-based navigation system with the following tabs:
  - Deals (Home)
  - Marketplace
  - Offers
  - Profile
- **State Management**: Centralized application state (`AppState`) managing navigation, user onboarding status, and UI interaction states.
- **Views**:
  - `MarketplaceView`: Displays the main marketplace interface.
  - `DealsHomeView`: Provides a view for browsing deals.
  - `OffersView`: Manages user offers.
  - `ProfileView`: Handles user profile information and settings.
  - `ListingCardView`: Component for displaying individual product listings.

### Project Structure

The project is divided into:
- `/midterm`: Native SwiftUI implementation.
- `/UI Prototype (Midterm)`: React/TypeScript prototype for UI/UX reference.
