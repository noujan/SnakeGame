//
//  GameView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 10/7/21.
//

import Foundation
import SwiftUI
import FirebaseAuth

class AppViewModel: ObservableObject {
    
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) {
            [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            
            //MARK: Success
            print("Signed In Successfully")
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
        
    }
    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) {
            [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            
            //MARK: Success
            print("Signed Up successfully")
            DispatchQueue.main.async {
                self?.signedIn = true

            }
        }
    }
    
}

struct GameView : View {
    
    @StateObject var viewModel = AppViewModel()
    
    var body: some View {
        ZStack{
            if viewModel.signedIn {
                SnakeGameView()
            } else {
                SignUpView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear() {
            viewModel.signedIn = viewModel.isSignedIn
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
