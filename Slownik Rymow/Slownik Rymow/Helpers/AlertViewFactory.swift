//
//  AlertViewFactory.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 26.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import UIKit

struct AlertViewFactory {
    let vc: UIViewController
    
    func showErrorAlert(errorType: AppErrors, word: String = "") {
        var title = ""
        var message = ""
        
        switch errorType {
        case .NoDefinitionsFound:
            title = word
            message = "Brak definicji w słowniku"
        case .NotConnectedToNetworkError:
            title = "Błąd połączenia"
            message = "Słownik nie działa w trybie offline. Sprawdź swoje połączenie z internetem"
        case .ParseError, .NetworkError:
            title = "Błąd serwera"
            message = "Wystąpił błąd po stronie serwera. Spróbuj ponownie za kilka minut"
        case .NoRhymesFound:
            title = "Brak wyników"
            message = "Brak rymów do słowa \(word)"
        }
        
        let alert = buildAlert(title, msg: message)
        vc.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func showLoadingAlert(preciseRhymeSearch: Bool) {
        let message = preciseRhymeSearch ? "" : "Szukanie rymów niedokładnych zajmuje więcej czasu"
        let alert = buildAlert("Szukam rymów", msg: message, withActivityIndicator: true, cancellable: false)
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func buildAlert(title: String, msg: String, withActivityIndicator: Bool = false, cancellable: Bool = true) -> UIAlertController{
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UIColor.orangeColor()
        
        if cancellable {
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        }
        
        if withActivityIndicator {
            addActivityIndicatorToAlertController(alert)
        }
        
        return alert
    }
    
    private func addActivityIndicatorToAlertController(alertView: UIAlertController) {
        var views = [String : UIView]()
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alertView.view.addSubview(indicator)
        indicator.userInteractionEnabled = false
        indicator.startAnimating()
        
        views = ["pending" : alertView.view, "indicator" : indicator]
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[indicator]-(-50)-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[indicator]|", options: [], metrics: nil, views: views)
        alertView.view.addConstraints(constraints)
    }
    
    func showFormattedAlert(message: String, title: String) {
        let formattedMessage = prepareAttributedString(message)
        
        //I need to build cancellable alert and create "OK" there because I want to have "OK" button to the right
        let alert = buildAlert(title, msg: message, cancellable: false)
        alert.setValue(formattedMessage, forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "Copy word", style: UIAlertActionStyle.Default) { _ in
            UIPasteboard.generalPasteboard().string = title
            })
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func prepareAttributedString(message: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Justified
        
        let messageText = NSMutableAttributedString(
            string: message,
            attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1),
                NSForegroundColorAttributeName : UIColor.blackColor()
            ]
        )
        
        return messageText
    }
}