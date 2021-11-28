//
//  SignUpView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 10/7/21.
//

import Foundation
import SwiftUI

struct SignUpView : View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 50) {
            TextField("Email", text: $email)
                .multilineTextAlignment(.center)
                .overlay(VStack{Divider().offset(x: 0, y: 15)})
                .background(Color(UIColor.secondarySystemBackground))
                .disableAutocorrection(true)
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .multilineTextAlignment(.center)
                .overlay(VStack{Divider().offset(x: 0, y: 15)})
                .background(Color(UIColor.secondarySystemBackground))
                .disableAutocorrection(true)
                .autocapitalization(.none )
            Button {
                print("Sign In button tapped")
                guard !email.isEmpty, !password.isEmpty else {
                    return
                }
                viewModel.signIn(email: email, password: password)
                
            } label: {
                Text("Sign In")
            }
            .padding(.leading, UIScreen.screenWidth/8)
            
            Button {
                print("Sign up button tapped")
                guard !email.isEmpty, !password.isEmpty else {
                    return
                }
                viewModel.signUp(email: email, password: password)
            } label: {
                Text("Sign Up")
            }
            .padding(.leading, UIScreen.screenWidth/8)
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
