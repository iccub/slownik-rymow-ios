//
//  FoundRhymesModel.swift
//  Slownik Rymow
//
//  Created by bucci on 16.06.2015.
//  Copyright (c) 2016 Michał Buczek. All rights reserved.
//

import Foundation

typealias ServiceResponse = (NSArray?) -> Void


class FoundRhymesModel {
  static func getRhymesForWord(word: String, sortMethod: String, rhymePrecision: String, rhymeLenght: Int, onCompletion: ServiceResponse){
    
    let request = prepareHTTPRequest(word, sortMethod: sortMethod, rhymePrecision: rhymePrecision, rhymeLenght: rhymeLenght)
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      
      if error != nil{
        print("error=\(error)")
        return
      }
      
      do {
        let jsonObject =  try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSArray
        var rhymeArray = [String]()
        
        for elem: AnyObject in jsonObject {
          let name = elem["word"] as! String
          rhymeArray.append(name)
        }
        
        onCompletion(rhymeArray)
        
        
      } catch {
        print("parsing json error")
        onCompletion(nil)
      }
    }
    task.resume()
    
  }
  
  private static func prepareHTTPRequest(word: String, sortMethod: String, rhymePrecision: String, rhymeLenght: Int) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(URL: NSURL(string: "http://178.62.220.64/wbs/findRhymes.php")!)
    request.HTTPMethod = "POST"
    let postString = "rhyme_precision=\(rhymePrecision)&sort_method=\(sortMethod)&rhyme_length=\(rhymeLenght)&search_word=\(word)"
    request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
    
    return request
  }
  
  
  
  static func getRhymeDefinition(word: String, onCompletion: (String) -> Void){
    
    let rhymeDefinitionURL = "http://sjp.pl/\(word)"
    let escapedRhymeDefinitionURL = rhymeDefinitionURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    

    var resultString = ""
    
    guard let address = escapedRhymeDefinitionURL, myURL = NSURL(string: address) else {
      print("error getting url for rhyme definition")
      onCompletion("Błąd połączenia z serwerem")
      return
    }
    
    let htmlDataString: NSString?
    do {
      htmlDataString = try NSString(contentsOfURL: myURL, encoding: NSUTF8StringEncoding)
    } catch let error as NSError {
      print("error with fetching found rhymes definition: \(error)")
      htmlDataString = nil
    }
    
    let splitMagicString = "style=\"margin-top: .5em; font-size: medium; max-width: 32em; \">"
    
    guard let htmlString = htmlDataString where htmlString.componentsSeparatedByString(splitMagicString).count > 1 else {
      print("No rhyme definition found")
      onCompletion("Brak definicji w słowniku")
      return
    }
    
    let splitArray = htmlString.componentsSeparatedByString(splitMagicString)
    
    //ilosc paragrafow z definicja to count -1
    for index in 1...(splitArray.count - 1) {
      
      let paragraph = splitArray[index]
      let cuttedParagraph = cutParagraph(paragraph)
      
      resultString += formatParagraph(cuttedParagraph)
  
    }
    onCompletion(resultString)
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
