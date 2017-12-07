//
//  MaxKey.swift
//  bson
//
//  Created by Jason Flax on 11/27/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Represent the maximum key value regardless of the key's type
 */
public final class MaxKey: BsonCodable {
    public init() {
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        try reader.readMaxKey()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeMaxKey()
    }
}

extension MaxKey: Equatable {
    public static func ==(lhs: MaxKey, rhs: MaxKey) -> Bool {
        return true
    }
}

extension MaxKey: Hashable {
    public var hashValue: Int { return 0 }
}
