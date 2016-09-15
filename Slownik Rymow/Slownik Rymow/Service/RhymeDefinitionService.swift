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
    case success(html: String)
    case failure(error: AppErrors)
}

struct RhymeDefinitionService {
    
    func getWordDefinitionHTML(_ word: String, completion: @escaping (_ status: RhymeDefinitionServiceStatus) -> Void) {        
        let escapedRhymeDefinitionURL = "http://sjp.pl//\(word)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        
        
        Alamofire.request(escapedRhymeDefinitionURL!, method: .get, encoding: URLEncoding.default).validate().responseString(encoding: String.Encoding.utf8) {
            response in
            
            guard response.result.error == nil, let data = response.result.value else {
                completion(.failure(error: .networkError))
                return
            }
            
            completion(.success(html: data))
        }
    }
}
