//
//  HomeTableViewCellDelegate.swift
//  Connect
//
//  Created by Dino Martan on 25/07/2021.
//

import Foundation

protocol HomeTableViewCellDelegate: AnyObject {
    
    func didTapCell(project: DatabaseDocument)
    
}
