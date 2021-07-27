//
//  UIImageExtension.swift
//  Connect
//
//  Created by Dino Martan on 27/07/2021.
//

import UIKit

extension UIImage {
    
    // in kb
    enum ImageQuality: Int {
        
        case lowest = 200
        case low = 400
        case medium = 600
        case high = 800
        case highest = 1000
        
    }
    
    // Image resize and compression source: https://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size/29138120
    
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func compress(to quality: ImageQuality) -> UIImage {
        let allowedMargin: CGFloat = 0.2
        guard quality.rawValue > 10 else { return self } // Prevents user from compressing below a limit (10kb in this case).
        let bytes = quality.rawValue * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false
        while(!complete) {
            guard let data = holderImage.jpegData(compressionQuality: 1.0) else { break }
            let ratio = data.count / bytes
            if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
                complete = true
                guard let uiImage = UIImage(data: data) else { return self }
                return uiImage
            } else {
                let multiplier:CGFloat = CGFloat((ratio / 5) + 1)
                compression -= (step * multiplier)
            }
            guard let newImage = holderImage.resized(withPercentage: compression) else { break }
            holderImage = newImage
        }
        return self
    }
    
}
