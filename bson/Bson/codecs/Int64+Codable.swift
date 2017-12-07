//
//  Int64+Codable.swift
//  bson
//
//  Created by Jason Flax on 12/5/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

extension Int64: BsonCodable {
    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self = try NumberCodableHelper.decodeInt64(reader: reader)
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeInt64(value: self)
    }
}
