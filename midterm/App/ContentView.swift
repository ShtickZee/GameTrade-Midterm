import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            if !appState.isAuthenticated {
                NavigationStack {
                    LoginView(appState: appState)
                }
            } else if appState.onboarded {
                MainAppView(appState: appState)
            } else {
                OnboardingView(appState: appState)
            }
        }
    }
}

#Preview {
    ContentView()
}
