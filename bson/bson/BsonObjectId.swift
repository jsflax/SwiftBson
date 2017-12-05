//
//  BsonObjectId.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A representation of the BSON ObjectId type.
 *
 * @since 3.0
 */
public final class BsonObjectId: BsonValue {
    public var bsonType: BsonType = .objectId

    public let value: ObjectId

    /**
     * Construct a new instance with the given code and scope.
     *
     * @param code the code
     * @param scope the scope
     */
    public init(value: ObjectId) {
        self.value = value
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.value = try reader.readObjectId()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeObjectId(objectId: self.value)
    }
}

extension BsonObjectId: Equatable {
    public static func ==(lhs: BsonObjectId, rhs: BsonObjectId) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BsonObjectId: Hashable {
    public var hashValue: Int {
        return value.hashValue
    }
}
