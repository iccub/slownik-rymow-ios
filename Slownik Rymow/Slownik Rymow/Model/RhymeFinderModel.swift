//
//  RhymeModel.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation

typealias FoundRhyme = String
typealias SearchParameters = (word: String, sortMethod: SortOrder, rhymePrecision: RhymePrecision, rhymeLenght: Int)

enum RhymePrecision {
    case precise
    case nonPrecise
}

enum SortOrder {
    case alphabetical
    case random
}
