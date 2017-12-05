//
//  BsonDateTime.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonDateTime: BsonValue {
    public var bsonType: BsonType = .dateTime

    public let value: Int64

    /**
     * Construct a new instance with the given code and scope.
     *
     * @param code the code
     * @param scope the scope
     */
    public init(value: Int64) {
        self.value = value
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.value = try reader.readDateTime()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeDateTime(value: self.value)
    }
}

extension BsonDateTime: Equatable {
    public static func ==(lhs: BsonDateTime, rhs: BsonDateTime) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BsonDateTime: Hashable {
    public var hashValue: Int {
        return value.hashValue
    }
}
