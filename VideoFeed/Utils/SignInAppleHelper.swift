//
//  SignInAppleHelper.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/15/24.
//

import Foundation
import AuthenticationServices
import CryptoKit


@MainActor
final class SignInAppleHelper : NSObject {
    
    fileprivate var currentNonce: String?
    private var completionHandler: ((Result<AppleSignInResultModel, Error>) -> Void)? = nil

    func startSignInWithAppleFlow() async throws -> AppleSignInResultModel{
        try await withCheckedThrowingContinuation { continuation in
            self.startSignInWithAppleFlow { result in
                switch result {
                case .success(let appleSignInResult):
                    continuation.resume(returning: appleSignInResult)
                    return
                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    @available(iOS 13, *)
    func startSignInWithAppleFlow(completion: @escaping (Result<AppleSignInResultModel, Error>) -> Void) {
        
        guard let topVC = Utilities.shared.topViewController() else{
            completion(.failure(URLError(.badServerResponse)))
            return
        }
      let nonce = randomNonceString()
      currentNonce = nonce
      completionHandler = completion
        
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = topVC
      authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

        
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

}





extension UIViewController :ASAuthorizationControllerPresentationContextProviding{
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension SignInAppleHelper: ASAuthorizationControllerDelegate{

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      
      guard
        let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
        let nonce = currentNonce,
        let appleIDToken = appleIDCredential.identityToken,
        let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data")
          completionHandler?(.failure(URLError(.badURL)))
        return
      }
      
      


      
     let tokens = AppleSignInResultModel(appleIDCredential: appleIDCredential, idTokenString: idTokenString, nonce: nonce)
     completionHandler?(.success(tokens))

      
    
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
    completionHandler?(.failure(URLError(.badURL)))

  }

}
