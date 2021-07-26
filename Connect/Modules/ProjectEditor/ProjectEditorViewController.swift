//
//  ProjectEditorViewController.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import UIKit
import WSTagsField

class ProjectEditorViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextView!
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var haveTagsView: UIView!
    @IBOutlet private weak var needTagsView: UIView!
    @IBOutlet private weak var deleteButton: UIButton!
    
    //MARK: - Public properties
    
    var project: DatabaseDocument?
    weak var delegate: ProjectEditorViewControllerDelegate?
    
    //MARK: - Private properties
    
    private let haveTagsField = WSTagsField()
    private let needTagsField = WSTagsField()
    private var badWords: [String]?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
}

//MARK: - Private extension -

private extension ProjectEditorViewController {
    
    //MARK: - View Setup
    
    private func setupView() {
        if project != nil && project?.object is Project { loadDataToUI(project: project!.object as! Project) }
        else {
            deleteButton.isHidden = true
        }
        backgroundView.layer.cornerRadius = 15
        backgroundView.backgroundColor = .connectBackground
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Project title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        loadBadWords()
        configureTagViews()
        configureFirstTagField()
        configureSecondTagField()
    }
    
    private func loadDataToUI(project: Project) {
        titleTextField.text = project.title
        descriptionTextField.text = project.description
        if let haveTags = project.haveTags {
            haveTagsField.addTags(haveTags)
        }
        if let needTags = project.needTags {
            needTagsField.addTags(needTags)
        }
    }
    
    //MARK: - Tag Views and Fields
    
    private func configureTagViews() {
        haveTagsView.layer.cornerRadius = 15
        needTagsView.layer.cornerRadius = 15
    }
    
    private func configureFirstTagField() {
        haveTagsField.frame = haveTagsView.bounds
        haveTagsView.addSubview(haveTagsField)
        haveTagsField.defaultConfiguration()
        haveTagsField.maxHeight = haveTagsView.frame.height
        haveTagsField.placeholder = "backend, swift, php..."
        
        haveTagsField.onValidateTag = { tag, tags in
            guard let badWords = self.badWords else { return false }
            for badWord in badWords {
                if tag.text.contains(badWord) {
                    Alerter.showOneButtonAlert(on: self, title: .warning, message: .beRespectful, actionTitle: .ok, handler: nil)
                    return false
                }
            }
            // custom validations, called before tag is added to tags list
            return tag.text != "#" && !tags.contains(where: { $0.text.uppercased() == tag.text.uppercased() })
        }
    }
    
    private func configureSecondTagField() {
        needTagsField.frame = needTagsView.bounds
        needTagsView.addSubview(needTagsField)
        needTagsField.defaultConfiguration()
        needTagsField.maxHeight = haveTagsView.frame.height
        needTagsField.placeholder = "backend, swift, php..."
        
        needTagsField.onValidateTag = { tag, tags in
            guard let badWords = self.badWords else { return false }
            for badWord in badWords {
                if tag.text.contains(badWord) {
                    Alerter.showOneButtonAlert(on: self, title: .warning, message: .beRespectful, actionTitle: .ok, handler: nil)
                    return false
                }
            }
            // custom validations, called before tag is added to tags list
            return tag.text != "#" && !tags.contains(where: { $0.text.uppercased() == tag.text.uppercased() })
        }
    }
    
    //MARK: - Data
    
    private func loadBadWords() {
        guard let assets = NSDataAsset(name: "bad-words", bundle: Bundle.main)
        else { return }
        let data = assets.data
        badWords = try! JSONDecoder().decode([String].self, from: data)
    }
    
}

//MARK: - IBActions -

extension ProjectEditorViewController {
    
    @IBAction func didTapOutside(_ sender: Any) {
        titleTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        haveTagsField.textField.resignFirstResponder()
        needTagsField.textField.resignFirstResponder()
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        let title = titleTextField.text
        let description = descriptionTextField.text
        guard title != nil, !title!.isEmpty, description != nil, !description!.isEmpty,
              let userId = CurrentUser.shared.getCurrentUserId()
              else {
            Alerter.showOneButtonAlert(on: self, title: .oops, message: .checkFields, actionTitle: .ok, handler: nil)
            return
        }
        
        // extract string tags
        var haveTags: [String] = []
        var needTags: [String] = []
        for tag in haveTagsField.tags {
            haveTags.append(tag.text)
        }
        for tag in needTagsField.tags {
            needTags.append(tag.text)
        }
        
        let newProject = Project(title: title!, description: description!, haveTags: haveTags, needTags: needTags, ownerId: userId, ownerImage: nil, creationDate: Date())
        
        // if project wasn't set, add new project
        if project == nil {
            DatabaseHandler.shared.addDocument(object: newProject, collection: .projects, documentIdType: .random) {
                self.delegate?.didMakeChanges()
                self.dismiss(animated: true, completion: nil)
            } failure: { error in
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
        
        // if project was set, update project
        else {
            project!.object = newProject
            DatabaseHandler.shared.updateDocument(type: Project.self, databaseDocument: project!, collection: .projects) {
                self.delegate?.didMakeChanges()
                self.dismiss(animated: true, completion: nil)
            } failure: { error in
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
        guard let databaseDocument = project
              else {
            Alerter.showOneButtonAlert(on: self, title: .oops, message: .somethingWentWrong, actionTitle: .ok, handler: nil)
            return
        }
        Alerter.showTwoButtonAlert(on: self, title: .areYouSure, message: .deleteProjectQuestion, buttonOneTitle: .yes, buttonOneStyle: .destructive, buttonTwoTitle: .cancel, buttonTwoStyle: .cancel) { action in
            if action.style == .destructive {
                DatabaseHandler.shared.deleteDocument(documentId: databaseDocument.id, collection: .projects) {
                    self.delegate?.didMakeChanges()
                    self.dismiss(animated: true, completion: nil)
                } failure: { error in
                    Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    })
                }

            }
        }
    }
    
}
