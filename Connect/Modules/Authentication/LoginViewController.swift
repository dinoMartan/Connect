//
//  LoginViewController.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

//MARK: - IBActions -

extension LoginViewController {
    
    @IBAction func didTapLoginButton(_ sender: Any) {
    }
    
    @IBAction func didTapLoginWithFacebookButton(_ sender: Any) {
    }
    
    @IBAction func didTapLoginWithGoogleButton(_ sender: Any) {
    }
    
    @IBAction func didTapLoginWithGithubButton(_ sender: Any) {
    }
    
}
