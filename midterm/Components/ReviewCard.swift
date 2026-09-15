import SwiftUI

struct ReviewCard: View {
    let reviewerName: String
    let rating: Double
    let comment: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(reviewerName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            // Star rating placeholder
            HStack(spacing: 2) {
                ForEach(0..<5) { i in
                    Image(systemName: i < Int(rating) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                }
            }
            
            Text(comment)
                .font(.subheadline)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}
