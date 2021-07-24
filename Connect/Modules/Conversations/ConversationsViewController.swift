//
//  ConversationsViewController.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import UIKit

class ConversationsViewController: UIViewController {
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

}

//MARK: - Private extension -

private extension ConversationsViewController {
    
    //MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = .connectBackground
    }
    
}
