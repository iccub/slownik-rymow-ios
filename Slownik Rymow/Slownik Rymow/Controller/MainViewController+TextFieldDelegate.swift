//
//  MainViewController+TextFieldDelegate.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import UIKit

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == inputWord.text! {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    //funkcja blokuje wszystkie znaki specjalne poza A-Z i polskimi ogonkami
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzĄĘÓŃŚĆŻŹŁąęóńśćżźł"
        let charset = CharacterSet(charactersIn: allowedLetters).inverted
        
        return string.rangeOfCharacter(from: charset) == nil
    }
}
