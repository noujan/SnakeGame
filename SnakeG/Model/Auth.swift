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
    @Published var errorMessage: String?

    var isSignedIn: Bool {
        return auth.currentUser != nil
    }

    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) {
            [weak self] result, error in
            if let error = error {
                self?.publishError(error.localizedDescription)
                return
            }
            guard result != nil else { return }
            DispatchQueue.main.async {
                self?.errorMessage = nil
                self?.signedIn = true
            }
        }
    }

    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) {
            [weak self] result, error in
            if let error = error {
                self?.publishError(error.localizedDescription)
                return
            }
            guard result != nil else { return }
            DispatchQueue.main.async {
                self?.errorMessage = nil
                self?.signedIn = true
            }
        }
    }

    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            publishError("Missing Firebase clientID; cannot start Google sign-in")
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let presenter = Self.topPresentingViewController() else {
            publishError("No presenting view controller available")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presenter) { [weak self] result, error in
            if let error = error {
                self?.publishError("Google sign-in failed: \(error.localizedDescription)")
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.publishError("Google sign-in returned no token")
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            self?.auth.signIn(with: credential) { authResult, err in
                if let err = err {
                    self?.publishError("Firebase sign-in failed: \(err.localizedDescription)")
                    return
                }
                guard authResult != nil else { return }
                DispatchQueue.main.async {
                    self?.errorMessage = nil
                    self?.signedIn = true
                }
            }
        }
    }

    private func publishError(_ message: String) {
        print(message)
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = message
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
