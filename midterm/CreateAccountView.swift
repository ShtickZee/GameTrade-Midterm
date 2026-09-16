import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    
    // Email validation logic
    var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    var body: some View {
        NavigationStack {
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
                        .autocorrectionDisabled()
                        .overlay(
                            Image(systemName: isEmailValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(isEmailValid ? .green : .red)
                                .padding(.trailing, 8),
                            alignment: .trailing
                        )
                    
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
                    if !isEmailValid {
                        errorMessage = "Invalid email format."
                    } else if password.count < 6 {
                        errorMessage = "Password must be at least 6 characters."
                    } else if password != confirmPassword {
                        errorMessage = "Passwords do not match."
                    } else {
                        errorMessage = ""
                        // Save credentials
                        appState.storedEmail = email
                        appState.storedPassword = password
                        
                        // Initialize default profile data
                        appState.userEmail = email
                        
                        // Proceed to profile setup
                        appState.shouldSetupProfile = true
                    }
                }
                .disabled(!isEmailValid || password.isEmpty || confirmPassword.isEmpty)
                .primaryButtonStyle()
                .padding(.horizontal)
                
                Button("Already have an account? Sign in") {
                    dismiss()
                }
                .font(.footnote)
                .foregroundColor(.purple)
                
                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $appState.shouldSetupProfile) {
                ProfileSetupView(appState: appState)
            }
        }
    }
}
