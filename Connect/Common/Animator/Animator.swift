//
//  Animator.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import UIKit
import ViewAnimator

enum AnimatorType {
    
    case zoom
    case fade
    case rotate90
    
}

final class Animator {
    
    //MARK: - Public methods
    
    static func animate(view: UIView, animationTypes: [AnimatorType]) {
        
        var animations: [Animation] = []
        for animationType in animationTypes {
            switch animationType {
            case .zoom:
                let animation = AnimationType.zoom(scale: 0.2)
                animations.append(animation)
            case .fade:
                let animation = AnimationType.identity
                animations.append(animation)
            case .rotate90:
                let animation = AnimationType.rotate(angle: 90)
                animations.append(animation)
            }
        }
        
        view.animate(animations: animations)
        
    }
    
}

