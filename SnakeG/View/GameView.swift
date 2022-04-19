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
    
    var body: some View {
        ZStack{
            if viewModel.signedIn {
                SnakeGameView()
            } else {
                SignUpView()
            }
        }
        .environmentObject(viewModel)
        .onAppear() {
            viewModel.signedIn = viewModel.isSignedIn
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
