//
//  RhymeFinderManager.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 26.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation
import Alamofire

enum RhymeFinderManagerStatus {
    case success(foundRhymesList: [FoundRhyme])
    case failure(error: AppErrors)
}

struct RhymeFinderManager {
    
    let rhymeFinderService: RhymeFinderService
    
    init(rhymesService: RhymeFinderService = RhymeFinderService()) {
        self.rhymeFinderService = rhymesService
    }
    
    func getRhymesWithParameters(_ parameters: SearchParameters, completion: @escaping (_ status: RhymeFinderManagerStatus) -> Void) {
        guard Reachability.isConnectedToNetwork() else {
            completion(.failure(error: .notConnectedToNetworkError))
            return
        }
        
        rhymeFinderService.getRhymes(parameters.word, sortMethod: parameters.sortMethod, rhymePrecision: parameters.rhymePrecision, rhymeLenght: parameters.rhymeLenght) {
            status in
            
            switch status {
            case .failure(let error):
                completion(.failure(error: error))
            case .success(let json):
                var foundRhymesArray = [FoundRhyme]()
                
                
                for word in json {
                    foundRhymesArray.append(word)
                }
                
                completion(.success(foundRhymesList: foundRhymesArray))
            }
        }
    }
}
