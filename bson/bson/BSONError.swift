//
//  BSONException.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

enum BSONError: Error {
    case unexpected(String)
    case invalidOperation(String)
    case invalidConversion(String)
    case serialization(String)
}
