//
//  String+Extensions.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 26/01/2020.
//  Copyright © 2020 Michał Buczek. All rights reserved.
//

import Foundation

extension String {
    /// Returns a string that contains only polish characters.
    /// This helper also removes all whitespace characters, it is meant to return a single word.
    var wordWithPolishCharactersOnly: String {
        let allowedLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzĄĘÓŃŚĆŻŹŁąęóńśćżźł"
        
        return self.filter { allowedLetters.contains($0) }
    }
}
