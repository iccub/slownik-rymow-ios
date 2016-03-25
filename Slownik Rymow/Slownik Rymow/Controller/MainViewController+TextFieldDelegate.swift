//
//  MainViewController+TextFieldDelegate.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import UIKit

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == inputWord.text {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    //funkcja blokuje wszystkie znaki specjalne poza A-Z i polskimi ogonkami
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let allowedLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzĄĘÓŃŚĆŻŹŁąęóńśćżźł"
        let charset = NSCharacterSet(charactersInString: allowedLetters).invertedSet
        
        return string.rangeOfCharacterFromSet(charset) == nil
    }
}