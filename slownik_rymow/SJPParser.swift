//
//  SJPParser.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 09/01/2020.
//  Copyright © 2020 Michał Buczek. All rights reserved.
//

import Foundation
import Combine

class SJPParser: ObservableObject {
    
    @Published var showAlert = false
    @Published var wordDefinition = ""
    
    var cancellable: AnyCancellable?
    
    deinit {
        cancellable?.cancel()
    }
    
    func parse(word: String) {
        guard let escapedRhymeDefinitionURL = "https://sjp.pl//\(word)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: escapedRhymeDefinitionURL) else {
                return
        }
        
        let session = URLSession.shared
        
        cancellable = session.dataTaskPublisher(for: url)
            .map { String(decoding: $0.data, as: UTF8.self) } //parse further
            .map { try? self.formatHTMLToDescription($0, word: word) }
            .replaceError(with: "")
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sink {
                guard let data = $0 else {
                    return
                }
                                
                self.wordDefinition = data
                self.showAlert = true
            }
    }
    
    func formatHTMLToDescription(_ html: String, word: String) throws -> String {
        var resultString = ""
        
        do {
            let splitArray = try splitHtmlToDescriptionParagraphs(html, word: word)
            
            for paragraph in splitArray {
                resultString += try formatParagraph(paragraph)
            }
        } catch let error as AppErrors {
            throw error
        }
        
        return resultString
    }
    
    /** sjp.pl webpage word definitions are split into paragraphs, because polish words often have few meanings */
    func splitHtmlToDescriptionParagraphs(_ html: String, word: String) throws -> [String]{
        //each relevant paragraph has style like this, so I'm searching for its occurences in html source
        let splitMagicString = "style=\"margin: .5em 0; font: medium/1.4 sans-serif; max-width: 32em; \">"
        
        var sectionsArray = html.components(separatedBy: splitMagicString)
        
        guard sectionsArray.count > 1 else {
            throw AppErrors.noDefinitionsFound
        }
        
        //first part of split is junk - all the html body before first occurence of paragraph with word description so I remove it here
        sectionsArray.removeFirst()
        
        var resultArray = [String]()
        do {
            for section in sectionsArray {
                try resultArray.append(cutParagraph(section))
            }
        } catch {
            throw AppErrors.parseError
        }
        
        return resultArray
    }
    
    fileprivate func cutParagraph(_ paragraph: String) throws -> String {
        guard let closingParagraphRange = paragraph.range(of: "</p>") else {
            throw AppErrors.parseError
        }
        
        return paragraph.substring(to: closingParagraphRange.lowerBound)
    }
    
    /** There are 2 types of definitions in sjp.pl website:
     numbered list when there is few definitions under one context
     and regular text when there is only one definition. This methods both so they are shown to user in standarized manner, with dashes for each definition */
    fileprivate func formatParagraph(_ paragraph: String) throws -> String{
        
        var resultString = ""
        var numberRegex: NSRegularExpression?
        
        do {
            numberRegex = try NSRegularExpression(pattern: "[0-9]+\\.", options: [])
        } catch {
            throw AppErrors.parseError
        }
        
        guard let regex = numberRegex else {
            throw AppErrors.parseError
        }
        
        let stringWithDashes = regex.matches(in: paragraph, options: [], range: NSMakeRange(0, paragraph.count)).count > 0
            ? regex.stringByReplacingMatches(in: paragraph, options: [], range: NSMakeRange(0, paragraph.count), withTemplate: "-") : "- \(paragraph)"
        
        resultString += replaceWhiteSpaces(stringWithDashes)
        resultString += "\n"
        
        return resultString
    }
    
    fileprivate func replaceWhiteSpaces(_ text: String) -> String {
        return text.replacingOccurrences(of: "<br />", with: "\n", options: NSString.CompareOptions.literal, range: nil)
            .replacingOccurrences(of: "&nbsp", with: "", options: NSString.CompareOptions.literal, range: nil)
            .replacingOccurrences(of: "&quot;", with: "\"", options: NSString.CompareOptions.literal, range: nil)
        
    }
}

enum AppErrors: Error {
    case notConnectedToNetworkError
    case networkError
    case sqlError
    /** Thrown when rhyme description was not properly parsed */
    case parseError
    case noRhymesFound
    case noDefinitionsFound
}
