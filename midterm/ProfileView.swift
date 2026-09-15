import SwiftUI

struct ProfileView: View {
    @ObservedObject var appState: AppState
    @State private var showVerificationSheet = false
    
    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
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
                            .overlay(Text(String(appState.userName.prefix(1))).font(.system(size: 40, weight: .bold)).foregroundColor(.purple))
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .offset(y: 50)
                    }

                    .padding(.bottom, 50)
                    
                    // Name & Verified
                    VStack(spacing: 4) {
                        HStack {
                            Text(appState.userName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        Text(appState.userHandle)
                            .foregroundColor(.gray)
                        Text("Member since Mar 2025 · \(appState.userLocation)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Stats
                    HStack(spacing: 0) {
                        StatView(value: "14", label: "Listings")
                        Divider().frame(height: 30)
                        StatView(value: "38", label: "Saved")
                        Divider().frame(height: 30)
                        StatView(value: "6", label: "Sold")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Menu
                    VStack {
                        MenuRow(icon: "shippingbox", title: "My Listings", trailing: "14")
                        MenuRow(icon: "heart", title: "Saved Items", trailing: "38")
                        MenuRow(icon: "bag", title: "Sold Items", trailing: "6")
                        
                        // Verification Button
                        Button {
                            showVerificationSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                Text("Verify your account")
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                            .foregroundColor(.purple)
                            .padding(.vertical, 10)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .sheet(isPresented: $showVerificationSheet) {
                        VerificationBenefitsView()
                            .presentationDetents([.fraction(0.75)])
                    }
                    
                    // Buttons
                    VStack(spacing: 16) {
                        NavigationLink(value: StackScreen.editProfile) {
                            Text("Edit profile")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.purple))
                        }
                        .padding(.horizontal)
                        
                        // Added Preview Button
                        NavigationLink(value: StackScreen.otherProfile(userId: "currentUser")) {
                            Text("View Profile Preview")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // New Buttons
                        Button("Switch account") { }
                            .secondaryButtonStyle()
                            .padding(.horizontal)
                        
                        Button("Logout") {
                            appState.logout()
                        }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: StackScreen.self) { screen in
                switch screen {
                case .editProfile:
                    EditProfileView(appState: appState)
                case .otherProfile(let userId):
                    // Preview own profile using same component
                    let isPreview = userId == "currentUser"
                    OtherProfileView(
                        userId: userId,
                        userName: isPreview ? appState.userName : "Sarah Johnson",
                        rating: 4.8,
                        bio: isPreview ? appState.userBio : "Gamer since 1990.",
                        reviews: isPreview ? [Review(reviewerName: "Mike", rating: 4, comment: "Great seller", date: "2 days ago")] : []
                    )
                default:
                    Text("Screen not implemented")
                }
            }
        }
    }
}

#Preview {
    ProfileView(appState: AppState())
}

struct VerificationBenefitsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Verify Your Account now!").font(.title2).bold()
            Text("See what are the benefits!").font(.subheadline).foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("1. The Verified Profile Badge")
                Text("2. Post more than 10 Listings a day!")
                Text("3. Occasional deals from official sellers such as Sony and Nintendo.")
                Text("4. You can send in the chat window how many people you have bought from or sold to to prove that you are trustworthy!")
                Text("5. Added Account Protection.")
            }
            Spacer()
        }
        .padding(30)
    }
}

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let trailing: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
            Text(trailing).foregroundColor(.gray)
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding(.vertical, 10)
    }
}
