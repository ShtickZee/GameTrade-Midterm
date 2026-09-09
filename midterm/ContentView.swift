import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            if appState.onboarded {
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
