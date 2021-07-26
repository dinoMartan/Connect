//
//  ActionsSettingTableViewCell.swift
//  Connect
//
//  Created by Dino Martan on 26/07/2021.
//

import UIKit

class ActionsSettingTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    
    @IBOutlet private weak var actionButton: UIButton!
    
    //MARK: - Public properties
    
    static let identifier = "ActionsSettingTableViewCell"
    weak var delegate: ProfileSettingsTableViewCellDelegate?
    
    //MARK: - Private properties
    
    private var setting: ProfileSetting?
    
    //MARK: - Public methods
    
    func configureCell(setting: ProfileSetting) {
        self.setting = setting
        actionButton.setTitle(setting.label, for: .normal)
        actionButton.layer.cornerRadius = 20
        actionButton.backgroundColor = setting.backgroundColor
        actionButton.tintColor = setting.foregroundColor
    }
    
}

//MARK: - IBActions -

extension ActionsSettingTableViewCell {
    
    @IBAction func didTapActionButton(_ sender: Any) {
        guard let setting = setting else { return }
        delegate?.didCallProfileSetting(setting: setting)
    }
    
}
