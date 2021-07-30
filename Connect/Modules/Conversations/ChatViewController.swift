//
//  ChatViewController.swift
//  Connect
//
//  Created by Dino Martan on 28/07/2021.
//

import UIKit
import ViewAnimator

class ChatViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var newMessageBackgroundView: UIView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var newMessageTextField: UITextField!
    
    //MARK: - Public properties
    
    var conversationId: String?
    
    //MARK: - Private properties
    
    private var conversation: Conversation?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
}

//MARK: - Private extension -

private extension ChatViewController {
    
    //MARK: - View Setup
    
    private func setupView() {
        if conversationId == nil {
            Alerter.showOneButtonAlert(on: self, title: .oops, message: .somethingWentWrong, actionTitle: .ok) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
            navigationItem.largeTitleDisplayMode = .never
            newMessageBackgroundView.backgroundColor = .connectBackground
            view.backgroundColor = .connectBackground
            tableView.backgroundColor = .connectBackground
            navigationController?.navigationBar.backgroundColor = .connectBackground
            attachConversationListener()
            configureTableView()
            configureTextField()
        }
    }
    
    //MARK: - TextField Configuration
    
    private func configureTextField() {
        textField.delegate = self
    }
    
    //MARK: - TableView Configuration
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func scrollToBottom() {
        guard let conversation = conversation else { return }
        let indexPath = NSIndexPath(row: conversation.messages.count-1, section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
    }
    
    //MARK: - Data
    
    private func attachConversationListener() {
        guard let conversationId = conversationId else { return }
        DatabaseHandler.shared.listenForDocumentRealTimeUpdates(type: Conversation.self, collection: .conversations, documentId: conversationId) { [unowned self] conversation in
            self.conversation = conversation
            tableView.reloadData()
            scrollToBottom()
        } failure: { error in
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
        }

    }
    
}

//MARK: - TableView DataSource and Delegate -

extension ChatViewController: UITableViewDataSource, UITableViewDelegate, ImageMessageTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let conversation = conversation else { return 0 }
        return conversation.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let conversation = conversation,
              let currentUserId = CurrentUser.shared.getCurrentUserId()
              else { return UITableViewCell() }
        let message = conversation.messages[indexPath.row]
        let senderId = message.sender
        let senderUserDetails = getSenderUserDetails(for: senderId)
        
        // current user's message
        if senderId == currentUserId {
            switch message.messageType {
            case .text:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RightSideTableViewCell.identifier) as? RightSideTableViewCell else { return UITableViewCell() }
                cell.configureCell(message: message, senderUserDetails: senderUserDetails)
                return cell
            case .image:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RightSideImageMessageTableViewCell.identifier) as? RightSideImageMessageTableViewCell else { return UITableViewCell() }
                cell.configureCell(message: message, senderUserDetails: senderUserDetails)
                cell.delegate = self
                return cell
            }
        }
        
        // someone elses message
        else {
            switch message.messageType {
            case .text:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LeftSideTableViewCell.identifier) as? LeftSideTableViewCell else { return UITableViewCell() }
                cell.configureCell(message: message, senderUserDetails: senderUserDetails)
                return cell
            case .image:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LeftSideImageMessageTableViewCell.identifier) as? LeftSideImageMessageTableViewCell else { return UITableViewCell() }
                cell.configureCell(message: message, senderUserDetails: senderUserDetails)
                cell.delegate = self
                return cell
            }
        }
    }
    
    //MARK: - Helper functions
    
    func getSenderUserDetails(for sender: String) -> UserDetails? {
        guard let conversation = conversation else { return nil }
        for conversationUser in conversation.conversationUsers {
            if conversationUser.id == sender { return conversationUser.userDetails }
        }
        return nil
    }
    
    //MARK: - ImageMessageTableViewCellDelegate
    
    func didTapImage(image: UIImage) {
        guard let imageViewerViewController = UIStoryboard.getViewController(viewControllerType: ImageViewerViewController.self, from: .Conversations) else { return }
        imageViewerViewController.image = image
        present(imageViewerViewController, animated: true, completion: nil)
    }
    
}

//MARK: - TextField Delegate -

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSendButton(self)
        return true
    }
    
}

//MARK: - ImagePicker Delegate -

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
           let userId = CurrentUser.shared.getCurrentUserId() {
            picker.dismiss(animated: true, completion: nil)
            uploadImage(image: image) { [unowned self] url in
                let message = Message(messageType: .image, text: nil, image: url, creationDate: Date(), sender: userId)
                sendMessage(message: message)
            } failure: { error in
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
            }
        }
    }
    
    //MARK: - Helper functions
    
    private func uploadImage(image: UIImage, success: @escaping ((String) -> Void), failure: @escaping ((Error?) -> Void)) {
        DatabaseHandler.shared.uploadImage(image: image, path: .messageImages, imageQuality: .lowest) { url in
            success(url)
        } failure: { error in
            failure(error)
        }
    }
    
}

//MARK: - IBActions -

extension ChatViewController {
    
    @IBAction func didTapImageButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        Alerter.showThreeButtonAlert(on: self, alerterStyle: .actionSheet, title: nil, message: nil, buttonOneTitle: .camera, buttonOneStyle: .default, buttonTwoTitle: .library, buttonTwoStyle: .default, buttonThreeTitle: .cancel, buttonThreeStyle: .cancel) { _ in
            // show camera
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        } buttonTwohandler: { _ in
            // show photo library
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } buttonThreehandler: { _ in
            //
        }

    }
    
    @IBAction func didTapOutside(_ sender: Any) {
        textField.resignFirstResponder()
    }
    
    @IBAction func didTapSendButton(_ sender: Any) {
        guard let text = textField.text,
              text != "",
              text != " ",
              let userId = CurrentUser.shared.getCurrentUserId()
        else { return }
        let message = Message(messageType: .text, text: text, image: nil, creationDate: Date(), sender: userId)
        sendMessage(message: message)
    }
    
    //MARK: - Helper functions
    
    private func sendMessage(message: Message) {
        guard var conversation = conversation,
              let conversationId = conversationId
        else { return }
        conversation.messages.append(message)
        DatabaseHandler.shared.updateDocument(type: Conversation.self, databaseDocument: DatabaseDocument(id: conversationId, object: conversation), collection: .conversations) {
            self.textField.text = ""
        } failure: { error in
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
        }
    }
    
}
