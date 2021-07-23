//
//  LoginViewController.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var facebookLoginButton: UIButton!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

//MARK: - IBActions -

extension LoginViewController {
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        guard UITextField.checkFields(fields: [emailTextField, passwordTextField]) != false else {
            Alerter.showOneButtonAlert(on: self, title: .oops, message: .checkFields, actionTitle: .ok, handler: nil)
            return
        }
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
            guard authDataResult != nil,
                  error == nil else {
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                return
            }
            // to do - send to app
        }
    }
    
    @IBAction func didTapLoginWithFacebookButton(_ sender: Any) {
    }
    
    @IBAction func didTapLoginWithGoogleButton(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    let authError = error as NSError
                    if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                        // The user is a multi-factor user. Second factor challenge is required.
                        let resolver = authError
                            .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                        var displayNameString = ""
                        for tmpFactorInfo in resolver.hints {
                            displayNameString += tmpFactorInfo.displayName ?? ""
                            displayNameString += " "
                        }
                        self.showTextInputPrompt(
                            withMessage: "Select factor to sign in\n\(displayNameString)",
                            completionBlock: { userPressedOK, displayName in
                                var selectedHint: PhoneMultiFactorInfo?
                                for tmpFactorInfo in resolver.hints {
                                    if displayName == tmpFactorInfo.displayName {
                                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                                    }
                                }
                                PhoneAuthProvider.provider()
                                    .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                                       multiFactorSession: resolver
                                                        .session) { verificationID, error in
                                        if error != nil {
                                            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                                        } else {
                                            self.showTextInputPrompt(
                                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                                completionBlock: { userPressedOK, verificationCode in
                                                    let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                                        .credential(withVerificationID: verificationID!,
                                                                    verificationCode: verificationCode!)
                                                    let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                                        .assertion(with: credential!)
                                                    resolver.resolveSignIn(with: assertion!) { authResult, error in
                                                        if error != nil {
                                                            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                                                        } else {
                                                            self.navigationController?.popViewController(animated: true)
                                                        }
                                                    }
                                                }
                                            )
                                        }
                                    }
                            }
                        )
                    } else {
                        Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                        return
                    }
                    return
                }
                // to do - send to the app
            }
        }
    }
    
    @IBAction func didTapLoginWithGithubButton(_ sender: Any) {
    }
    
}
