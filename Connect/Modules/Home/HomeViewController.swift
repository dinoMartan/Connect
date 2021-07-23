//
//  HomeViewController.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

//MARK: - IBActions -

extension HomeViewController {
    
    @IBAction func didTapLogoutButton(_ sender: Any) {
        CurrentUser.shared.signOut(viewController: self)
    }
    
}
