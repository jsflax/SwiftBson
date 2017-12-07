//
//  BsonMaxKey.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonMaxKey: BsonValue, Hashable {
    public var hashValue: Int = 0

    public static func ==(lhs: BsonMaxKey, rhs: BsonMaxKey) -> Bool {
        return true
    }

    public var bsonType: BsonType = .maxKey

    public init() {}
    
    public required init(reader: BsonReader, decoderContext: DecoderContext) throws {
        try reader.readMaxKey()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeMaxKey()
    }
}
