import SwiftUI

struct ListingCardView: View {
    let listing: Listing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder for image
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)
                .overlay(Text("📷").font(.largeTitle))
            
            Text(listing.title)
                .font(.subheadline)
                .lineLimit(2)
            
            Text("$\(Int(listing.price))")
                .font(.headline)
                .foregroundColor(.purple)
            
            HStack {
                Text(listing.condition.rawValue)
                    .font(.caption2)
                    .padding(4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                
                Spacer()
                
                Text(listing.location)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
