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
    
    @IBOutlet private weak var profileImageBackgroundView: UIView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    
    //MARK: - Private properties
    
    private let defaultProfileImage = AuthConstants.defaultProfilePicture.rawValue
    private var didSetCustomProfilePicture = false
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
}

//MARK: - Private extension -

private extension RegisterViewController {
    
    //MARK: - View Setup
    
    private func setupView() {
        view.backgroundColor = .connectBackground
        profileImageView.roundView()
        profileImageBackgroundView.roundView()
    }
    
}

//MARK: - ImagePicker Delegate -

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = pickedImage
            didSetCustomProfilePicture = true
        }
    }
    
}

//MARK: - IBActions -

extension RegisterViewController {
    
    @IBAction func didTapProfileImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        // check all textfields
        guard UITextField.checkFields(fields: [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField]) != false,
              passwordTextField.text == confirmPasswordTextField.text
        else {
            Alerter.showOneButtonAlert(on: self, title: .oops, message: .checkFields, actionTitle: .ok, handler: nil)
            return
        }
        showSpinner(nil)
        addNewUser { [unowned self] authDataResult in
            if didSetCustomProfilePicture {
                uploadProfileImage { imageUrl in
                    let userDetails = UserDetails(name: nameTextField.text!, profileImage: imageUrl)
                    addUserDetails(userDetails: userDetails, userId: authDataResult.user.uid) {
                        sendToTheApp()
                    } failure: { error in
                        showErrorAlert(error: error)
                    }
                } failure: { error in
                    showErrorAlert(error: error)
                }
            }
            else {
                let userDetails = UserDetails(name: nameTextField.text!, profileImage: defaultProfileImage)
                addUserDetails(userDetails: userDetails, userId: authDataResult.user.uid) {
                    sendToTheApp()
                } failure: { error in
                    showErrorAlert(error: error)
                }
            }
        } failure: { error in
            self.showErrorAlert(error: error)
        }
    }
    
    //MARK: - Helper functions
    
    /// Uploads image and returns url of the image. Only signed in used can upload the image.
    private func uploadProfileImage(success: @escaping ((String) -> Void), failure: @escaping ((Error?) -> Void)) {
        guard let image = profileImageView.image else {
            failure(nil)
            return
        }
        DatabaseHandler.shared.uploadImage(image: image, path: .profileImages, imageQuality: .low) { imageUrl in
            success(imageUrl)
        } failure: { error in
            failure(error)
        }
    }
    
    /// Creates new firebase user and returns AuthDataResult.
    private func addNewUser(success: @escaping ((AuthDataResult) -> Void), failure: @escaping ((Error?) -> Void)) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
            guard let result = authDataResult,
                  error == nil
            else {
                failure(error)
                return
            }
            success(result)
        }
    }
    
    /// Adds user details to userDetails collection. Only signed in user can add users details.
    private func addUserDetails(userDetails: UserDetails, userId: String, success: @escaping (() -> Void), failure: @escaping ((Error?) -> Void)) {
        DatabaseHandler.shared.addDocument(object: userDetails, collection: .userDetails, documentIdType: .custom(id: userId)) {
            success()
        } failure: { error in
            failure(error)
        }
    }
    
    /// Send signed in user to main app screen.
    private func sendToTheApp() {
        guard let navigationTabBarViewController = UIStoryboard.getViewController(viewControllerType: NavigationTabBarViewController.self, from: .Navigation) else { return }
        navigationTabBarViewController.modalPresentationStyle = .fullScreen
        hideSpinner {
            self.present(navigationTabBarViewController, animated: true, completion: nil)
        }
    }
    
    /// Shows alert with error description.
    private func showErrorAlert(error: Error?) {
        hideSpinner {
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
        }
    }
    
}
