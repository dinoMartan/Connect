//
//  MyProjectsViewController.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import UIKit
import ViewAnimator

class MyProjectsViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    //MARK: - Private properties
    
    private var projects: [DatabaseDocument] = []
    private let hideTableViewAnimationDuration = 0.5
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        projects.removeAll()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyProjects()
    }

}

//MARK: - Private extension -

private extension MyProjectsViewController {
    
    //MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = .connectBackground
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        tableView.backgroundColor = .connectBackground
        configureTableView()
    }
    
    //MARK: - SegmentedControl setup and configuration
    
    private func setListenerOnSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(self.didChangeValue(_:)), for: .valueChanged)
    }
    
    @objc func didChangeValue(_ sender: UISegmentedControl) {
        let index = self.segmentedControl.selectedSegmentIndex
        if index == 0 { // my projects
            fetchMyProjects()
        }
        else if index == 1 { // assigned projects
            // to do - assign user to project
        }
    }
    
    //MARK: - TableView Configuration
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
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
    
    //MARK: - Data
    
    private func fetchMyProjects() {
        guard let userId = CurrentUser.shared.getCurrentUserId() else {
            Alerter.showOneButtonAlert(on: self, title: .oops, message: .somethingWentWrong, actionTitle: .ok, handler: nil)
            return
        }
        hideTableView()
        DatabaseHandler.shared.getDataWhere(type: Project.self, collection: .projects, whereField: .ownerId, isEqualTo: userId) { [unowned self] databaseDocuments in
            projects = databaseDocuments
            showTableView()
            tableView.reloadData()
        } failure: { error in
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
        }
    }
    
}

//MARK: - IBActions -

extension MyProjectsViewController {
    
    @IBAction func didTapAddProjectButton(_ sender: Any) {
        guard let projectEditorViewController = UIStoryboard.getViewController(viewControllerType: ProjectEditorViewController.self, from: .ProjectEditor) else { return }
        projectEditorViewController.delegate = self
        present(projectEditorViewController, animated: true, completion: nil)
    }
    
}

//MARK: - TableView DataSource and Delegate -

extension MyProjectsViewController: UITableViewDataSource, UITableViewDelegate {
    
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

extension MyProjectsViewController: HomeTableViewCellDelegate {
    
    func didTapCell(project: DatabaseDocument) {
        guard let projectEditorViewController = UIStoryboard.getViewController(viewControllerType: ProjectEditorViewController.self, from: .ProjectEditor) else { return }
        projectEditorViewController.project = project
        projectEditorViewController.delegate = self
        present(projectEditorViewController, animated: true, completion: nil)
    }
    
}

//MARK: - ProjectEditorViewControllerDelegate -

extension MyProjectsViewController: ProjectEditorViewControllerDelegate {
    
    func didMakeChanges() {
        fetchMyProjects()
    }
    
}
