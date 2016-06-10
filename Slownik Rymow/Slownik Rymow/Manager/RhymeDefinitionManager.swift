//
//  RhymeDefinitionManager.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 26.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation

enum RhymeDefinitionManagerStatus {
    case Success(definition: RhymeDefinition)
    case Failure(error: AppErrors)
}

struct RhymeDefinitionManager {
    let rhymeDefinitionService: RhymeDefinitionService
    
    init(rhymeDefinitionService: RhymeDefinitionService = RhymeDefinitionService()) {
        self.rhymeDefinitionService = rhymeDefinitionService
    }
    
    func getRhymeDefinition(word: String, completion: (status: RhymeDefinitionManagerStatus) -> Void){
        guard Reachability.isConnectedToNetwork() else {
            completion(status: .Failure(error: .NotConnectedToNetworkError))
            return
        }
        
        rhymeDefinitionService.getWordDefinitionHTML(word) { status in
            
            switch status {
            case .Failure(let error):
                completion(status: .Failure(error: error))
            case .Success(let htmlString):
                do {
                    let resultString = try self.formatHTMLToDescription(htmlString, word: word)
                    completion(status: .Success(definition: resultString))
                } catch let error {
                    if let error = error as? AppErrors {
                        completion(status: .Failure(error: error))
                    } else {
                        print("undefined error, should never launch, throws parse error just in case")
                        completion(status: .Failure(error: .ParseError))
                    }
                }
            }
        }
    }
    
    func formatHTMLToDescription(html: String, word: String) throws -> String {
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
    func splitHtmlToDescriptionParagraphs(html: String, word: String) throws -> [String]{
        //each relevant paragraph has style like this, so I'm searching for its occurences in html source
        let splitMagicString = "style=\"margin: .5em 0; font-size: medium; max-width: 32em; \">"
        var sectionsArray = html.componentsSeparatedByString(splitMagicString)
        
        guard sectionsArray.count > 1 else {
            throw AppErrors.NoDefinitionsFound
        }
        
        //first part of split is junk - all the html body before first occurence of paragraph with word description so I remove it here
        sectionsArray.removeFirst()
        
        var resultArray = [RhymeDefinition]()
        do {
            for section in sectionsArray {
                try resultArray.append(cutParagraph(section))
            }
        } catch {
            throw AppErrors.ParseError
        }
        
        return resultArray
    }
    
    private func cutParagraph(paragraph: String) throws -> String {
        guard let closingParagraphRange = paragraph.rangeOfString("</p>") else {
            throw AppErrors.ParseError
        }
        
        return paragraph.substringToIndex(closingParagraphRange.startIndex)
    }
    
    /** There are 2 types of definitions in sjp.pl website:
     numbered list when there is few definitions under one context
     and regular text when there is only one definition. This methods both so they are shown to user in standarized manner, with dashes for each definition */
    private func formatParagraph(paragraph: String) throws -> String{
        
        var resultString = ""
        var numberRegex: NSRegularExpression?
        
        do {
            numberRegex = try NSRegularExpression(pattern: "[0-9]+\\.", options: [])
        } catch {
            throw AppErrors.ParseError
        }
        
        guard let regex = numberRegex else {
            throw AppErrors.ParseError
        }
        
        let stringWithDashes = regex.matchesInString(paragraph, options: [], range: NSMakeRange(0, paragraph.characters.count)).count > 0
            ? regex.stringByReplacingMatchesInString(paragraph, options: [], range: NSMakeRange(0, paragraph.characters.count), withTemplate: "-") : "- \(paragraph)"
        
        resultString += replaceWhiteSpaces(stringWithDashes)
        resultString += "\n"
        
        return resultString
    }
    
    private func replaceWhiteSpaces(text: String) -> String {
        return text.stringByReplacingOccurrencesOfString("<br />", withString: "\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
            .stringByReplacingOccurrencesOfString("&nbsp", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            .stringByReplacingOccurrencesOfString("&quot;", withString: "\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
    }
}