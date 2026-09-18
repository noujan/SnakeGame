//
//  LaunchScreen.swift
//  SnakeG
//
//  Animated startup screen shown when the app launches, built around the
//  retro `SnakeLogo` branding so players immediately see what's happening.
//

import SwiftUI

/// A self-contained splash screen that animates the snake logo in, reveals the
/// "SnakeG" wordmark, and shows a subtle loading indicator. Purely decorative –
/// it fades itself out and calls `onFinished` when the intro completes.
struct LaunchScreen: View {
    /// Called once the intro animation has finished.
    var onFinished: () -> Void = {}

    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 12
    @State private var dotsPhase: Int = 0

    // Animated loading dots.
    private let dotTimer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Deep, game-like backdrop with a soft pink glow behind the logo.
            LinearGradient(
                colors: [Color.black, Color(red: 0.10, green: 0.02, blue: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.pink.opacity(0.35), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 260
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                SnakeLogo(cell: 22, color: .pink)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .shadow(color: .pink.opacity(0.6), radius: 20)

                VStack(spacing: 12) {
                    Text("SnakeG")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .pink],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Loading dots that cycle while the app gets ready.
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.pink)
                                .frame(width: 8, height: 8)
                                .opacity(dotsPhase == index ? 1 : 0.25)
                        }
                    }
                }
                .opacity(titleOpacity)
                .offset(y: titleOffset)
            }
        }
        .onReceive(dotTimer) { _ in
            dotsPhase = (dotsPhase + 1) % 3
        }
        .onAppear(perform: runIntro)
    }

    private func runIntro() {
        // Logo springs in.
        withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) {
            logoScale = 1
            logoOpacity = 1
        }

        // Title fades up shortly after.
        withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
            titleOpacity = 1
            titleOffset = 0
        }

        // Hand off to the app once the intro has played.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            onFinished()
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
    }
}
