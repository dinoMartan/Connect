//
//  LeftSideImageMessageTableViewCell.swift
//  Connect
//
//  Created by Dino Martan on 30/07/2021.
//

import UIKit
import SDWebImage

class LeftSideImageMessageTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var messageImageBackgroundView: UIView!
    @IBOutlet private weak var messageImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!

    //MARK: - Public properties
    
    static let identifier = "LeftSideImageMessageTableViewCell"
    weak var delegate: ImageMessageTableViewCellDelegate?
    
    //MARK: - Public methods
    
    func configureCell(message: Message, senderUserDetails: UserDetails?) {
        messageImageBackgroundView.layer.cornerRadius = 15
        messageImageView.layer.cornerRadius = 15
        profileImageView.roundView()
        if let image = senderUserDetails?.profileImage { profileImageView.sd_setImage(with: URL(string: image), completed: nil) }
        if let image = message.image { messageImageView.sd_setImage(with: URL(string: image), completed: nil) }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        messageImageView.addGestureRecognizer(tap)
    }
    
    //MARK: - Private methods
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let image = messageImageView.image else { return }
        delegate?.didTapImage(image: image)
    }

}
