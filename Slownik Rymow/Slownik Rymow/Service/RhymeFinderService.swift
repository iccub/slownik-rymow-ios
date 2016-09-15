//
//  RhymesService.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation
import Alamofire

typealias JSON = [[String: String]]

enum RhymesServiceStatus {
    case success(json: [String])
    case failure(error: AppErrors)
}

struct RhymeFinderService {
    
    func getRhymes(_ word: String, sortMethod: String, rhymePrecision: String, rhymeLenght: Int, completion: @escaping (_ status: RhymesServiceStatus) -> Void) {
        let endPoint = "http://178.62.220.64/wbs/findRhymes.php"
        
        let params: [String: AnyObject] = ["rhyme_precision": rhymePrecision as AnyObject,
                      "sort_method": sortMethod as AnyObject,
                      "rhyme_length": rhymeLenght as AnyObject,
                      "search_word": word as AnyObject]
        
        
        
        Alamofire.request(endPoint, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseData {
            response in
            
            guard response.result.error == nil, let data = response.data else {
                completion(.failure(error: .networkError))
                return
            }
            
            let dataAsString = String(data: data, encoding: String.Encoding.utf8)
            guard dataAsString != "null" else {
                completion(.failure(error: .noRhymesFound))
                return
            }
            
            do {
                let foundRhymesJson = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! JSON
                
                var rhymeArray = [FoundRhyme]()
                for rhymeDictionary in foundRhymesJson {
                    if let rhyme = rhymeDictionary["word"] {
                        if rhyme != word {
                            rhymeArray.append(rhyme)
                        }
                    }
                }
                
                completion(.success(json: rhymeArray))
            } catch  {
                completion(.failure(error: .parseError))
            }
        }
    }
}
