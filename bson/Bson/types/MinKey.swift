//
//  MinKey.swift
//  bson
//
//  Created by Jason Flax on 11/27/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Represent the minimum key value regardless of the key's type
 */
public final class MinKey: BsonCodable {
    public init() {
    }
    
    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        try reader.readMinKey()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeMinKey()
    }
}

extension MinKey: Equatable {
    public static func ==(lhs: MinKey, rhs: MinKey) -> Bool {
        return true
    }
}

extension MinKey: Hashable {
    public var hashValue: Int { return 0 }
}

