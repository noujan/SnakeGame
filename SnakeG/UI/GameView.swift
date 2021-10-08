//
//  GameView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 10/7/21.
//

import Foundation
import SwiftUI


struct GameView : View {
    var body: some View {
        ZStack{
            SnakeGameView()
            SignUpView()
        }
    }
}


struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
        }
        
    }
}
