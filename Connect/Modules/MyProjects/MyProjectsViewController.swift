//
//  MyProjectsViewController.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import UIKit

class MyProjectsViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
    
    //MARK: - TableView Configuration
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

//MARK: - IBActions -

extension MyProjectsViewController {
    
    @IBAction func didTapAddProjectButton(_ sender: Any) {
        guard let projectEditorViewController = UIStoryboard.getViewController(viewControllerType: ProjectEditorViewController.self, from: .ProjectEditor) else { return }
        present(projectEditorViewController, animated: true, completion: nil)
    }
    
}

//MARK: - TableView DataSource and Delegate -

extension MyProjectsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
