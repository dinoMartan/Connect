//
//  ProfileSettings.swift
//  Connect
//
//  Created by Dino Martan on 27/07/2021.
//

import UIKit

enum ProfileSettingSection {
    
    case changes(sectionTitle: String, settings: [ProfileSetting])
    case actions(sectionTitle: String, settings: [ProfileSetting])
    
}

struct ProfileSetting {
    
    let settingAction: ProfileSettingAction
    let image: UIImage?
    let label: String?
    let backgroundColor: UIColor?
    let foregroundColor: UIColor?
    
}

enum ProfileSettingAction {
    
    case chageNickname
    case changeProfileImage
    case signOut
    
}
