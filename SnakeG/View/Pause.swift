//
//  Pause.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 11/28/21.
//

import Foundation
import SwiftUI

struct PauseView : View {
    
    var body: some View {
        VStack{
            Text("Game Paused!")
            Button{
                
            } label: {
                Text("Reset")
            }
        }
    }
}


struct PauseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PauseView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
        }
        
    }
}

