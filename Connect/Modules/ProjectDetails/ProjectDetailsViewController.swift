//
//  ProjectDetailsViewController.swift
//  Connect
//
//  Created by Dino Martan on 25/07/2021.
//

import UIKit
import ViewAnimator
import WSTagsField
import SDWebImage

class ProjectDetailsViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var ownerImageView: UIImageView!
    @IBOutlet private weak var ownerNicknameLabel: UILabel!
    @IBOutlet private weak var projectTitleLabel: UILabel!
    @IBOutlet private weak var haveTagsLabel: UILabel!
    @IBOutlet private weak var projectDescriptionTextView: UITextView!
    @IBOutlet private weak var needTagsLabel: UILabel!
    
    //MARK: - Public properties
    
    var project: DatabaseDocument?
    
    //MARK: - Private properties
    
    private let fadeAnimation = AnimationType.identity
    private let zoomAnimation = AnimationType.zoom(scale: 0.1)
    
    //MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
}

//MARK: - Private extension -

private extension ProjectDetailsViewController {
    
    //MARK: - View Setup
    
    private func setupView() {
        checkDatabaseDocumentType()
        animateAppearing()
        loadDataToUI()
        backgroundView.backgroundColor = .connectBackground
        projectDescriptionTextView.backgroundColor = .connectSecondBackground
        backgroundView.layer.cornerRadius = 20
    }
    
    //MARK: - Data check
    
    private func checkDatabaseDocumentType() {
        guard project?.object is Project else {
            Alerter.showOneButtonAlert(on: self, title: .oops, message: .somethingWentWrong, actionTitle: .ok) { _ in
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
    }
    
    private func loadDataToUI() {
        let project = self.project?.object as! Project
        ownerNicknameLabel.text = project.ownerName ?? "user"
        projectTitleLabel.text = project.title
        projectDescriptionTextView.text = project.description
        haveTagsLabel.text = tagsToString(tags: project.haveTags)
        needTagsLabel.text = tagsToString(tags: project.needTags)
        guard let image = project.ownerImage else { return }
        ownerImageView.layer.cornerRadius = ownerImageView.frame.height / 2
        ownerImageView.sd_setImage(with: URL(string: image), completed: nil)
    }
    
    private func tagsToString(tags: [String]?) -> String {
        guard let tags = tags else {
            return ""
        }
        var tagString = ""
        for tag in tags {
            tagString = tagString + "  " + tag
        }
        return tagString
    }
    
    //MARK: - View Animation
    
    private func animateAppearing() {
        view.animate(animations: [fadeAnimation])
        backgroundView.animate(animations: [zoomAnimation])
    }
    
}

//MARK: - IBActions -

extension ProjectDetailsViewController {
    
    @IBAction func didTapOutside(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.view.layer.opacity = 0
        } completion: { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func didTapMessageButton(_ sender: Any) {
        guard let userId = CurrentUser.shared.getCurrentUserId(),
              let project = project?.object as? Project else { return }
        
        showTextInputPrompt(withMessage: "Message") { (didTypeText, text) in
            if didTypeText {
                guard let messageText = text else { return }
                CurrentUser.shared.getCurrentUserDetails { userDetails in
                    guard userDetails != nil else { return }
                    let meMessageUser = ConversationUser(id: userId, userDetails: userDetails!)
                    let projectMessageUser = ConversationUser(id: project.ownerId, userDetails: UserDetails(name: project.ownerName, profileImage: project.ownerImage))
                    let myMessage = Message(text: messageText, creationDate: Date(), sender: userId)
                    let conversation = Conversation(conversationUsers: [meMessageUser, projectMessageUser], messageUsersIds: [userId, project.ownerId], dateStarted: Date(), messages: [myMessage])
                    DatabaseHandler.shared.addDocument(object: conversation, collection: .conversations, documentIdType: .random) {
                        Alerter.showOneButtonAlert(on: self, title: .messageSent, message: .messageIsInConversations, actionTitle: .ok, handler: nil)
                    } failure: { error in
                        Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                    }

                } failure: { error in
                    Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
                }
            }
        }
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        didTapOutside(self)
    }
    
}
