//
//  SettingTableViewCell.swift
//  Connect
//
//  Created by Dino Martan on 26/07/2021.
//

import UIKit

class ChangesSettingTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var settingImageView: UIImageView!
    @IBOutlet private weak var settingLabelLabel: UILabel!
    
    //MARK: - Public properties
    
    static let identifier = "ChangesSettingTableViewCell"
    
    //MARK: - Public methods
    
    func configureCell(setting: ProfileSetting) {
        settingImageView.image = setting.image
        settingLabelLabel.text = setting.label
    }

}
