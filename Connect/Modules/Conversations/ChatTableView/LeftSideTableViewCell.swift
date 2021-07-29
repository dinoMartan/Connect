//
//  LeftSideTableViewCell.swift
//  Connect
//
//  Created by Dino Martan on 28/07/2021.
//

import UIKit
import SDWebImage

class LeftSideTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    
    @IBOutlet private weak var messageBackgroundView: UIView!
    @IBOutlet private weak var personImageView: UIImageView!
    @IBOutlet private weak var messageTextLabel: UILabel!
    
    //MARK: - Public properties
    
    static let identifier = "LeftSideTableViewCell"
    
    //MARK: - Public methods
    
    func configureCell(message: Message, senderUserDetails: UserDetails?) {
        messageBackgroundView.layer.cornerRadius = 15
        messageTextLabel.text = message.text
        personImageView.roundView()
        if let image = senderUserDetails?.profileImage { personImageView.sd_setImage(with: URL(string: image), completed: nil) }
    }

}
