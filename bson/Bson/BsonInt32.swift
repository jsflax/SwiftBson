//
//  BsonInt32.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonInt32: BsonNumber {
    public var int32: Int32 { return self.value }

    public var int64: Int64 { return Int64(self.value) }

    public var double: Double { return Double(self.value) }

    public var decimal: Decimal { return Decimal(self.value) }

    public var bsonType: BsonType = .int32

    public let value: Int32

    init(value: Int32) {
        self.value = value
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.value = try reader.readInt32()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeInt32(value: self.value)
    }
}

extension BsonInt32: Equatable {
    public static func ==(lhs: BsonInt32, rhs: BsonInt32) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BsonInt32: Hashable {
    public var hashValue: Int {
        return Int(self.value)
    }
}

extension BsonInt32: Comparable {
    public static func <(lhs: BsonInt32, rhs: BsonInt32) -> Bool {
        return lhs.value < rhs.value
    }
}
