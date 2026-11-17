import SwiftUI

struct ReviewCard: View {
    let reviewerName: String
    let rating: Double
    let comment: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Theme.primary.opacity(0.2))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(String(reviewerName.prefix(1)).uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.primary)
                        )
                    Text(reviewerName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.textPrimary)
                }

                Spacer()

                Text(date)
                    .font(.caption2)
                    .foregroundColor(Theme.textMuted)
            }
            
            // Star rating
            HStack(spacing: 3) {
                ForEach(0..<5) { i in
                    Image(systemName: i < Int(rating) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                }
            }
            
            Text(comment)
                .font(.footnote)
                .foregroundColor(Theme.textSecondary)
                .lineLimit(3)
        }
        .padding(14)
        .background(Theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
    }
}
