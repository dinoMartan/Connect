//
//  ChangesSettingTableViewCellDelegate.swift
//  Connect
//
//  Created by Dino Martan on 27/07/2021.
//

import Foundation

protocol ProfileSettingsTableViewCellDelegate: AnyObject {
    
    func didCallProfileSetting(setting: ProfileSetting)
    
}
