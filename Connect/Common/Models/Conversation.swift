//
//  Conversation.swift
//  Connect
//
//  Created by Dino Martan on 28/07/2021.
//

import Foundation

struct Conversation: Codable {
    
    let conversationUsers: [ConversationUser]
    let messageUsersIds: [String]
    let dateStarted: Date
    var messages: [Message]
    
}

struct ConversationUser: Codable {
    
    let id: String
    let userDetails: UserDetails
    
}

struct Message: Codable {
    
    let messageType: MessageType
    let text: String?
    let image: String?
    let creationDate: Date
    let sender: String
    
}

enum MessageType: String, Codable {
    
    case text
    case image
    
}
