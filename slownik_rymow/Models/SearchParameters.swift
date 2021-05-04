//
//  SearchParameters.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 12/01/2020.
//  Copyright © 2020 Michał Buczek. All rights reserved.
//

import Foundation

struct SearchParameters {
  let word: String
  let sortMethod: SortOrder
  let rhymePrecision: RhymePrecision
  let rhymeLenght: Int
  
  enum RhymePrecision: Int {
    case precise
    case nonPrecise
  }
  
  enum SortOrder: Int {
    case alphabetical
    case random
  }
}
