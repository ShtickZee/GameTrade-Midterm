import SwiftUI

struct DateSeparatorView: View {
    let date: Date

    var dateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack { Divider().background(Color.gray.opacity(0.3)) }
            Text(dateLabel)
                .font(.caption2.bold())
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
            VStack { Divider().background(Color.gray.opacity(0.3)) }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}
