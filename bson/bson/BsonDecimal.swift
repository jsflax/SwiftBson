//
//  BsonDecimal.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonDecimal: BsonNumber {
    public var int32: Int32 { return self.value.int32 }

    public var int64: Int64 { return self.value.int64 }

    public var double: Double { return self.value.double }

    public var decimal: Decimal { return self.value }

    public var bsonType: BsonType = .decimal128

    public let value: Decimal

    init(value: Decimal) {
        self.value = value
    }
}

extension BsonDecimal: Equatable {
    public static func ==(lhs: BsonDecimal, rhs: BsonDecimal) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BsonDecimal: Hashable {
    public var hashValue: Int {
        return Int(self.value.int32)
    }
}

extension BsonDecimal: Comparable {
    public static func <(lhs: BsonDecimal, rhs: BsonDecimal) -> Bool {
        return lhs.double < rhs.double
    }
}
