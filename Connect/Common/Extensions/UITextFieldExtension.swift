//
//  UITextFieldExtension.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit

extension UITextField {
    
    /// Checks if all field are not empty
    static func checkFields(fields: [UITextField]) -> Bool {
        for field in fields {
            if field.text == "" || field.text == nil { return false }
        }
        return true
    }
    
}
