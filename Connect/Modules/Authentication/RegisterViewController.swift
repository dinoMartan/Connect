//
//  RegisterViewController.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit
import FirebaseAuth

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

//MARK: - IBActions -

extension RegisterViewController {
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        guard UITextField.checkFields(fields: [nameTextField, surnameTextField, emailTextField, passwordTextField, confirmPasswordTextField]) != false,
              passwordTextField.text == confirmPasswordTextField.text
        else {
            Alerter.showOneButtonAlert(on: self, title: .oops, message: .checkFields, actionTitle: .ok, handler: nil)
            return
        }
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
            guard authDataResult != nil,
                  error == nil else {
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                return
            }
            // to do - send to app
        }
    }
    
}
