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
    case sqlError
    /** Thrown when rhyme description was not properly parsed */
    case parseError
    case noRhymesFound
    case noDefinitionsFound
}
