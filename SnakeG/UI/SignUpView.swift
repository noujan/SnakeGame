//
//  SignUpView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 10/7/21.
//

import Foundation
import SwiftUI


struct SignUpView : View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 50) {
            TextField("Username", text: $username)
                .multilineTextAlignment(.center)
                .overlay(VStack{Divider().offset(x: 0, y: 15)})
            TextField("Password", text: $password)
                .multilineTextAlignment(.center)
                .overlay(VStack{Divider().offset(x: 0, y: 15)})
            Button {
                print("Sign up button tapped")
            } label: {
                Text("Sign Up")
            }
        }
        .padding()
        .frame(width: UIScreen.screenWidth/2)
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignUpView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
        }
        
    }
}
