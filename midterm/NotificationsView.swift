import SwiftUI

struct NotificationsView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(appState.notifications) { notification in
                    NotificationRow(
                        title: notification.title,
                        subtitle: "Check it out now!",
                        time: notification.time
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Notifications")
    }
}
