//
//  BsonInt64Codec.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public class BsonInt64Codec: Codec {
    public func decode(reader: BsonReader, decoderContext: DecoderContext) throws -> BsonInt64 {
        return try BsonInt64(value: reader.readInt64())
    }

    public func encode(writer: BsonWriter, value: BsonInt64, encoderContext: EncoderContext) throws {
        try writer.writeInt64(value: value.value)
    }
}
