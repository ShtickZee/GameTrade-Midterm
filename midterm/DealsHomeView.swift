import SwiftUI

struct CategoryItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

struct DealsHomeView: View {
    @ObservedObject var appState: AppState
    
    let categories = [
        CategoryItem(title: "PlayStation", icon: "gamecontroller.fill", color: .blue.opacity(0.1)),
        CategoryItem(title: "Xbox", icon: "xbox.logo", color: .green.opacity(0.1)),
        CategoryItem(title: "Switch", icon: "nintendo.switch.fill", color: .red.opacity(0.1)),
        CategoryItem(title: "Controllers", icon: "gamecontroller", color: .gray.opacity(0.1)),
        CategoryItem(title: "Bundles", icon: "shippingbox.fill", color: .orange.opacity(0.1)),
        CategoryItem(title: "Deals of Day", icon: "bolt.fill", color: .orange.opacity(0.1)),
        CategoryItem(title: "Official Stores", icon: "building.2.fill", color: .green.opacity(0.1)),
        CategoryItem(title: "Accessories", icon: "headphones", color: .gray.opacity(0.1))
    ]
    
    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    // Header & Search
                    VStack(spacing: 12) {
                        HStack {
                            Text("Game").font(.title2).bold() + Text("Trade!").font(.title2).bold().foregroundColor(.purple)
                            Text("⚡️")
                            Spacer()
                            Image(systemName: "bell.fill")
                        }
                        .padding(.horizontal)
                        
                        TextField("Search PS5, Xbox Series X, Switch...", text: .constant(""))
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Promo Banner
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 160)
                        .padding(.horizontal)
                        .overlay(
                            VStack(alignment: .leading) {
                                Text("SPRING RESET SALE").font(.caption).foregroundColor(.white.opacity(0.8))
                                Text("Trade in your old\nconsole level up").font(.title2).bold().foregroundColor(.white)
                                Button("Start trading") {}.padding(.vertical, 8).padding(.horizontal, 16).background(.white).cornerRadius(8)
                            }
                            .padding(.leading, 32),
                            alignment: .leading
                        )
                    
                    // Categories
                    VStack(alignment: .leading) {
                        Text("Browse by category").font(.headline).padding(.horizontal)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(categories) { cat in
                                VStack {
                                    Image(systemName: cat.icon).font(.title2).foregroundColor(.primary)
                                        .frame(width: 50, height: 50).background(cat.color).cornerRadius(12)
                                    Text(cat.title).font(.caption2).multilineTextAlignment(.center)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Flash Deals
                    HStack {
                        Text("⚡️ Flash Deals").font(.headline)
                        Spacer()
                        Text("02 : 14 : 32").font(.system(.subheadline, design: .monospaced)).padding(8).background(Color.orange.opacity(0.2)).cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
    }
}
