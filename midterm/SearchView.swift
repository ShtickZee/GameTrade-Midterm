import SwiftUI

struct SearchView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    // Placeholder data
    let items = Array(0..<9)
    
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
                    
                    // Listings Near You
                    Text("Listings Near You")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(items, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(Text("🎮"))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Trending Searches
                    Text("Trending Searches")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        ForEach(["#PS5", "#Xbox", "#Switch"], id: \.self) { tag in
                            Text(tag)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(20)
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
        }
    }
}
