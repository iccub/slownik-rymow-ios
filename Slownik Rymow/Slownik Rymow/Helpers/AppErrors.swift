//
//  AppErrors.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation

enum AppErrors: Error {
    case notConnectedToNetworkError
    case networkError
    /** Thrown when found rhymes JSON are wrong or rhyme description was not properly parsed */
    case parseError
    /** Thrown if found rhymes list is empty or no rhyme definition is found */
    case noRhymesFound
    case noDefinitionsFound
}
