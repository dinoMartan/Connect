//
//  ConversationsViewController.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import UIKit

class ConversationsViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Private properties
    
    private var usersConversations: [DatabaseDocument] = []
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchConversations()
    }

}

//MARK: - Private extension -

private extension ConversationsViewController {
    
    //MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = .connectBackground
        configureTableView()
    }
    
    //MARK: - TableView Configuration
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //MARK: - Data
    
    private func fetchConversations() {
        guard let userId = CurrentUser.shared.getCurrentUserId() else { return }
        DatabaseHandler.shared.getDataWhereArrayContains(type: Conversation.self, collection: .conversations, whereField: .messageUsersIds, contains: userId) { [unowned self] databaseDocuments in
            usersConversations.removeAll()
            for document in databaseDocuments {
                if document.object is Conversation { usersConversations.append(document) }
                else { continue }
            }
            tableView.reloadData()
        } failure: { error in
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
        }
    }
    
}

//MARK: - TableView DataSource and Delegate -

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersConversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationsTableViewCell.identifier) as? ConversationsTableViewCell else { return UITableViewCell() }
        cell.configureCell(conversation: usersConversations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let chatViewController = UIStoryboard.getViewController(viewControllerType: ChatViewController.self, from: .Conversations)
              else { return }
        chatViewController.conversationId = usersConversations[indexPath.row].id
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
}
