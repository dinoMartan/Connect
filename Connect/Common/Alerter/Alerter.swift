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
        case warning = "Warning"
        case areYouSure = "Are you sure?"
        case signOut = "Sign out"
        case messageSent = "Message sent!"
        case selectType = "Select type"
        
    }

    enum AlertMessage: String {

        case somethingWentWrong = "Something went wrong."
        case passwordChanged = "Your password has been changed."
        case wrongCode = "Looks like your code is incorrect. Please try again."
        case checkFields = "Please make sure you input all fields."
        case wrongResponse = "We couldn't get the right response."
        case updateFailed = "Looks like update failed. Please try again."
        case dataFetchingFailed = "Looks like we couldn't fetch data. Please try again."
        case beRespectful = "Please don't be rude and be respectful."
        case deleteProjectQuestion = "Deleting the project cannot be undone."
        case areYouSure = "Are you sure?"
        case messageIsInConversations = "Now you can chat with the user in Conversations tab!"
        case selectImageType = "Select image type"
        
    }

    enum AlertButton: String {
        
        case ok = "OK"
        case yes = "YES"
        case delete = "DELETE"
        case cancel = "CANCEL"
        case camera = "Camera"
        case library = "Library"
        
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
    
    static func showTwoButtonAlert(on viewController: UIViewController, title: AlertTitle, message: AlertMessage, buttonOneTitle: AlertButton, buttonOneStyle: UIAlertAction.Style, buttonTwoTitle: AlertButton, buttonTwoStyle: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let actionOne = UIAlertAction(title: buttonOneTitle.rawValue, style: buttonOneStyle, handler: handler)
        let actionTwo = UIAlertAction(title: buttonTwoTitle.rawValue, style: buttonTwoStyle, handler: handler)
        alert.addAction(actionOne)
        alert.addAction(actionTwo)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showThreeButtonAlert(on viewController: UIViewController, alerterStyle: UIAlertController.Style, title: AlertTitle?, message: AlertMessage?, buttonOneTitle: AlertButton, buttonOneStyle: UIAlertAction.Style, buttonTwoTitle: AlertButton, buttonTwoStyle: UIAlertAction.Style, buttonThreeTitle: AlertButton, buttonThreeStyle: UIAlertAction.Style, buttonOnehandler: ((UIAlertAction) -> Void)?, buttonTwohandler: ((UIAlertAction) -> Void)?, buttonThreehandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title?.rawValue, message: message?.rawValue, preferredStyle: alerterStyle)
        let actionOne = UIAlertAction(title: buttonOneTitle.rawValue, style: buttonOneStyle, handler: buttonOnehandler)
        let actionTwo = UIAlertAction(title: buttonTwoTitle.rawValue, style: buttonTwoStyle, handler: buttonTwohandler)
        let actionThree = UIAlertAction(title: buttonThreeTitle.rawValue, style: buttonThreeStyle, handler: buttonThreehandler)
        
        alert.addAction(actionOne)
        alert.addAction(actionTwo)
        alert.addAction(actionThree)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
