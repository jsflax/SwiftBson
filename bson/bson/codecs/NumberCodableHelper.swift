//
//  NumberCodableHelper.swift
//  bson
//
//  Created by Jason Flax on 12/3/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

struct NumberCodableHelper {
    static func decodeInt(reader: BsonReader) throws -> Int32 {
        let intValue: Int32
        let bsonType = reader.currentBsonType
        switch bsonType {
        case .int32: intValue = try reader.readInt32()
        case .int64:
            let longValue = try reader.readInt64()
            guard longValue < Int32.max && longValue > Int32.min else {
                throw BSONError.invalidConversion(
                    "Could not convert \(longValue) to \(Int32.self) without losing precision")
            }
            intValue = Int32(longValue)
        case .double:
            let doubleValue = Int64(try reader.readDouble())
            guard doubleValue < Int32.max && doubleValue > Int32.min else {
                throw BSONError.invalidConversion(
                    "Could not convert \(doubleValue) to \(Int32.self) without losing precision")
            }
            intValue = Int32(doubleValue)
        default:
            throw BSONError.invalidOperation("Invalid numeric type, found: \(bsonType)")
        }
        return intValue
    }
}
