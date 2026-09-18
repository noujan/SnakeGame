//
//  Menu.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 11/28/21.
//

import Foundation
import SwiftUI

struct MenuView : View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.pink.opacity(0.25), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                // Branding
                VStack(spacing: 10) {
                    SnakeLogo(cell: 14, color: .pink)
                    Text("SnakeG")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                }
                .padding(.top, 24)

                // Menu options
                VStack(spacing: 14) {
                    MenuButton(title: "Resume", systemImage: "play.fill", isPrimary: true) {
                        isPresented = false
                    }
                    MenuButton(title: "Leaderboard", systemImage: "list.number") {
                        GameCenterManager.shared.showLeaderboard()
                    }
                    MenuButton(title: "Multiplayer", systemImage: "person.2.fill") {}
                    MenuButton(title: "More", systemImage: "ellipsis.circle") {}
                }
                .padding(.horizontal, 28)

                Spacer()
            }
        }
    }
}

/// A single retro-styled menu row.
private struct MenuButton: View {
    let title: String
    let systemImage: String
    var isPrimary: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isPrimary ? Color.pink : Color(.secondarySystemBackground))
            )
            .foregroundColor(isPrimary ? .white : .primary)
        }
    }
}


struct MenuView_Previews: PreviewProvider {
    @State static var showingMenu = true

    static var previews: some View {
        Group {
            MenuView(isPresented: $showingMenu)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
        }

    }
}
