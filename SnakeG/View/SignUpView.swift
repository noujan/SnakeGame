//
//  SignUpView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 10/7/21.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var viewModel: AuthViewModel

    private var canSubmit: Bool { !email.isEmpty && !password.isEmpty }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                header

                VStack(spacing: 14) {
                    AuthField(systemImage: "envelope",
                              placeholder: "Email",
                              text: $email,
                              isSecure: false)
                    AuthField(systemImage: "lock",
                              placeholder: "Password",
                              text: $password,
                              isSecure: true)
                }

                if let message = viewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: 12) {
                    primaryButton(title: "Sign In") {
                        guard canSubmit else { return }
                        viewModel.signIn(email: email, password: password)
                    }

                    secondaryButton(title: "Create an account") {
                        guard canSubmit else { return }
                        viewModel.signUp(email: email, password: password)
                    }
                }

                orSeparator

                googleButton

                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 60)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "scribble.variable")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundColor(.pink)
            Text("SnakeG")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text("Sign in to play and save your score")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var orSeparator: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            Text("or").font(.footnote).foregroundColor(.secondary)
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
        }
    }

    private var googleButton: some View {
        Button {
            viewModel.signInWithGoogle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "g.circle.fill")
                    .font(.title3)
                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
            )
        }
        .foregroundColor(.primary)
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(canSubmit ? Color.pink : Color.pink.opacity(0.4))
                )
                .foregroundColor(.white)
        }
        .disabled(!canSubmit)
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .foregroundColor(.pink)
        .disabled(!canSubmit)
    }
}

private struct AuthField: View {
    let systemImage: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
                .frame(width: 18)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }
            }
            .disableAutocorrection(true)
            .autocapitalization(.none)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignUpView()
                .environmentObject(AuthViewModel())
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
        }
    }
}
