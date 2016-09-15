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
    
    func showErrorAlert(_ errorType: AppErrors, word: String = "") {
        var title = ""
        var message = ""
        
        switch errorType {
        case .noDefinitionsFound:
            title = word
            message = "Brak definicji w słowniku"
        case .notConnectedToNetworkError:
            title = "Błąd połączenia"
            message = "Słownik nie działa w trybie offline. Sprawdź swoje połączenie z internetem"
        case .parseError, .networkError:
            title = "Błąd serwera"
            message = "Wystąpił błąd po stronie serwera. Spróbuj ponownie za kilka minut"
        case .noRhymesFound:
            title = "Brak wyników"
            message = "Brak rymów do słowa \(word)"
        }
        
        let alert = buildAlert(title, msg: message)
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    func showLoadingAlert(_ preciseRhymeSearch: Bool) {
        let message = preciseRhymeSearch ? "" : "Szukanie rymów niedokładnych zajmuje więcej czasu"
        let alert = buildAlert("Szukam rymów", msg: message, withActivityIndicator: true, cancellable: false)
        vc.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func buildAlert(_ title: String, msg: String, withActivityIndicator: Bool = false, cancellable: Bool = true) -> UIAlertController{
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor.orange
        
        if cancellable {
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        }
        
        if withActivityIndicator {
            addActivityIndicatorToAlertController(alert)
        }
        
        return alert
    }
    
    fileprivate func addActivityIndicatorToAlertController(_ alertView: UIAlertController) {
        var views = [String : UIView]()
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alertView.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        
        views = ["pending" : alertView.view, "indicator" : indicator]
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(-50)-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: [], metrics: nil, views: views)
        alertView.view.addConstraints(constraints)
    }
    
    func showFormattedAlert(_ message: String, title: String) {
        let formattedMessage = prepareAttributedString(message)
        
        //I need to build cancellable alert and create "OK" there because I want to have "OK" button to the right
        let alert = buildAlert(title, msg: message, cancellable: false)
        alert.setValue(formattedMessage, forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "Copy word", style: UIAlertActionStyle.default) { _ in
            UIPasteboard.general.string = title
            })
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func prepareAttributedString(_ message: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.justified
        
        let messageText = NSMutableAttributedString(
            string: message,
            attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1),
                NSForegroundColorAttributeName : UIColor.black
            ]
        )
        
        return messageText
    }
}
