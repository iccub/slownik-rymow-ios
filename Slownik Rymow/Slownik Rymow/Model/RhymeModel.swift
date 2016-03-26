//
//  RhymeModel.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias FoundRhyme = String

enum RhymesModelStatus {
    case Success(foundRhymesList: [FoundRhyme])
    case Failure(error: AppErrors)
}

struct RhymeModel {
    
    static func getRhymesWithParameters(parameters: SearchParameters, completion: (status: RhymesModelStatus) -> Void) {
        guard Reachability.isConnectedToNetwork() else {
            completion(status: .Failure(error: .NotConnectedToNetworkError))
            return
        }
        
        RhymesService.getRhymes(parameters.word, sortMethod: parameters.sortMethod, rhymePrecision: parameters.rhymePrecision, rhymeLenght: parameters.rhymeLenght) {
            status in
            
            switch status {
            case .Failure(let error):
                completion(status: .Failure(error: error))
            case .Success(let json):
                var foundRhymesArray = [FoundRhyme]()
                
                for (_, subJson):(String, JSON) in json {
                    if let word = subJson["word"].string {
                        foundRhymesArray.append(word)
                    }
                }
                
                completion(status: .Success(foundRhymesList: foundRhymesArray))
            }
        }
    }
}
