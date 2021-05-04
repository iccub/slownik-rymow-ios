//
//  FindRhymeDBHelper.swift
//  Slownik Rymow
//
//  Created by Michał Buczek on 18.12.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation
import Combine

class RhymeFinderModel: ObservableObject {
  @Published var searchPending = false
  @Published var foundRhymesState: FoundRhymesState = .initial
  
  private let repository = DBRepository()
  private var cancellable: AnyCancellable?
  
  deinit {
    cancellable?.cancel()
  }
  
  func findRhymes(with parameters: SearchParameters) {
    searchPending = true
    cancellable = repository.findRhymes(with: parameters)
      .replaceError(with: [])
      .receive(on: RunLoop.main)
      .sink { [self] in
        foundRhymesState = $0.isEmpty ? .noResults : .found(rhymes: $0)
        searchPending = false
      }
  }
}
