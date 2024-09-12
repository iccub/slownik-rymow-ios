//
//  SearchParameters.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 12/01/2020.
//  Copyright © 2020 Michał Buczek. All rights reserved.
//

import Foundation

public struct SearchParameters {
  public let word: String
  public let sortMethod: SortOrder
  public let rhymePrecision: RhymePrecision
  public let rhymeLenght: Int
  
  public enum RhymePrecision: Int {
    case precise
    case nonPrecise
  }
  
  public enum SortOrder: Int {
    case alphabetical
    case random
  }
  
  public init(word: String, sortMethod: SortOrder, rhymePrecision: RhymePrecision, rhymeLenght: Int) {
    self.word = word
    self.sortMethod = sortMethod
    self.rhymePrecision = rhymePrecision
    self.rhymeLenght = rhymeLenght
  }
}
