import SwiftUI

struct LoginView: View {
    @ObservedObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("Game Trade")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Sign In") {
                if email.isEmpty || password.isEmpty {
                    errorMessage = "Please fill in all fields."
                } else if email == appState.storedEmail && password == appState.storedPassword {
                    errorMessage = ""
                    appState.isAuthenticated = true
                } else {
                    errorMessage = "Invalid email or password."
                }
            }
            .primaryButtonStyle()
            .padding(.horizontal)
            
            Spacer()
            
            NavigationLink(destination: CreateAccountView(appState: appState)) {
                Text("Don't have an account yet? ") +
                Text("Create an account").bold().foregroundColor(.purple)
            }
            .padding(.bottom, 32)
        }
        .padding()
    }
}
