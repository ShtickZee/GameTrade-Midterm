import SwiftUI

struct SearchView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var filteredListings: [Listing] {
        if appState.searchQuery.isEmpty {
            return appState.listings
        } else {
            return appState.listings.filter { 
                $0.title.localizedCaseInsensitiveContains(appState.searchQuery) ||
                $0.platform.rawValue.localizedCaseInsensitiveContains(appState.searchQuery)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Search Bar
                    TextField("Search Games...", text: $appState.searchQuery)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    // Listings
                    Text("Listings")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(filteredListings) { listing in
                            ListingCardView(listing: listing)
                                .onTapGesture {
                                    appState.navigate(to: .listing(listingId: listing.id))
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                appState.fetchListings()
            }
        }
    }
}
