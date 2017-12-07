//
//  BsonDbPointer.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public class BsonDbPointer: BsonValue {
    public var bsonType: BsonType = .dbPointer


    let namespace: String
    let id: ObjectId

    /**
     * Construct a new instance with the given namespace and id.
     *
     * @param namespace the namespace
     * @param id the id
     */
    public init(namespace: String, id: ObjectId) {
        self.namespace = namespace
        self.id = id
    }

    public required init(reader: BsonReader, decoderContext: DecoderContext) throws {
        let dbPointer = try reader.readDBPointer()
        self.namespace = dbPointer.namespace
        self.id = dbPointer.id
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeDBPointer(value: self)
    }
}

extension BsonDbPointer: Equatable {
    public static func ==(lhs: BsonDbPointer, rhs: BsonDbPointer) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        if lhs.namespace != rhs.namespace {
            return false
        }

        return true
    }
}

extension BsonDbPointer: Hashable {
    public var hashValue: Int {
        var result = namespace.hashValue
        result = 31 * result + id.hashValue
        return result
    }


}
