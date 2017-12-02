//
//  BsonMinKey.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonMinKey: BsonValue, Hashable {
    public var hashValue: Int = 0

    public static func ==(lhs: BsonMinKey, rhs: BsonMinKey) -> Bool {
        return true
    }

    public var bsonType: BsonType = .minKey
}
