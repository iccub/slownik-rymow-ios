//
//  RhymeDefinitionService.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 26.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation
import Alamofire

enum RhymeDefinitionServiceStatus {
    case Success(html: String)
    case Failure(error: AppErrors)
}

struct RhymeDefinitionService {
    
    static func getWordDefinitionHTML(word: String, completion: (status: RhymeDefinitionServiceStatus) -> Void) {
        let escapedRhymeDefinitionURL = "http://sjp.pl//\(word)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        Alamofire.request(.GET, escapedRhymeDefinitionURL!, encoding: .URL).validate().responseString(encoding: NSUTF8StringEncoding) {
            response in
            
            guard response.result.error == nil, let data = response.result.value else {
                completion(status: .Failure(error: .NetworkError))
                return
            }
            
            completion(status: .Success(html: data))
        }
    }
}