//
//  HomeViewController.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit
import ViewAnimator

class HomeViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    //MARK: - Private properties
    
    private var projects: [DatabaseDocument] = []
    private let hideTableViewAnimationDuration = 0.5
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get users conversations
        /*
        guard let userId = CurrentUser.shared.getCurrentUserId() else { return }
        DatabaseHandler.shared.getDataWhereArrayContains(type: Conversation.self, collection: .conversations, whereField: .messageUsersIds, contains: userId) { databaseDocuments in
            for document in databaseDocuments {
                guard let conversation = document.object as? Conversation else { continue }
                print(conversation.messageUsersIds)
            }
        } failure: { _ in
            //
        }
        */
        
        
        // new conversation
        
        /*
        guard let userId = CurrentUser.shared.getCurrentUserId() else { return }
        CurrentUser.shared.getCurrentUserDetails { userDetails in
            guard userDetails != nil else { return }
            let meMessageUser = ConversationUser(id: userId, userDetails: userDetails!)
            let gitMessageUser = ConversationUser(id: "lrzewExkjuS19OnbBeQztRtbiYH3", userDetails: UserDetails(name: "git user", profileImage: "https://avatars.githubusercontent.com/u/45883808?v=4"))
            let myMessage = Message(text: "This is message", creationDate: Date(), sender: userId)
            let gitUsersMessage = Message(text: "This is git users message", creationDate: Date(), sender: "lrzewExkjuS19OnbBeQztRtbiYH3")
            let conversation = Conversation(conversationUsers: [meMessageUser, gitMessageUser], messageUsersIds: [userId, "lrzewExkjuS19OnbBeQztRtbiYH3"], dateStarted: Date(), messages: [myMessage, gitUsersMessage])
            DatabaseHandler.shared.addDocument(object: conversation, collection: .conversations, documentIdType: .random) {
                //
            } failure: { _ in
                //
            }

        } failure: { _ in
            //
        }
        */
        
        
        
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        projects.removeAll()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProjects()
    }
    
}

//MARK: - Private extension -

private extension HomeViewController {
    
    //MARK: - View Setup
    
    private func setupView() {
        view.backgroundColor = .connectBackground
        searchBar.barTintColor = .connectBackground
        tableView.backgroundColor = .connectBackground
        searchBar.searchTextField.textColor = .white
        configureTableView()
        configureSearchBar()
    }
    
    //MARK: - TableView Configuration
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: HomeTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: HomeTableViewCell.identifier)
    }
    
    private func hideTableView() {
        UIView.animate(withDuration: hideTableViewAnimationDuration) {
            self.tableView.layer.opacity = 0
        }
    }
    
    private func showTableView() {
        UIView.animate(withDuration: hideTableViewAnimationDuration) {
            self.tableView.layer.opacity = 1
        }
    }
    
    //MARK: - SearchBar Configuration
    
    private func configureSearchBar() {
        searchBar.delegate = self
    }
    
    //MARK: - Data
    
    private func fetchProjects() {
        hideTableView()
        DatabaseHandler.shared.getAllDocumentsFromCollection(type: Project.self, collection: .projects) { [unowned self] databaseDocuments in
            projects = databaseDocuments
            tableView.reloadData()
            showTableView()
        } failure: { error in
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
        }
    }
    
}

//MARK: - TableView DataSource and Delegate

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier) as? HomeTableViewCell else { return UITableViewCell() }
        cell.configureCell(data: projects[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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
    
}

//MARK: - TableViewCell Delegate -

extension HomeViewController: HomeTableViewCellDelegate {
    
    func didTapCell(project: DatabaseDocument) {
        guard let projectDetailsViewController = UIStoryboard.getViewController(viewControllerType: ProjectDetailsViewController.self, from: .ProjectDetails) else { return }
        projectDetailsViewController.project = project
        projectDetailsViewController.modalPresentationStyle = .overFullScreen
        present(projectDetailsViewController, animated: false, completion: nil)
    }
    
}

//MARK: - SearchBar Delegate -

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text == nil { return }
        if searchBar.text == "" { fetchProjects() }
        else {
            hideTableView()
            DatabaseHandler.shared.getDataWhereArrayContains(type: Project.self, collection: .projects, whereField: .needTags, contains: searchBar.text!.lowercased()) { [unowned self] databaseDocuments in
                projects.removeAll()
                projects = databaseDocuments
                tableView.reloadData()
                showTableView()
            } failure: { error in
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" { fetchProjects() }
    }
    
}

//MARK: - IBActions -

extension HomeViewController {
    
    @IBAction func didTapOutside(_ sender: Any) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func didTapProfileButton(_ sender: Any) {
        guard let profileViewController = UIStoryboard.getViewController(viewControllerType: ProfileViewController.self, from: .Profile) else { return }
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
}
