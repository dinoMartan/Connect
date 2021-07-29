//
//  ProfileViewController.swift
//  Connect
//
//  Created by Dino Martan on 26/07/2021.
//

import UIKit
import ViewAnimator
import SDWebImage

class ProfileViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var imageBackgroundView: UIView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nicknameLabel: UILabel!
    
    //MARK: - Private properties
    
    private var userDetails: UserDetails?
    private var settingsSections: [ProfileSettingSection] = []
    
    private let zoomAnimation = AnimationType.zoom(scale: 0.2)
    private let fadeAnimation = AnimationType.identity
    private let vectorAnimationLeftToRight = AnimationType.vector(CGVector(dx: -300, dy: 0))
    private let vectorAnimationRightToLeft = AnimationType.vector(CGVector(dx: 300, dy: 0))
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

}

//MARK: - Private extension -

private extension ProfileViewController {
    
    //MARK: - View Setup
    
    private func setupView() {
        imageBackgroundView.layer.cornerRadius = imageBackgroundView.frame.height / 2
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        tableView.backgroundColor = .connectBackground
        self.navigationController?.navigationBar.tintColor = .systemRed
        configureTableView()
        createSettings()
        fetchUserDetails {
            self.animateImage()
            self.animateNickname()
            self.loadDataToUI()
            self.tableView.reloadData()
        }
    }
    
    private func loadDataToUI() {
        guard let userDetails = userDetails else { return }
        if let image = userDetails.profileImage { profileImageView.sd_setImage(with: URL(string: image), completed: nil) }
        nicknameLabel.text = userDetails.name
    }
    
    //MARK: - TableView Configuration
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProfileSettingsSectionView", bundle: nil), forHeaderFooterViewReuseIdentifier: ProfileSettingsSectionView.identifier)
    }
    
    //MARK: - Animations
    
    private func animateImage() {
        UIView.animate(views: [profileImageView], animations: [zoomAnimation])
    }
    
    private func animateNickname() {
        UIView.animate(views: [nicknameLabel], animations: [fadeAnimation])
    }
    
    //MARK: - Data
    
    private func createSettings() {
        let settingOne = ProfileSetting(settingAction: .chageNickname, image: UIImage(systemName: "person"), label: "Change nickname", backgroundColor: nil, foregroundColor: nil)
        let settingTwo = ProfileSetting(settingAction: .changeProfileImage, image: UIImage(systemName: "person.fill"), label: "Change profile image", backgroundColor: nil, foregroundColor: nil)
        let firstSettingsSection = ProfileSettingSection.changes(sectionTitle: "CONFIGURE YOUR ACCOUNT", settings: [settingOne, settingTwo])
        
        let settingThree = ProfileSetting(settingAction: .signOut, image: nil, label: "Sign out", backgroundColor: .systemRed, foregroundColor: .white)
        let secondSettingsSection = ProfileSettingSection.actions(sectionTitle: "THE APPLICATION", settings: [settingThree])
        
        settingsSections.append(firstSettingsSection)
        settingsSections.append(secondSettingsSection)
    }
    
    private func fetchUserDetails(completion: @escaping (() -> Void)) {
        CurrentUser.shared.getCurrentUserDetails { [unowned self] userDetails in
            guard let details = userDetails else {
                Alerter.showOneButtonAlert(on: self, title: .oops, message: .somethingWentWrong, actionTitle: .ok) { _ in
                    dismiss(animated: true, completion: nil)
                    return
                }
                return
            }
            self.userDetails = details
            completion()
        } failure: { error in
            Alerter.showOneButtonAlert(on: self, title: .oops, error: error, actionTitle: .ok) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

//MARK: - TableView DataSource and Delegate -

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = settingsSections[section]
        switch section {
        case .changes(_, let settings):
            return settings.count
        case .actions(_, let settings):
            return settings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = settingsSections[indexPath.section]
        switch section {
        case .changes(_, let settings):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChangesSettingTableViewCell.identifier) as? ChangesSettingTableViewCell else { return UITableViewCell() }
            cell.configureCell(setting: settings[indexPath.row])
            cell.delegate = self
            return cell
        case .actions(_, let settings):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionsSettingTableViewCell.identifier) as? ActionsSettingTableViewCell else { return UITableViewCell() }
            cell.configureCell(setting: settings[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileSettingsSectionView.identifier) as? ProfileSettingsSectionView else { return nil }
        let section = settingsSections[section]
        switch section {
        case .actions(let sectionTitle, _):
            sectionView.configureSection(label: sectionTitle)
        case .changes(let sectionTitle, _):
            sectionView.configureSection(label: sectionTitle)
        }
        return sectionView
    }
    
    // animate cells on appear - randomly select left2right or right2left animation
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let random = Int.random(in: 1...10)
        if random % 2 == 0 { UIView.animate(views: [cell], animations: [fadeAnimation, vectorAnimationLeftToRight]) }
        else { UIView.animate(views: [cell], animations: [fadeAnimation, vectorAnimationRightToLeft]) }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let random = Int.random(in: 1...10)
        if random % 2 == 0 { UIView.animate(views: [view], animations: [fadeAnimation, vectorAnimationLeftToRight]) }
        else { UIView.animate(views: [view], animations: [fadeAnimation, vectorAnimationRightToLeft]) }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
}

//MARK: - TableCell Delegates -

extension ProfileViewController: ProfileSettingsTableViewCellDelegate {
    
    func didCallProfileSetting(setting: ProfileSetting) {
        switch setting.settingAction {
        case .chageNickname:
            changeNickname()
        case .changeProfileImage:
            changeProfilePicture()
        case .signOut:
            signOut()
        }
    }
    
    //MARK: - Helper methods
    
    private func signOut() {
        Alerter.showTwoButtonAlert(on: self, title: .signOut, message: .areYouSure, buttonOneTitle: .yes, buttonOneStyle: .default, buttonTwoTitle: .cancel, buttonTwoStyle: .cancel) { action in
            if action.style == .default {
                CurrentUser.shared.signOut(viewController: self)
            }
        }
    }
    
    private func changeNickname() {
        guard let currentUserDetails = userDetails,
              let userId = CurrentUser.shared.getCurrentUserId() else { return }
        showTextInputPrompt(withMessage: "New nickname") { didChange, nickname in
            if didChange, let newNickname = nickname {
                let userDetails = UserDetails(name: newNickname, profileImage: currentUserDetails.profileImage)
                let databaseDocument = DatabaseDocument(id: userId, object: userDetails)
                self.updateUserDetails(updateImage: false, databaseDocument: databaseDocument)
            }
        }
    }
    
    private func changeProfilePicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateUserDetails(updateImage: Bool, databaseDocument: DatabaseDocument) {
        DatabaseHandler.shared.updateUserDetails(databaseDocument: databaseDocument) {
            self.fetchUserDetails {
                if updateImage { self.animateNickname() }
                else { self.animateNickname() }
                self.loadDataToUI()
            }
        } failure: { error in
            Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
        }

    }
    
}

//MARK: - ImagePicker Delegate -

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            guard let currentUserDetails = userDetails,
                  let userId = CurrentUser.shared.getCurrentUserId() else { return }
            DatabaseHandler.shared.uploadImage(image: pickedImage, path: .profileImages, imageQuality: .lowest) { url in
                let userDetails = UserDetails(name: currentUserDetails.name, profileImage: url)
                let databaseDocument = DatabaseDocument(id: userId, object: userDetails)
                self.updateUserDetails(updateImage: true, databaseDocument: databaseDocument)
            } failure: { error in
                Alerter.showOneButtonAlert(on: self, title: .error, error: error, actionTitle: .ok, handler: nil)
            }

        }
    }
    
}
