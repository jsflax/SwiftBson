//
//  BsonNull.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonNull: BsonValue, Hashable {
    public static let value = BsonNull()
    
    public static func ==(lhs: BsonNull, rhs: BsonNull) -> Bool {
        return true
    }

    public var bsonType: BsonType = .null

    public var hashValue: Int = 0
}
