//
//  Alerter.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import UIKit

final class Alerter {
    
    enum AlertTitle: String {
        
        case error = "Error"
        case wrongCode = "Wrong code"
        case oops = "Oops"
        case success = "Success"
        
    }

    enum AlertMessage: String {

        case somethingWentWrong = "Something went wrong."
        case passwordChanged = "Your password has been changed."
        case wrongCode = "Looks like your code is incorrect. Please try again."
        case checkFields = "Please make sure you input all fields."
        case wrongResponse = "We couldn't get the right response."
        case updateFailed = "Looks like update failed. Please try again."
        case dataFetchingFailed = "Looks like we couldn't fetch data. Please try again."
        
    }

    enum AlertButton: String {
        
        case ok = "OK"
        
    }
    
    static func showOneButtonAlert(on viewController: UIViewController, title: AlertTitle, message: AlertMessage, actionTitle: AlertButton, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle.rawValue, style: .default, handler: handler)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showOneButtonAlert(on viewController: UIViewController, title: AlertTitle, error: Error?, actionTitle: AlertButton, handler: ((UIAlertAction) -> Void)?) {
        var alert: UIAlertController
        if error != nil {
            alert = UIAlertController(title: title.rawValue, message: error!.localizedDescription, preferredStyle: .alert)
        }
        else {
            alert = UIAlertController(title: title.rawValue, message: AlertMessage.somethingWentWrong.rawValue, preferredStyle: .alert)
        }
        let action = UIAlertAction(title: actionTitle.rawValue, style: .default, handler: handler)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
