//
//  FindRhymeDBHelper.swift
//  Slownik Rymow
//
//  Created by Michał Buczek on 18.12.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation
import SQLite

class FindRhymeDataHelper {
    let table = Table("word_list")
    let word = Expression<String>("word")
    
    func findRhymes(with parameters: SearchParameters) throws -> [FoundRhyme] {
        guard let db = DBConnection.shared.connection else {
            throw DBError.datastoreConnectionError
        }
        
        #if DEBUG
            db.trace { print($0) }
        #endif
        
        let preparedQuery = prepareStatement(parameters)
        
        var foundRhymes: [FoundRhyme] = []
        
        do {
            let queryResults = try db.prepare(preparedQuery)
            for row in queryResults {
                for (word, _) in queryResults.columnNames.enumerated() {
                    if let row = row[word] as? FoundRhyme {
                        foundRhymes.append(row)
                    }
                }
            }
        } catch {
            throw DBError.sqlStatementError
        }

        return foundRhymes
    }
    
    // Query is prepared by hand. I decided to not use type-safe features of sqlite.swift because the query is pretty complicated
    // and originally I wanted to write some statements using REGEXP keyword
    private func prepareStatement(_ parameters: SearchParameters) -> String {
        
        var inputWord = parameters.word
        let inputWordCharacters = inputWord.characters
        
        let rhymeLength = parameters.rhymeLenght > inputWordCharacters.count ? inputWordCharacters.count : parameters.rhymeLenght
        
        let rhymeRange = inputWordCharacters.index(inputWordCharacters.endIndex, offsetBy: rhymeLength * -1) ..< inputWordCharacters.endIndex
        let trimmedInputWord = inputWord[rhymeRange]
        
        //MARK: Base query
        var query = "SELECT * FROM word_list WHERE word LIKE '%\(trimmedInputWord)' "
        
        //Letters 'u' and 'ó' sound the same phonetically. Checking both possibilities.
        let wordWithUSwapped2 = trimmedInputWord.contains("u") ?
            trimmedInputWord.replacingOccurrences(of: "u", with: "ó") : trimmedInputWord.replacingOccurrences(of: "ó", with: "u")
        
        query += appendLikeStatement(wordToCompare: wordWithUSwapped2)
        
        //MARK: Non-precise rhymes algorithm
        if parameters.rhymePrecision == .nonPrecise {
            
            //Add consonant at the word's end. It usually rhymes.
            let consonantsArray = ["b", "c", "ć", "d", "f", "g", "h", "j", "k", "l", "ł", "m", "n", "ń", "p",
                                   "r", "s", "ś", "t", "w", "z", "ź", "ź", "cz", "dz", "dź", "dż", "sz", "ch", "rz"]
            
            //REGEXP doesn't seem to work in iOS implementation of sqlite so instead I'm doing big chain of 'like' statements, one for each consonant.
            for consonant in consonantsArray {
                query += appendLikeStatement(wordToCompare: trimmedInputWord + consonant)
            }
            
            //Looking for last consonant in the word and swap it with other consonants
            do {
                //Digraphs(double character consonants) are placed first so they don't overlap with single characters
                // for example word 'talerz' contains 3 consonants: 't' 'l' 'rz'
                // if one character consonants were first it showed 4 consonants matches what was wrong
                let consonantsRegexPattern = "(cz|dz|dź|dż|sz|ch|rz|[bcćdfghjklłmnńprsśtwzżź])"
                let consonantsRegex = try NSRegularExpression(pattern: consonantsRegexPattern, options: [])
                
                let consonantsMatches = consonantsRegex.matches(in: trimmedInputWord, options: [], range: NSRange(location: 0, length: trimmedInputWord.characters.count))
                
                if let lastMatch = consonantsMatches.last {
                    for consonant in consonantsArray {
                        
                        //casting to NSString because it has replace function with NSRange argument, unlike the regular String
                        let inputWordNSString = trimmedInputWord as NSString
                        let newWord = inputWordNSString.replacingCharacters(in: lastMatch.range, with: consonant)
                        
                        query += appendLikeStatement(wordToCompare: newWord)
                    }
                }
            } catch {
                //regex error, can do nothing here
            }
        }
        
        //MARK: Sorth order
        if parameters.sortMethod == .random {
            query += "ORDER BY RANDOM() "
        }
        
        //MARK: Results limit
        //I have in plans to change it to user defined value through settings, for now it's a constant
        // 200 words is enough results to look through
        query += "limit 200;"
        
        return query
    }
    
    private func appendLikeStatement(wordToCompare: String) -> String {
        return "OR \(word.template) LIKE '%\(wordToCompare)' "
    }
}

