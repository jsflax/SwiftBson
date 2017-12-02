//
//  BsonString.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonString: BsonValue {
    public var bsonType: BsonType = .string

    public let value: String

    /**
     * Construct a new instance with the given code and scope.
     *
     * @param code the code
     * @param scope the scope
     */
    public init(value: String) {
        self.value = value
    }
}

extension BsonString: Equatable {
    public static func ==(lhs: BsonString, rhs: BsonString) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BsonString: Hashable {
    public var hashValue: Int {
        return value.hashValue
    }
}
