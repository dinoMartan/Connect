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
        setupView()
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
        fetchProjects()
        configureTableView()
        configureSearchBar()
    }
    
    //MARK: - TableView Configuration
    
    private func configureTableView() {
        tableView.register(UINib(nibName: HomeTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
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
        DatabaseHandler.shared.getAllDocumentsFromCollection(type: Project.self, collection: .projects) { databaseDocuments in
            self.projects = databaseDocuments
            self.tableView.reloadData()
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

//MARK: - SearchBar Delegate -

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text == nil { return }
        if searchBar.text == "" { fetchProjects() }
        else {
            hideTableView()
            DatabaseHandler.shared.getDataWhereArrayContains(type: Project.self, collection: .projects, whereField: .needTags, contains: searchBar.text!.lowercased()) { databaseDocuments in
                self.projects.removeAll()
                self.projects = databaseDocuments
                self.tableView.reloadData()
                self.showTableView()
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
    
    @IBAction func didTapLogoutButton(_ sender: Any) {
        CurrentUser.shared.signOut(viewController: self)
    }
    
}
