//
//  BsonBool.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonBool: BsonValue {
    public static let yes = BsonBool(value: true)
    public static let no = BsonBool(value: false)

    public var bsonType: BsonType = .boolean

    public let value: Bool

    public init(value: Bool) {
        self.value = value
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.value = try reader.readBoolean()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeBoolean(value: value)
    }
}

extension BsonBool: Equatable {
    public static func ==(lhs: BsonBool, rhs: BsonBool) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BsonBool: Hashable {
    public var hashValue: Int {
        return value ? 0 : 1
    }
}

extension BsonBool: Comparable {
    public static func <(lhs: BsonBool, rhs: BsonBool) -> Bool {
        if lhs.value { return !rhs.value }
        else { return rhs.value }
    }
}
