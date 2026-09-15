import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState 
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image Carousel
                TabView {
                    ForEach(listing.images, id: \.self) { image in
                        Image(image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 350)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(listing.title)
                        .font(.title)
                        .bold()
                    
                    Text("$\(Int(listing.price))")
                        .font(.title2)
                        .foregroundColor(.purple)
                        .bold()
                    
                    Text(listing.description)
                        .font(.body)
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Seller Section
                NavigationLink(value: StackScreen.otherProfile(userId: listing.sellerID)) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(Text(String(listing.sellerName.prefix(1))))
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(listing.sellerName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                if listing.isVerified {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", listing.sellerRating))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(listing.location)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button("Contact Seller") { }
                        .secondaryButtonStyle()
                    
                    Button("Make Offer") { }
                        .primaryButtonStyle()
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
            }
        }
    }
}
