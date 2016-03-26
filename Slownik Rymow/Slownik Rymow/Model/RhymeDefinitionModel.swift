//
//  RhymeDefinitionModel.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation

typealias RhymeDefinition = String

enum RhymeDefinitionStatus {
    case Success(definition: RhymeDefinition)
    case Failure(error: AppErrors)
}

struct RhymeDefinitionModel {
    static func getRhymeDefinition(word: String, completion: (status: RhymeDefinitionStatus) -> Void){
        guard Reachability.isConnectedToNetwork() else {
            completion(status: .Failure(error: .NotConnectedToNetworkError))
            return
        }
        
        RhymeDefinitionService.getWordDefinitionHTML(word) {
            status in
            
            switch status {
            case .Failure(let error):
                completion(status: .Failure(error: error))
            case .Success(let htmlString):
                var resultString = ""
                let splitMagicString = "style=\"margin-top: .5em; font-size: medium; max-width: 32em; \">"
                
                guard htmlString.componentsSeparatedByString(splitMagicString).count > 1 else {
                    print("No rhyme definition found")
                    completion(status: .Failure(error: AppErrors.EmptyResults))
                    return
                }
                
                let splitArray = htmlString.componentsSeparatedByString(splitMagicString)
                
                //ilosc paragrafow z definicja to count -1
                for index in 1...(splitArray.count - 1) {
                    
                    let paragraph = splitArray[index]
                    let cuttedParagraph = cutParagraph(paragraph)
                    
                    resultString += formatParagraph(cuttedParagraph)
                    
                }
                completion(status: .Success(definition: resultString))
            }
        }
    }
    
    //Wycina paragraf od <p> do </p>
    private static func cutParagraph(paragraph: String) -> String {
        guard let ClosingParagraphMarkRange = paragraph.rangeOfString("</p>") else {
            print("Cant find closing </p>")
            return ""
        }
        
        
        //szukam indexu wycinku tekstu po paragrafie
        //    let ClosingParagrapshMarkIndex: Int = distance(paragraph.startIndex, ClosingParagraphMarkRange.startIndex)
        
        let ClosingParagrapshMarkIndex: Int = (paragraph.startIndex).distanceTo(ClosingParagraphMarkRange.startIndex)
        
        
        
        return (paragraph as NSString).substringToIndex(ClosingParagrapshMarkIndex)
    }
    
    private static func formatParagraph(paragraph: String) -> String {
        
        var resultString = ""
        var regex: NSRegularExpression?
        
        do {
            regex = try NSRegularExpression(pattern: "[0-9]+\\.", options: [])
        } catch let error as NSError {
            regex = nil
            print(error)
        }
        
        guard let reg = regex else {
            print("Error when initializing regex")
            return ""
        }
        
        //jak pierwszy znak to cyfra to szukam kropki i zamieniam wszystko na myslnik zeby bylo spojnie
        // a jak nie ma cyfry to dodaje myslnik od razu
        let stringWithDashes = reg.matchesInString(paragraph, options: [], range: NSMakeRange(0, paragraph.characters.count)).count > 0
            ? reg.stringByReplacingMatchesInString(paragraph, options: [], range: NSMakeRange(0, paragraph.characters.count), withTemplate: "-") : "- \(paragraph)"
        
        resultString += replaceWhiteSpaces(stringWithDashes)
        resultString += "\n"
        
        return resultString
    }
    
    private static func replaceWhiteSpaces(text: String) -> String {
        return text.stringByReplacingOccurrencesOfString("<br />", withString: "\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
            .stringByReplacingOccurrencesOfString("&nbsp", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            .stringByReplacingOccurrencesOfString("&quot;", withString: "\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
    }
    
    
    
}