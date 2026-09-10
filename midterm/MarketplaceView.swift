import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.purple : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .black)
            .clipShape(Capsule())
    }
}

struct MarketplaceView: View {
    @ObservedObject var appState: AppState
    
    // Mock listings for display
    let listings = [
        Listing(id: "L1", title: "PS5 Disc Edition — 1TB", price: 430, was: 499, platform: .ps5, condition: .likeNew, sellerId: "jordan", location: "Quezon City", saved: false, bundle: nil, images: nil, description: nil),
        Listing(id: "L2", title: "Xbox Series X — 1TB", price: 350, was: nil, platform: .xbox, condition: .good, sellerId: "mia", location: "Makati", saved: true, bundle: nil, images: nil, description: nil),
        Listing(id: "L3", title: "Nintendo Switch OLED — White", price: 280, was: nil, platform: .switchConsole, condition: .likeNew, sellerId: "gamehaven", location: "BGC", saved: false, bundle: nil, images: nil, description: nil),
        Listing(id: "L4", title: "PS4 Pro 1TB", price: 150, was: 169, platform: .ps4, condition: .fair, sellerId: "alex", location: "Pasig", saved: false, bundle: nil, images: nil, description: nil)
    ]
    
    @State private var searchText = ""
    @State private var showingFilters = false
    
    // Updated data model to support categories and filtering
    enum Category: String, CaseIterable {
        case all = "All", gameDiscs = "Game Discs", consoles = "Consoles for Sale", others = "Others"
    }
    
    @State private var selectedPlatform: Platform? = nil
    @State private var selectedCategory: Category = .all

    var filteredListings: [Listing] {
        listings.filter { listing in
            let matchesSearch = searchText.isEmpty || listing.title.localizedCaseInsensitiveContains(searchText)
            let matchesPlatform = selectedPlatform == nil || listing.platform == selectedPlatform
            // Category filtering would require more complex mapping based on listing type,
            // placeholder logic for now
            return matchesSearch && matchesPlatform
        }
    }

    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Filter & Search & Add
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Marketplace").font(.title2).bold()
                            Spacer()
                            Image(systemName: "message.fill")
                        }
                        .padding(.horizontal)
                        
                        // Filter Menu
                        HStack {
                            Button {
                                showingFilters.toggle()
                            } label: {
                                HStack {
                                    Text("Filter")
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                }
                                .foregroundColor(.primary)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            TextField("Search marketplace...", text: $searchText)
                                .padding(10)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            
                            Button {
                                // TODO: Add Listing flow
                            } label: {
                                Text("Add Listing")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    .sheet(isPresented: $showingFilters) {
                        // TODO: Implement Filter Sheet
                        Text("Filters").presentationDetents([.medium])
                    }

                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(title: "All", isSelected: true)
                            FilterChip(title: "PlayStation", isSelected: false)
                            FilterChip(title: "Xbox", isSelected: false)
                            FilterChip(title: "Switch", isSelected: false)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Featured Header
                    Text("Featured — verified sellers")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    // Featured Card (Placeholder)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.purple.opacity(0.8))
                        .frame(height: 150)
                        .padding(.horizontal)
                        
                    // Listings Grid
                    Text("\(filteredListings.count) listings")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredListings) { listing in
                            ListingCardView(listing: listing)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Marketplace")
        }
    }
}
