//
//  ConversationsViewController.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import UIKit
import ViewAnimator

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        usersConversations.removeAll()
        tableView.reloadData()
    }

}

//MARK: - Private extension -

private extension ConversationsViewController {
    
    //MARK: - Setup View
    
    private func setupView() {
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .connectBackground
        tableView.backgroundColor = .connectBackground
        navigationController?.navigationBar.backgroundColor = .connectBackground
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
    
    // animate cells on appear - randomly select left2right or right2left animation
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let fadeAnimation = AnimationType.identity
        let vectorAnimationLeftToRight = AnimationType.vector(CGVector(dx: -300, dy: 0))
        let vectorAnimationRightToLeft = AnimationType.vector(CGVector(dx: 300, dy: 0))
        let random = Int.random(in: 1...10)
        if random % 2 == 0 {
            UIView.animate(views: [cell], animations: [fadeAnimation, vectorAnimationLeftToRight])
        }
        else {
            UIView.animate(views: [cell], animations: [fadeAnimation, vectorAnimationRightToLeft])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
}
