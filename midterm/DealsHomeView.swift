import SwiftUI
import Combine

struct CategoryItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

#Preview {
    DealsHomeView(appState: AppState())
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
    
    @State private var timeRemaining = 2 * 3600 + 14 * 60 + 32
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Carousel state
    @State private var carouselIndex = 0
    let carouselItems = ["gamecontroller", "shippingbox", "bolt"]
    let carouselTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d : %02d : %02d", hours, minutes, seconds)
    }

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
                            Image(systemName: "message.fill")
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
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("SPRING RESET SALE").font(.caption).foregroundColor(.white.opacity(0.8))
                                    Text("Trade in your old\nconsole level up").font(.title2).bold().foregroundColor(.white)
                                    Button("Start trading") {}.padding(.vertical, 8).padding(.horizontal, 16).background(.white).cornerRadius(8)
                                }
                                .padding(.leading, 32)
                                Spacer()
                                Image(systemName: "gamecontroller.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 32)
                            },
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
                    VStack(spacing: 16) {
                        HStack {
                            Text("⚡️ Flash Deals").font(.headline)
                            Spacer()
                            Text(formatTime(timeRemaining)).font(.system(.subheadline, design: .monospaced)).padding(8).background(Color.orange.opacity(0.2)).cornerRadius(8)
                                .onReceive(timer) { _ in
                                    if timeRemaining > 0 {
                                        timeRemaining -= 1
                                    }
                                }
                        }
                        .padding(.horizontal)
                        
                        // Carousel
                        TabView(selection: $carouselIndex) {
                            ForEach(0..<carouselItems.count, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.orange.opacity(0.2))
                                    .overlay(Image(systemName: carouselItems[index]).font(.system(size: 50)))
                            }
                        }
                        .frame(height: 150)
                        .tabViewStyle(PageTabViewStyle())
                        .onReceive(carouselTimer) { _ in
                            withAnimation {
                                carouselIndex = (carouselIndex + 1) % carouselItems.count
                            }
                        }
                        
                        // 3x3 Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            ForEach(0..<9, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.05))
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
    }
}
