//
//  RhymeDefinitionManager.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 26.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation

enum RhymeDefinitionManagerStatus {
    case success(definition: RhymeDefinition)
    case failure(error: AppErrors)
}

struct RhymeDefinitionManager {
    let rhymeDefinitionService: RhymeDefinitionService
    
    init(rhymeDefinitionService: RhymeDefinitionService = RhymeDefinitionService()) {
        self.rhymeDefinitionService = rhymeDefinitionService
    }
    
    func getRhymeDefinition(_ word: String, completion: @escaping (_ status: RhymeDefinitionManagerStatus) -> Void){
        guard Reachability.isConnectedToNetwork() else {
            completion(.failure(error: .notConnectedToNetworkError))
            return
        }
        
        rhymeDefinitionService.getWordDefinitionHTML(word) { status in
            
            switch status {
            case .failure(let error):
                completion(.failure(error: error))
            case .success(let htmlString):
                do {
                    let resultString = try self.formatHTMLToDescription(htmlString, word: word)
                    completion(.success(definition: resultString))
                } catch let error {
                    if let error = error as? AppErrors {
                        completion(.failure(error: error))
                    } else {
                        print("undefined error, should never launch, throws parse error just in case")
                        completion(.failure(error: .parseError))
                    }
                }
            }
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
        let splitMagicString = "style=\"margin: .5em 0; font-family: sans-serif; font-size: medium; max-width: 32em; \">"
      
        var sectionsArray = html.components(separatedBy: splitMagicString)
        
        guard sectionsArray.count > 1 else {
            throw AppErrors.noDefinitionsFound
        }
        
        //first part of split is junk - all the html body before first occurence of paragraph with word description so I remove it here
        sectionsArray.removeFirst()
        
        var resultArray = [RhymeDefinition]()
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
        
        let stringWithDashes = regex.matches(in: paragraph, options: [], range: NSMakeRange(0, paragraph.characters.count)).count > 0
            ? regex.stringByReplacingMatches(in: paragraph, options: [], range: NSMakeRange(0, paragraph.characters.count), withTemplate: "-") : "- \(paragraph)"
        
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
