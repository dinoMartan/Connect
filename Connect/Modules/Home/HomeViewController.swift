//
//  HomeViewController.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
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
    }
    
}

//MARK: - IBActions -

extension HomeViewController {
    
    @IBAction func didTapLogoutButton(_ sender: Any) {
        CurrentUser.shared.signOut(viewController: self)
    }
    
}
