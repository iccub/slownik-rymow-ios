//
//  RhymeModel.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation

typealias FoundRhyme = String
typealias SearchParam = (segmentedControlIndex: Int, parameterValue: String)
typealias SearchParameters = (word: String, sortMethod: String, rhymePrecision: String, rhymeLenght: Int)

struct RhymePrecision {
    static let PreciseRhymes = SearchParam(segmentedControlIndex: 0, parameterValue: "D")
    static let NonPreciseRhymes = SearchParam(segmentedControlIndex: 1, parameterValue: "N")
}

struct SortOrder {
    static let Alphabetical = SearchParam(segmentedControlIndex: 0, parameterValue: "A")
    static let Random = SearchParam(segmentedControlIndex: 1, parameterValue: "R")
}