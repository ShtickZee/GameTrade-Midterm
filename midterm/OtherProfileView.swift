import SwiftUI

struct OtherProfileView: View {
    let userId: String
    let userName: String
    let rating: Double
    let bio: String
    let reviews: [Review]
    
    // Default initializer for preview purposes
    init(userId: String, userName: String = "Sarah Johnson", rating: Double = 4.8, bio: String = "Casual gamer and trader.", reviews: [Review] = []) {
        self.userId = userId
        self.userName = userName
        self.rating = rating
        self.bio = bio
        self.reviews = reviews
    }
    
    var body: some View {
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
                        .overlay(Text(String(userName.prefix(1))).font(.system(size: 40, weight: .bold)).foregroundColor(.purple))
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .offset(y: 50)
                }
                .padding(.bottom, 50)
                
                VStack(spacing: 4) {
                    Text(userName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Star rating display
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                // Reviews
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reviews (\(reviews.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(reviews) { review in
                            ReviewCard(
                                reviewerName: review.reviewerName,
                                rating: review.rating,
                                comment: review.comment,
                                date: review.date
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
