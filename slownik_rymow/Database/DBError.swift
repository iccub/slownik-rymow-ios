//
//  DBError.swift
//  Slownik Rymow
//
//  Created by Michał Buczek on 18.12.2016.
//  Copyright © 2019 Michał Buczek. All rights reserved.
//

import Foundation

enum DBError: Error {
  case datastoreConnectionError
  case sqlStatementError
}
