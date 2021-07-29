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
    
    @IBOutlet private weak var githubButton: UIButton!
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
        configureGithubButton()
        view.backgroundColor = .connectBackground
    }
    
    //MARK: - Github Button Configuration
    
    private func configureGithubButton() {
        let image = githubButton.image(for: .normal)
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        githubButton.setImage(tintedImage, for: .normal)
        githubButton.tintColor = .darkGray
    }
    
    //MARK: - FacebookLoginButton configuraton
    
    private func configureFacebookLoginButton() {
        fbLoginButton.isHidden = true
        view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
    }
    
}

//MARK: - Login helper methods

private extension LoginViewController {
    
    private func addNewUserDetails(userDetails: UserDetails, userId: String) {
        DatabaseHandler.shared.addDocument(object: userDetails, collection: .userDetails, documentIdType: .custom(id: userId)) {
            //
        } failure: { _ in
            //
        }
    }
    
}

//MARK: - IBActions -

extension LoginViewController {
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        guard UITextField.checkFields(fields: [emailTextField, passwordTextField]) != false else {
            Alerter.showOneButtonAlert(on: self, title: .oops, message: .checkFields, actionTitle: .ok, handler: nil)
            return
        }
        showSpinner(nil)
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
            guard authDataResult != nil,
                  error == nil else {
                self.hideSpinner(nil)
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                return
            }
            self.sendToApp()
        }
    }
    
    @IBAction func didTapFacebookLoginButton(_ sender: Any) {
        showSpinner(nil)
        fbLoginButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func didTapLoginWithGoogleButton(_ sender: Any) {
        showSpinner(nil)
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                hideSpinner(nil)
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
                                            print("Multi factor start sign in failed. Error: \(error.debugDescription)" )
                                            hideSpinner(nil)
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
                                                            print("Multi factor finanlize sign in failed. Error: \(error.debugDescription)")
                                                            hideSpinner(nil)
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
                        hideSpinner(nil)
                        return
                    }
                    hideSpinner(nil)
                    return
                }
                
                if let newUser = authResult?.additionalUserInfo?.isNewUser,
                   let userId = authResult?.user.uid
                    {
                    if newUser {
                        let name = user?.profile?.name
                        let profileImage = user?.profile?.imageURL(withDimension: 200)?.absoluteString ?? AuthConstants.defaultProfilePicture.rawValue
                        let userDetails = UserDetails(name: name, profileImage: profileImage)
                        addNewUserDetails(userDetails: userDetails, userId: userId)
                    }
                }
                sendToApp()
            }
        }
    }
    
    @IBAction func didTapLoginWithGithubButton(_ sender: Any) {
        showSpinner(nil)
        provider = OAuthProvider(providerID: AuthProviders.github.rawValue)
        provider?.scopes = [
            "user:email",
            "read:profile"
        ]
        provider!.getCredentialWith(nil) { credential, error in
            if error != nil {
                self.hideSpinner(nil)
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
            }
            if credential != nil {
                Auth.auth().signIn(with: credential!) { authResult, error in
                    if error != nil {
                        self.hideSpinner(nil)
                        Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                    }
                    else {
                        guard let result = authResult,
                              let isNewUser = result.additionalUserInfo?.isNewUser else {
                            Alerter.showOneButtonAlert(on: self, title: .error, error: nil, actionTitle: .ok, handler: nil)
                            return
                        }
                        if isNewUser {
                            guard let userId = authResult?.user.uid
                                  else { return }
                            let userDetails = UserDetails(name: result.user.displayName, profileImage: result.user.photoURL?.absoluteString ?? AuthConstants.defaultProfilePicture.rawValue)
                            self.addNewUserDetails(userDetails: userDetails, userId: userId)
                            self.sendToApp()
                        }
                        else {
                            self.sendToApp()
                        }
                    }
                }
            }
        }
    }
    
}

//MARK: - IBAction helper methods

extension LoginViewController {
    
    private func sendToApp() {
        hideSpinner(nil)
        guard let navigationTabBarViewController = UIStoryboard.getViewController(viewControllerType: NavigationTabBarViewController.self, from: .Navigation) else { return }
        navigationTabBarViewController.modalPresentationStyle = .fullScreen
        present(navigationTabBarViewController, animated: true, completion: nil)
    }
    
}

//MARK: - LoginButton Delegate -

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let result = result,
              error == nil
        else {
            hideSpinner(nil)
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
            return
        }
        
        guard let token = AccessToken.current?.tokenString else {
            hideSpinner(nil)
            return
        }
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
                                        Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                                        self.hideSpinner(nil)
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
                                                        self.hideSpinner(nil)
                                                    } else {
                                                        self.navigationController?.popViewController(animated: true)
                                                        self.hideSpinner(nil)
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
                    self.hideSpinner(nil)
                    return
                }
                self.hideSpinner(nil)
                return
            }
            if let newUser = authResult?.additionalUserInfo?.isNewUser,
               let userId = authResult?.user.uid
                {
                if newUser {
                    let name = authResult?.user.displayName
                    var image = ""
                    if let profileImage = authResult?.user.photoURL?.absoluteString {
                        image = profileImage + "?access_token=\(token)"
                    }
                    else { image = AuthConstants.defaultProfilePicture.rawValue }
                    let userDetails = UserDetails(name: name, profileImage: image)
                    self.addNewUserDetails(userDetails: userDetails, userId: userId)
                }
            }
            self.sendToApp()
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //
    }
    
}
