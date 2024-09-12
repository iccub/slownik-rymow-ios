//
//  Rhyme.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 06/08/2019.
//  Copyright © 2019 Michał Buczek. All rights reserved.
//

import Foundation

public struct Rhyme: Identifiable {
  public var id: String
  public init(id: String) {
    self.id = id
  }
}
