//
//  Auth.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 11/28/21.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class AuthViewModel: ObservableObject {

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

    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing Firebase clientID; cannot start Google sign-in")
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let presenter = Self.topPresentingViewController() else {
            print("No presenting view controller available")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presenter) { [weak self] result, error in
            guard error == nil,
                  let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Google sign-in failed: \(error?.localizedDescription ?? "unknown")")
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            self?.auth.signIn(with: credential) { authResult, err in
                guard authResult != nil, err == nil else {
                    print("Firebase sign-in with Google credential failed: \(err?.localizedDescription ?? "unknown")")
                    return
                }
                print("Signed In with Google Successfully")
                DispatchQueue.main.async {
                    self?.signedIn = true
                }
            }
        }
    }

    func signOut() {
        try? auth.signOut()
        GIDSignIn.sharedInstance.signOut()
        self.signedIn = false
    }

    // Walks the active scene to find a view controller capable of presenting
    // the Google sign-in sheet from a SwiftUI context.
    private static func topPresentingViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        guard var top = scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }

}
