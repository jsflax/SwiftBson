//
//  BsonDouble.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonDouble: BsonNumber {
    public var int32: Int32 { return Int32(self.value) }

    public var int64: Int64 { return Int64(self.value) }

    public var double: Double { return self.value }

    public var decimal: Decimal { return Decimal(self.value) }

    public var bsonType: BsonType = .double

    public let value: Double

    init(value: Double) {
        self.value = value
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.value = try reader.readDouble()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeDouble(value: self.value)
    }
}

extension BsonDouble: Equatable {
    public static func ==(lhs: BsonDouble, rhs: BsonDouble) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BsonDouble: Hashable {
    public var hashValue: Int {
        return Int(self.value)
    }
}

extension BsonDouble: Comparable {
    public static func <(lhs: BsonDouble, rhs: BsonDouble) -> Bool {
        return lhs.value < rhs.value
    }
}
