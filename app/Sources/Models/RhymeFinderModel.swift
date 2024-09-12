//
//  FindRhymeDBHelper.swift
//  Slownik Rymow
//
//  Created by Michał Buczek on 18.12.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation
import Combine

@MainActor
public class RhymeFinderModel: ObservableObject {
  @Published public var searchPending = false
  @Published public var foundRhymesState: FoundRhymesState = .initial
  
  private let repository = DBRepository()
  
  public init() { }
  
  public func findRhymes(with parameters: SearchParameters) {
    defer { searchPending = false }
    
    searchPending = true
    
    Task.init {
      do {
        let foundRhymes = try await repository.findRhymes(with: parameters)
        foundRhymesState = foundRhymes.isEmpty ? .noResults : .found(rhymes: foundRhymes)
      } catch {
        foundRhymesState = .noResults
      }
    }
  }
}
