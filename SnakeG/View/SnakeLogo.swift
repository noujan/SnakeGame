//
//  SnakeLogo.swift
//  SnakeG
//
//  A retro, pixel-art snake used for branding (sign-in header, menus, etc.).
//

import SwiftUI

/// A small grid-based snake drawn from square "pixels", echoing the classic
/// Nokia snake look. Purely decorative and self-contained (no image assets).
struct SnakeLogo: View {
    var cell: CGFloat = 14
    var color: Color = .pink

    // Body layout on a 6x5 grid. `.some` = body segment, `.head` = head.
    private enum Pixel { case empty, body, head }

    private let layout: [[Pixel]] = [
        [.empty, .body,  .body,  .body,  .empty, .empty],
        [.empty, .body,  .empty, .empty, .empty, .empty],
        [.empty, .body,  .body,  .body,  .body,  .empty],
        [.empty, .empty, .empty, .empty, .body,  .empty],
        [.empty, .body,  .body,  .body,  .body,  .head ],
    ]

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<layout.count, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<layout[row].count, id: \.self) { col in
                        cellView(for: layout[row][col])
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func cellView(for pixel: Pixel) -> some View {
        switch pixel {
        case .empty:
            Color.clear
                .frame(width: cell, height: cell)
        case .body:
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: cell, height: cell)
        case .head:
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: cell, height: cell)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: cell * 0.28, height: cell * 0.28)
                        .offset(x: cell * 0.18, y: -cell * 0.15)
                )
        }
    }
}

struct SnakeLogo_Previews: PreviewProvider {
    static var previews: some View {
        SnakeLogo()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
