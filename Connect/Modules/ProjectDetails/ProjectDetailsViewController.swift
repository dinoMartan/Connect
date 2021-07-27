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
        // to do - message owner
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        didTapOutside(self)
    }
    
}
