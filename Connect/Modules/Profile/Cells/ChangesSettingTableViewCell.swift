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
    weak var delegate: ProfileSettingsTableViewCellDelegate?
    
    //MARK: - Private properties
    
    private var setting: ProfileSetting?
    
    //MARK: - Public methods
    
    func configureCell(setting: ProfileSetting) {
        self.setting = setting
        settingImageView.image = setting.image
        settingLabelLabel.text = setting.label
    }
    
}

//MARK: - IBActions -

extension ChangesSettingTableViewCell {
    
    @IBAction func didTapChangeButton(_ sender: Any) {
        guard let setting = setting else { return }
        delegate?.didCallProfileSetting(setting: setting)
    }
    
}
