import SwiftUI

struct NotificationRow: View {
    let title: String
    let subtitle: String
    let time: String
    var isRead: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.purple)
                .frame(width: 10, height: 10)
                .padding(.top, 4)
                .opacity(isRead ? 0 : 1)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(isRead ? Color.clear : Color.purple.opacity(0.05))
        .cornerRadius(12)
    }
}
