//
//  ConversationsTableViewCell.swift
//  Connect
//
//  Created by Dino Martan on 27/07/2021.
//

import UIKit
import SDWebImage

class ConversationsTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    
    @IBOutlet private weak var cellBackgroundView: UIView!
    @IBOutlet private weak var conversationImageView: UIImageView!
    @IBOutlet private weak var conversationNameLabel: UILabel!
    @IBOutlet private weak var lastMessageLabel: UILabel!
    
    //MARK: - Public properties
    
    static let identifier = "ConversationsTableViewCell"
    
    //MARK: - Public methods
    
    func configureCell(conversation: DatabaseDocument) {
        guard let conversation = conversation.object as? Conversation else { return }
        cellBackgroundView.layer.cornerRadius = 15
        cellBackgroundView.backgroundColor = .connectSecondBackground
        conversationImageView.roundView()
        selectedBackgroundView?.backgroundColor = .black
        if let userId = CurrentUser.shared.getCurrentUserId() {
            let firstUser = conversation.conversationUsers.first
            if firstUser?.id == userId {
                if let image = conversation.conversationUsers[1].userDetails.profileImage { conversationImageView?.sd_setImage(with: URL(string: image), completed: nil) }
                conversationNameLabel.text = conversation.conversationUsers[1].userDetails.name
            }
            else {
                if let image = conversation.conversationUsers[0].userDetails.profileImage { conversationImageView?.sd_setImage(with: URL(string: image), completed: nil) }
                conversationNameLabel.text = conversation.conversationUsers[0].userDetails.name
            }
        }
        lastMessageLabel.text = conversation.messages.last?.text
    }
    
}
