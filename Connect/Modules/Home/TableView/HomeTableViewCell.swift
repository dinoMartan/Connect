//
//  HomeTableViewCell.swift
//  Connect
//
//  Created by Dino Martan on 25/07/2021.
//

import UIKit
import SDWebImage

class HomeTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var cellBackgroundView: UIView!
    @IBOutlet private weak var background: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ownerUsernameLabel: UILabel!
    @IBOutlet private weak var tagsLabel: UILabel!
    @IBOutlet private weak var ownerImage: UIImageView!
    
    //MARK: - Public properties
    
    static let identifier = "HomeTableViewCell"
    weak var delegate: HomeTableViewCellDelegate?
    
    //MARK: - Private properties
    
    private var project: DatabaseDocument?

    //MARK: - Public methods
    
    func configureCell(data: DatabaseDocument) {
        guard let project = data.object as? Project else { return }
        self.project = data
        
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        self.addGestureRecognizer(tapGuesture)
        
        ownerImage.layer.cornerRadius = ownerImage.frame.height / 2
        cellBackgroundView.backgroundColor = .connectBackground
        background.backgroundColor = .connectSecondBackground
        background.layer.cornerRadius = 20
        
        titleLabel.text = project.title
        //ownerUsernameLabel.text = project.ownerNickname
        if project.ownerImage != nil { ownerImage.sd_setImage(with: URL(string: project.ownerImage!), completed: nil) }
        guard let tags = project.needTags else {
            tagsLabel.isHidden = true
            return
        }
        var tagString = ""
        for tag in tags {
            tagString = tagString + "  " + tag
        }
        tagsLabel.text = tagString
    }
    
}

//MARK: - IBActions -

extension HomeTableViewCell {
    
    @objc func didTapCell(_ sender: Any) {
        guard let project = project else { return }
        delegate?.didTapCell(project: project)
    }
    
}
