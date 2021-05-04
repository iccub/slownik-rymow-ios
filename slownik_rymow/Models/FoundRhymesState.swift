//
//  FoundRhymesState.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 26/07/2020.
//  Copyright © 2020 Michał Buczek. All rights reserved.
//

import Foundation

enum FoundRhymesState {
  /// Initial state, user hasn't tapped on search button yet.
  case initial
  /// At least 1 rhyme was found.
  case found(rhymes: [Rhyme])
  /// No rhymes were found.
  case noResults
}
