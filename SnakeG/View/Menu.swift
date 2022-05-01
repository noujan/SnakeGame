//
//  Menu.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 11/28/21.
//

import Foundation
import SwiftUI

struct MenuView : View {
    
    var body: some View {
        VStack{
            List{
                Text("Play")
                Text("Leaderboard")
                Text("Multiplayer")
                Text("More")
            }
            
        }
    }
}


struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MenuView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
        }
        
    }
}

