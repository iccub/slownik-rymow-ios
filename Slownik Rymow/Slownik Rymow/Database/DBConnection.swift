//
//  DBConnection.swift
//  Slownik Rymow
//
//  Created by Michał Buczek on 18.12.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import Foundation
import SQLite

class DBConnection {
    static let shared = DBConnection()
    let connection: Connection?
    
    let databaseName = "word_list"
    let databaseExtension = "db"
    
    private init() {
        guard let databasePath = Bundle.main.path(forResource: databaseName, ofType: databaseExtension) else {
            connection = nil
            return
        }
        
        do {
            connection = try Connection(databasePath, readonly: true)
        } catch {
            connection = nil
        }
    }
}
