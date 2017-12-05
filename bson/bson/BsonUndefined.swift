//
//  BsonUndefined.swift
//  bson
//
//  Created by Jason Flax on 11/27/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Represents the value associated with the BSON Undefined type.  All values of this type are identical.  Note that this type has been
 * deprecated in the BSON specification.
 *
 * @see <a href="http://bsonspec.org/spec.html">BSON Spec</a>
 * @see org.bson.BsonType#UNDEFINED
 * @since 3.0
 */
public final class BsonUndefined: BsonValue {
    public var bsonType: BsonType = .undefined

    public init() {}

    public required init(reader: BsonReader, decoderContext: DecoderContext) throws {
        try reader.readUndefined()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeUndefined()
    }
}

extension BsonUndefined: Equatable {
    public static func ==(lhs: BsonUndefined, rhs: BsonUndefined) -> Bool {
        return true
    }
}

extension BsonUndefined: Hashable {
    public var hashValue: Int { return 0 }
}
