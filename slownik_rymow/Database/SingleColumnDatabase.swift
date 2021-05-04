//
//  SingleColumnDatabase.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 12/01/2020.
//  Copyright © 2020 Michał Buczek. All rights reserved.
//

import Foundation
import SQLite

protocol SingleColumnDatabase {
  var connection: Connection? { get }
  var tableName: String { get }
  var columnName: String { get }
}
