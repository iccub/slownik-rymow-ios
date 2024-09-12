//
//  WordsDatabase.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 12/01/2020.
//  Copyright © 2020 Michał Buczek. All rights reserved.
//

import Foundation
import SQLite

struct WordsDatabase: SingleColumnDatabase {
  let connection: Connection?
  
  let tableName = "word_list_fts5"
  let columnName = "word"
  
  private let databaseName = "db-fts5"
  private let databaseExtension = "db"
  
  init() {
    guard let databasePath = Bundle.main.path(forResource: databaseName, ofType: databaseExtension) else {
      connection = nil
      return
    }
    
    connection = try? Connection(databasePath, readonly: true)
  }
}
