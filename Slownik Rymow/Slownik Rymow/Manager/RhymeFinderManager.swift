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
    func findRhymes(with parameters: SearchParameters, completion: @escaping (_ status: RhymeFinderManagerStatus) -> Void) {
        
        let findRhymeDataHelper = FindRhymeDataHelper()
        
        do {
            let foundRhymes = try findRhymeDataHelper.findRhymes(with: parameters)
            completion(.success(foundRhymesList: foundRhymes))
            
            if foundRhymes.isEmpty {
                completion(.failure(error: .noRhymesFound))
            }
            
        } catch {
            completion(.failure(error: .sqlError))
        }
    }
}
