//
//  DBRepository.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 09/01/2020.
//  Copyright © 2020 Michał Buczek. All rights reserved.
//

import Foundation
import Combine
import SQLite

struct DBRepository {
  let database: SingleColumnDatabase
  private let queue = DispatchQueue(label: "findrhyme")
  
  init(database: SingleColumnDatabase = WordsDatabase()) {
    self.database = database
  }
  
  func findRhymes(with parameters: SearchParameters) async throws -> [Rhyme] {
    guard let db = self.database.connection else {
      throw DBError.datastoreConnectionError
    }
    
    let preparedQuery = self.prepareQueryStatement(with: parameters)
    
    var foundRhymes = [Rhyme]()
    
    do {
      let queryResults = try db.prepare(preparedQuery)
      
      // Do nothing but soak FTS error eventually.
      // SQLite.swift 0.12.2 force throws error when incorrect FTS syntax is used.
      // See `FailableIterator` for more details
      _ = try queryResults.failableNext()
      
      for row in queryResults {
        for (word, _) in queryResults.columnNames.enumerated() {
          if let row = row[word] as? String {
            // Reversing results to show user words in proper order
            let rowReversed = String(row.reversed())
            
            foundRhymes.append(Rhyme(id: rowReversed))
          }
        }
      }
    } catch {
      throw DBError.sqlStatementError
    }
    
    return foundRhymes
  }
  
  /** Query is prepared by hand. I decided to not use type-safe features of sqlite.swift because the query is pretty complicated..
   Words in database are stored in reverse order. Thanks to that we can take advantage of sqlite's full text search features.
   Using fts MATCH instead of regular LIKE expressions is many times faster for our use case.
   */
  private func prepareQueryStatement(with parameters: SearchParameters) -> String {
    
    let inputWord = parameters.word
    let inputWordCharacters = inputWord
    
    let rhymeLength = parameters.rhymeLenght > inputWordCharacters.count ? inputWordCharacters.count : parameters.rhymeLenght
    
    let rhymeRange = inputWordCharacters.index(inputWordCharacters.endIndex, offsetBy: rhymeLength * -1) ..< inputWordCharacters.endIndex
    let inputRhyme = inputWord[rhymeRange]
    
    let inputRhymeReversed = String(inputRhyme.reversed())
    
    //MARK: Base query
    var query = "SELECT * FROM \(database.tableName) WHERE \(database.columnName) MATCH '\(inputRhymeReversed)* "
    
    //Letters 'u' and 'ó' sound the same phonetically. Checking both possibilities.
    if inputRhymeReversed.contains("u") || inputRhymeReversed.contains("ó") {
      let wordWithUSwapped = inputRhymeReversed.contains("u") ?
        inputRhymeReversed.replacingOccurrences(of: "u", with: "ó") : inputRhymeReversed.replacingOccurrences(of: "ó", with: "u")
      
      query += appendMatchStatement(wordToCompare: wordWithUSwapped)
    }
    
    //MARK: Non-precise rhymes algorithm
    if parameters.rhymePrecision == .nonPrecise {
      
      //Add consonant at the word's end. It usually rhymes.
      let reversedConsonantsArray = ["b", "c", "ć", "d", "f", "g", "h", "j", "k", "l", "ł", "m", "n", "ń", "p",
                                     "r", "s", "ś", "t", "w", "z", "ź", "ź", "zc", "zd", "źd", "żd", "zs", "hc", "zr"]
      
      //REGEXP doesn't seem to work in iOS implementation of sqlite so instead I'm doing big chain of 'like' statements, one for each consonant.
      // performance sucked while using LIKE statements, but it's fine with fts4 MATCH
      for consonant in reversedConsonantsArray {
        query += appendMatchStatement(wordToCompare: consonant + inputRhymeReversed)
        
        // FIXME: DRY u/ó code
        if inputRhymeReversed.contains("u") || inputRhymeReversed.contains("ó") {
          let wordWithUSwapped = inputRhymeReversed.contains("u") ?
            inputRhymeReversed.replacingOccurrences(of: "u", with: "ó") : inputRhymeReversed.replacingOccurrences(of: "ó", with: "u")
          
          query += appendMatchStatement(wordToCompare: consonant + wordWithUSwapped)
        }
      }
      
      //Looking for last consonant(first in reverse) in the word and swap it with other consonants
      do {
        //Digraphs(double character consonants) are placed first so they don't overlap with single characters
        // for example word 'talerz' contains 3 consonants: 't' 'l' 'rz'
        // if one character consonants were first it showed 4 consonants matches what was wrong
        let reversedConsonantsPattern = "(zc|zd|źd|żd|zs|hc|zr|[bcćdfghjklłmnńprsśtwzżź])"
        let reversedConsonantsRegex = try NSRegularExpression(pattern: reversedConsonantsPattern, options: [])
        
        let consonantsMatches = reversedConsonantsRegex.matches(in: inputRhymeReversed, options: [],
                                                                range: NSRange(location: 0, length: inputRhyme.count))
        if let firstMatch = consonantsMatches.first {
          for consonant in reversedConsonantsArray {
            
            //casting to NSString because it has replace function with NSRange argument, unlike the regular String
            let inputWordNSString = inputRhymeReversed as NSString
            let newWord = inputWordNSString.replacingCharacters(in: firstMatch.range, with: consonant)
            
            query += appendMatchStatement(wordToCompare: newWord)
            
            // FIXME: DRY u/ó code
            if newWord.contains("u") || newWord.contains("ó") {
              let wordWithUSwapped = newWord.contains("u") ?
                newWord.replacingOccurrences(of: "u", with: "ó") : newWord.replacingOccurrences(of: "ó", with: "u")
              
              query += appendMatchStatement(wordToCompare: wordWithUSwapped)
            }
          }
        }
      } catch {
        assertionFailure("Regex error: \(error)")
      }
    }
    
    //closing match expression
    query += "' ";
    
    //MARK: Sort order
    if parameters.sortMethod == .random {
      query += "ORDER BY RANDOM() "
    }
    
    //MARK: Results limit
    //I have in plans to change it to user defined value through settings, for now it's a constant
    // 200 words is enough results to look through
    query += "limit 200;"
    
    return query
  }
  
  private func appendMatchStatement(wordToCompare: String) -> String {
    return "OR \(wordToCompare)* "
  }
}
