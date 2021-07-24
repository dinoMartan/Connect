//
//  Project.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import Foundation

struct Project: Codable {
    
    let title: String
    let description: String
    let haveTags: [String]?
    let needTags: [String]?
    let ownerId: String
    let ownerImage: String?
    let creationDate: Date
    
}
