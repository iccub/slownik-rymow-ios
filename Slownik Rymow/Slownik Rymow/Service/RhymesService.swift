//
//  RhymesService.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum RhymesServiceStatus {
    case Success(json: JSON)
    case Failure(error: AppErrors)
}

struct RhymesService {
    
    static func getRhymes(word: String, sortMethod: String, rhymePrecision: String, rhymeLenght: Int, completion: (status: RhymesServiceStatus) -> Void) {
        let endPoint = "http://178.62.220.64/wbs/findRhymes.php"
        
        let params: [String: AnyObject] = ["rhyme_precision": rhymePrecision,
                      "sort_method": sortMethod,
                      "rhyme_length": rhymeLenght,
                      "search_word": word]
        
        Alamofire.request(.POST, endPoint, parameters: params, encoding: .URL).validate().responseJSON() { response in
            
            guard response.result.error == nil, let data = response.result.value else {
                completion(status: .Failure(error: .NetworkError))
                return
            }
            
            let json = JSON(data)
            
            guard !json.isEmpty else {
                completion(status: .Failure(error: .EmptyResults))
                return
            }
            
            guard json.error == nil else {
                completion(status: .Failure(error: AppErrors.ParseError))
                return
            }
            
            completion(status: .Success(json: json))
        }
    }
}