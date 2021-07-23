//
//  RegisterViewController.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit

class RegisterViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var surnameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
