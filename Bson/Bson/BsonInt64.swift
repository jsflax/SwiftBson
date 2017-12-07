//
//  BsonInt64.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonInt64: BsonNumber {
    public var int32: Int32 { return Int32(self.value) }

    public var int64: Int64 { return self.value }

    public var double: Double { return Double(self.value) }

    public var decimal: Decimal { return Decimal(self.value) }

    public var bsonType: BsonType = .int64

    public let value: Int64

    init(value: Int64) {
        self.value = value
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.value = try reader.readInt64()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeInt64(value: self.value)
    }
}

extension BsonInt64: Equatable {
    public static func ==(lhs: BsonInt64, rhs: BsonInt64) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BsonInt64: Hashable {
    public var hashValue: Int {
        return Int(self.value)
    }
}

extension BsonInt64: Comparable {
    public static func <(lhs: BsonInt64, rhs: BsonInt64) -> Bool {
        return lhs.value < rhs.value
    }
}
