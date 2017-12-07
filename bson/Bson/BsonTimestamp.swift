//
//  BsonTimestamp.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

infix operator >>> : BitwiseShiftPrecedence

func >>> (lhs: UInt64, rhs: UInt64) -> Int64 {
    return Int64(bitPattern: lhs >> rhs)
}

public class BsonTimestamp: BsonValue {
    public var bsonType: BsonType = .timestamp

    let value: UInt64

    /**
     * Construct a new instance with a null time and a 0 increment.
     */
    public init() {
        value = 0
    }

    /**
     * Construct a new instance for the given value, which combines the time in seconds and the increment as a single long value.
     *
     * @param value the timetamp as a single long value
     * @since 3.5
     */
    public init(value: UInt64) {
        self.value = value
    }

    /**
     * Construct a new instance for the given time and increment.
     *
     * @param seconds the number of seconds since the epoch
     * @param increment  the increment.
     */
    public init(seconds: UInt, increment: UInt) {
        self.value = UInt64((seconds << 32) | (increment & 0xFFFFFFFF))
    }


    public required init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.value = try reader.readTimestamp().value
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeTimestamp(value: self)
    }
    /**
     * Gets the time in seconds since epoch.
     *
     * @return an int representing time in seconds since epoch
     */
    public var time: UInt {
        return UInt(value >> 32)
    }

    /**
     * Gets the increment value.
     *
     * @return an incrementing ordinal for operations within a given second
     */
    public var inc: UInt {
        return UInt(value)
    }
}

extension BsonTimestamp: Equatable {
    public static func ==(lhs: BsonTimestamp, rhs: BsonTimestamp) -> Bool {
        return lhs.value == rhs.value
    }
}
extension BsonTimestamp: Comparable {
    public static func <(lhs: BsonTimestamp, rhs: BsonTimestamp) -> Bool {
        return lhs.value < rhs.value
    }
}

extension BsonTimestamp: Hashable {
    public var hashValue: Int {
        return Int(Int64(value) ^ (value >>> 32))
    }
}
