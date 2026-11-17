import SwiftUI

struct ProfileView: View {
    @ObservedObject var appState: AppState
    @State private var showVerificationSheet = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack(path: $appState.profileNavPath) {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header Banner
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Theme.heroGradient)
                                .frame(height: 120)
                            
                            Circle()
                                .fill(Theme.surface)
                                .frame(width: 96, height: 96)
                                .overlay(
                                    Text(String(appState.userName.isEmpty ? "T" : appState.userName.prefix(1)).uppercased())
                                        .font(.system(size: 38, weight: .heavy))
                                        .foregroundColor(Theme.primary)
                                )
                                .overlay(Circle().stroke(Theme.border, lineWidth: 3))
                                .offset(y: 48)
                        }
                        .padding(.bottom, 48)
                        
                        // Name & Verified Status
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Text(appState.userName.isEmpty ? "Gamer" : appState.userName)
                                    .font(.title2.bold())
                                    .foregroundColor(Theme.textPrimary)
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Theme.cyberBlue)
                            }
                            Text(appState.userHandle)
                                .font(.subheadline)
                                .foregroundColor(Theme.cyberBlue)
                            Text("Member since Mar 2025 · \(appState.userLocation.isEmpty ? "Makati" : appState.userLocation)")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        // Gamer Stats
                        HStack(spacing: 0) {
                            StatView(value: "14", label: "Listings")
                            Divider().frame(height: 30).background(Theme.border)
                            StatView(value: "38", label: "Saved")
                            Divider().frame(height: 30).background(Theme.border)
                            StatView(value: "6", label: "Trades")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal)
                        
                        // Account Menu
                        VStack(spacing: 4) {
                            MenuRow(icon: "shippingbox.fill", title: "My Listings", trailing: "14")
                            Divider().background(Theme.border.opacity(0.5))
                            MenuRow(icon: "heart.fill", title: "Saved Items", trailing: "38")
                            Divider().background(Theme.border.opacity(0.5))
                            MenuRow(icon: "bag.fill", title: "Sold Hardware", trailing: "6")
                            Divider().background(Theme.border.opacity(0.5))
                            
                            // Verification Button
                            Button {
                                showVerificationSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Theme.cyberBlue)
                                    Text("Verify your account")
                                        .font(.subheadline.bold())
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Theme.textMuted)
                                        .font(.caption)
                                }
                                .padding(.vertical, 10)
                            }
                        }
                        .padding(16)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal)
                        .sheet(isPresented: $showVerificationSheet) {
                            VerificationBenefitsView()
                                .presentationDetents([.fraction(0.75)])
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            NavigationLink(value: StackScreen.editProfile) {
                                Text("Edit Profile")
                                    .secondaryButtonStyle()
                            }
                            .padding(.horizontal)
                            
                            NavigationLink(value: StackScreen.otherProfile(userId: "currentUser")) {
                                Text("View Public Profile")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Theme.surfaceElevated)
                                    .foregroundColor(Theme.cyberBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cyberBlue.opacity(0.4), lineWidth: 1))
                            }
                            .padding(.horizontal)
                            
                            Button("Logout") {
                                appState.logout()
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.3), lineWidth: 1))
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: StackScreen.self) { screen in
                switch screen {
                case .editProfile:
                    EditProfileView(appState: appState)
                case .otherProfile(let userId):
                    OtherProfileView(userId: userId, appState: appState)
                        .environmentObject(appState)
                case .chatDetail(let chatId):
                    ChatDetailView(chatId: chatId, appState: appState)
                        .environmentObject(appState)
                default:
                    Text("Screen not implemented")
                }
            }
        }
    }
}

struct VerificationBenefitsView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title)
                        .foregroundColor(Theme.cyberBlue)
                    Text("Verify Your Account")
                        .font(.title2.bold())
                        .foregroundColor(Theme.textPrimary)
                }

                Text("Join our verified circle of hardware traders.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                
                VStack(alignment: .leading, spacing: 14) {
                    benefitRow(num: "1", title: "Verified Profile Badge", desc: "Gain instant trust on all listings.")
                    benefitRow(num: "2", title: "Unlimited Listings", desc: "Post more than 10 console listings a day.")
                    benefitRow(num: "3", title: "Official Store Drops", desc: "Access verified retailer inventory.")
                    benefitRow(num: "4", title: "Reputation Counter", desc: "Display your successful trades badge in chat.")
                    benefitRow(num: "5", title: "48-Hour Hardware Guarantee", desc: "Priority dispute resolution.")
                }
                Spacer()
            }
            .padding(28)
        }
    }

    private func benefitRow(num: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(num)
                .font(.caption.bold())
                .foregroundColor(Theme.primary)
                .frame(width: 24, height: 24)
                .background(Theme.surfaceElevated)
                .clipShape(Circle())
                .overlay(Circle().stroke(Theme.primary.opacity(0.4), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
    }
}

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(Theme.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let trailing: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.primary)
                .frame(width: 20)
            Text(title)
                .font(.subheadline)
                .foregroundColor(Theme.textPrimary)
            Spacer()
            Text(trailing)
                .font(.subheadline.bold())
                .foregroundColor(Theme.cyberBlue)
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.textMuted)
                .font(.caption2)
        }
        .padding(.vertical, 8)
    }
}
