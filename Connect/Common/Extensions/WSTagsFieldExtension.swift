//
//  WSTagsFieldExtension.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import Foundation
import WSTagsField

extension WSTagsField {
    
    func defaultConfiguration() {
        layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        spaceBetweenLines = 5.0
        spaceBetweenTags = 10.0
        font = .systemFont(ofSize: 18.0)
        backgroundColor = .none
        
        tintColor = .systemRed // tag background and blinking line color (red)
        textColor = .white // tag text color
        textField.textColor = .white // typing text color
        selectedColor = .white // background color when tag is selected
        selectedTextColor = .black // text color when tag is selected
        placeholderColor = .lightGray // placeholder text color
        
        placeholderAlwaysVisible = false
        keyboardAppearance = .dark
        textField.returnKeyType = .default
        acceptTagOption = .space
        shouldTokenizeAfterResigningFirstResponder = true
    }
    
}
