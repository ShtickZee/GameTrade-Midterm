import SwiftUI

struct OfferCardView: View {
    let title: String
    let subtitle: String
    let status: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(Text("🎮"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(status)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            }
            
            HStack(spacing: 12) {
                Button("Decline") { }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                Button("Accept ✓") { }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct OffersView: View {
    @ObservedObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Offers").font(.title2).bold()
                        Spacer()
                        Image(systemName: "message.fill")
                    }
                    .padding(.horizontal)
                    
                    Picker("Offers", selection: $selectedTab) {
                        Text("Incoming (2)").tag(0)
                        Text("Sent (3)").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        OfferCardView(
                            title: "kai_gamer",
                            subtitle: "offered $265 on Switch OLED — White",
                            status: "Pending"
                        )
                        OfferCardView(
                            title: "mia.trades",
                            subtitle: "wants to trade: Xbox Series S + $40 on PS4 Pro 1TB",
                            status: "Pending"
                        )
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Offers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mark all read") { }
                        .font(.caption)
                }
            }
        }
    }
}
