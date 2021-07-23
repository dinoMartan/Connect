//
//  CurrentUser.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

final class CurrentUser {
    
    //MARK: - Public properties
    
    static let shared = CurrentUser()
    
    //MARK: - Private properties
    
    private let firebaseAuth = Auth.auth()
    private var user: User? {
        firebaseAuth.currentUser
    }
    
    //MARK: - Public methods
    
    func getCurrentUser() -> User? {
        return user
    }
    
    func userSignedIn() -> Bool {
        if user == nil { return false }
        else { return true }
    }
    
    func signOut(viewController: UIViewController) {
        var success = true
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            success = false
            Alerter.showOneButtonAlert(on: viewController, title: .error, error: signOutError, actionTitle: .ok, handler: nil)
        }
        if success {
            LoginManager().logOut() // for FB logout
            guard let loginViewController = UIStoryboard.getViewController(viewControllerType: LoginNavigationViewController.self, from: .Authentication) else { return }
            loginViewController.modalPresentationStyle = .fullScreen
            viewController.present(loginViewController, animated: true, completion: nil)
        }
    }
    
}
