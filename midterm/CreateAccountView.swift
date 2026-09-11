import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("Create Account")
                .font(.title)
                .bold()
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Create Account") {
                if email.isEmpty {
                    errorMessage = "Email cannot be empty."
                } else if password.count < 6 {
                    errorMessage = "Password must be at least 6 characters."
                } else if password != confirmPassword {
                    errorMessage = "Passwords do not match."
                } else {
                    errorMessage = ""
                    appState.isAuthenticated = true
                    appState.onboarded = false
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button("Already have an account? Sign in") {
                dismiss()
            }
            .font(.footnote)
            .foregroundColor(.purple)
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
