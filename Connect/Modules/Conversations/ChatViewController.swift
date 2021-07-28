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
            newMessageBackgroundView.backgroundColor = .connectBackground
            attachConversationListener()
            configureTableView()
        }
    }
    
    //MARK: - TableView Configuration
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //MARK: - Data
    
    private func attachConversationListener() {
        guard let conversationId = conversationId else { return }
        DatabaseHandler.shared.listenForDocumentRealTimeUpdates(type: Conversation.self, collection: .conversations, documentId: conversationId) { conversation in
            self.conversation = conversation
            self.tableView.reloadData()
        } failure: { error in
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
        }

    }
    
}

//MARK: - TableView DataSource and Delegate -

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        if senderId == currentUserId {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RightSideTableViewCell.identifier) as? RightSideTableViewCell else { return UITableViewCell() }
            cell.configureCell(message: message, senderUserDetails: senderUserDetails)
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LeftSideTableViewCell.identifier) as? LeftSideTableViewCell else { return UITableViewCell() }
            cell.configureCell(message: message, senderUserDetails: senderUserDetails)
            return cell
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
    
}

//MARK: - IBActions -

extension ChatViewController {
    
    @IBAction func didTapOutside(_ sender: Any) {
        textField.resignFirstResponder()
    }
    
    @IBAction func didTapSendButton(_ sender: Any) {
        textField.resignFirstResponder()
        guard let text = textField.text,
              text != "",
              text != " ",
              var conversation = conversation,
              let conversationId = conversationId,
              let userId = CurrentUser.shared.getCurrentUserId()
        else { return }
        let message = Message(text: text, creationDate: Date(), sender: userId)
        conversation.messages.append(message)
        DatabaseHandler.shared.updateDocument(type: Conversation.self, databaseDocument: DatabaseDocument(id: conversationId, object: conversation), collection: .conversations) {
            self.textField.text = ""
        } failure: { error in
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
        }
    }
    
}
