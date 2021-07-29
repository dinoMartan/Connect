//
//  ProfileSettingsSectionView.swift
//  Connect
//
//  Created by Dino Martan on 27/07/2021.
//

import UIKit

class ProfileSettingsSectionView: UITableViewHeaderFooterView {
    
    //MARK: - IBOutlets

    @IBOutlet weak var sectionLabel: UILabel!
    
    //MARK: -  Public properties
    
    static let identifier = "ProfileSettingsSectionView"
    
    //MARK: - Public methods
    
    func configureSection(label: String) {
        sectionLabel.text = label
    }

}
