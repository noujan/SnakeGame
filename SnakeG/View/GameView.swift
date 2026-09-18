//
//  GameView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 10/7/21.
//

import Foundation
import SwiftUI

struct GameView : View {
    @StateObject var viewModel = AuthViewModel()
    @State private var showLaunchScreen = true

    var body: some View {
        ZStack{
            if viewModel.signedIn {
                SnakeGameView()
            } else {
                SignUpView()
            }

            if showLaunchScreen {
                LaunchScreen {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showLaunchScreen = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .environmentObject(viewModel)
        .onAppear() {
            viewModel.signedIn = viewModel.isSignedIn
            GameCenterManager.shared.authenticate()
        }
    }
}


struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
        }
        
    }
}
