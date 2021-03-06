//
//  StoryboardExtension.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit

extension UIStoryboard {
    
    enum StoryboardId: String {
        
        case Navigation
        case Authentication
        case Home
        case Conversations
        case MyProjects
        case ProjectEditor
        case ProjectDetails
        case Profile
        
    }
    
    static func getViewController<T> (viewControllerType: T.Type, from storyboardId: StoryboardId) -> T? {
        let storyboard = UIStoryboard(name: storyboardId.rawValue, bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: String(describing: T.self)) as? T
        return viewController
    }
    
}
