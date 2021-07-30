//
//  ImageViewerViewController.swift
//  Connect
//
//  Created by Dino Martan on 30/07/2021.
//

import UIKit

class ImageViewerViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var displayingImageView: UIImageView!
    
    //MARK: - Public properties
    
    var image: UIImage?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

}

//MARK: - Private extension -

private extension ImageViewerViewController {
    
    //MARK: - View Setup
    
    private func setupView() {
        setImage()
    }
    
    private func setImage() {
        guard let image = image else {
            dismiss(animated: true, completion: nil)
            return
        }
        displayingImageView.image = image
    }
    
}
