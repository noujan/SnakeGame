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

        VStack{
            List{
                Button("Dismiss") {
                    isPresented = false
                }
                Text("Play")
                Text("Leaderboard")
                Text("Multiplayer")
                Text("More")
            }
            
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

