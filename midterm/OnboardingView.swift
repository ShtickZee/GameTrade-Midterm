import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appState: AppState
    @State private var slide = 0
    
    struct Slide {
        let emoji: String
        let gradient: LinearGradient
        let title: String
        let sub: String
    }
    
    let slides = [
        Slide(emoji: "🎮", gradient: LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing), title: "Welcome to GameTrade!", sub: "Buy, sell, and trade PlayStation, Xbox, and Nintendo Switch consoles — all in one place."),
        Slide(emoji: "🛍️", gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing), title: "Real Deals, Every Day", sub: "Official store discounts, flash sales, and seasonal drops on the consoles you want."),
        Slide(emoji: "📸", gradient: LinearGradient(colors: [.purple.opacity(0.8), .purple], startPoint: .topLeading, endPoint: .bottomTrailing), title: "Sell in Minutes", sub: "Snap a few photos, set your price, and reach thousands of local gamers."),
        Slide(emoji: "🔄", gradient: LinearGradient(colors: [.green, .purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing), title: "Trade, Not Just Buy", sub: "Propose console-for-console trades and close the deal your way.")
    ]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if slide < slides.count - 1 {
                    Button("Skip") {
                        appState.onboarded = true
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(slides[slide].gradient)
                    .frame(width: 280, height: 280)
                    .shadow(color: .purple.opacity(0.25), radius: 20, y: 20)
                
                Text(slides[slide].emoji)
                    .font(.system(size: 100))
            }
            .padding(.bottom, 40)
            
            Text(slides[slide].title)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            
            Text(slides[slide].sub)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            HStack(spacing: 8) {
                ForEach(0..<slides.count, id: \.self) { i in
                    Capsule()
                        .fill(i == slide ? Color.purple : Color.purple.opacity(0.5))
                        .frame(width: i == slide ? 24 : 8, height: 8)
                }
            }
            .padding(.vertical, 24)
            
            Button(slide == slides.count - 1 ? "Get Started 🚀" : "Next") {
                if slide == slides.count - 1 {
                    appState.onboarded = true
                } else {
                    slide += 1
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }
}
