import SwiftUI

struct ProfileView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 120)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .overlay(Text("A").font(.system(size: 40, weight: .bold)).foregroundColor(.purple))
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .offset(y: 50)
                    }
                    .padding(.bottom, 50)
                    
                    // Name & Verified
                    VStack(spacing: 4) {
                        HStack {
                            Text("Alex Reyes")
                                .font(.title2)
                                .fontWeight(.bold)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        Text("@alextrades")
                            .foregroundColor(.gray)
                        Text("Member since Mar 2025 · Makati")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Stats
                    HStack(spacing: 0) {
                        StatView(value: "14", label: "Listings")
                        Divider().frame(height: 30)
                        StatView(value: "38", label: "Saved")
                        Divider().frame(height: 30)
                        StatView(value: "6", label: "Sold")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Buttons
                    HStack {
                        Button("Edit profile") { }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.purple))
                            .cornerRadius(12)
                        
                        Button("Share profile") { }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Menu
                    VStack {
                        MenuRow(icon: "shippingbox", title: "My Listings", trailing: "14")
                        MenuRow(icon: "heart", title: "Saved Items", trailing: "38")
                        MenuRow(icon: "bag", title: "Sold Items", trailing: "6")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let trailing: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
            Text(trailing).foregroundColor(.gray)
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding(.vertical, 10)
    }
}
