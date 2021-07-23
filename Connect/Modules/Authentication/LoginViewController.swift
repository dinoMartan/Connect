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
import Alamofire

class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var facebookLoginButton: UIButton!
    
    //MARK: - Private properties
    
    var provider: OAuthProvider?
    let fbLoginButton = FBLoginButton()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
}

//MARK: - Setup and configuration -

private extension LoginViewController {
    
    //MARK: - View setup
    
    private func setupView() {
        configureFacebookLoginButton()
    }
    
    //MARK: - FacebookLoginButton configuraton
    
    private func configureFacebookLoginButton() {
        fbLoginButton.isHidden = true
        view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
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
            self.sendToApp()
        }
    }
    
    @IBAction func didTapFacebookLoginButton(_ sender: Any) {
        fbLoginButton.sendActions(for: .touchUpInside)
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
                              print(
                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
                              )
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
                                      print(
                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                      )
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
                sendToApp()
            }
        }
    }
    
    @IBAction func didTapLoginWithGithubButton(_ sender: Any) {
        provider = OAuthProvider(providerID: AuthProviders.github.rawValue)
        provider!.getCredentialWith(nil) { credential, error in
            if error != nil {
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
            }
            if credential != nil {
                Auth.auth().signIn(with: credential!) { authResult, error in
                    if error != nil {
                        Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                    }

                    guard let oauthCredential = authResult?.credential as? OAuthCredential else { return }
                    guard let accessToken = oauthCredential.accessToken else { return }
                    let headers = HTTPHeaders(["Authorization" : "token \(accessToken)"])
                    ApiCaller.shared.getRequest(type: GithubResponse.self, apiUrl: .githubAccountDetails, headers: headers) { response in
                        #warning("to do - add user details")
                        self.sendToApp()
                    } failure: { error in
                        Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                    }
                }
            }
        }
    }
    
}

//MARK: - IBAction helper methods

extension LoginViewController {
    
    private func sendToApp() {
        debugPrint("Sending to app...")
    }
    
}

//MARK: - LoginButton Delegate -

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let result = result,
              error == nil
        else {
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
            return
        }
        
        guard let token = AccessToken.current?.tokenString else { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
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
                          print(
                            "Multi factor start sign in failed. Error: \(error.debugDescription)"
                          )
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
                                  print(
                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                  )
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
            self.sendToApp()
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //
    }

}
