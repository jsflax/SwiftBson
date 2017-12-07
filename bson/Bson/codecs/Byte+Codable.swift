//
//  Byte+Codable.swift
//  bson
//
//  Created by Jason Flax on 12/3/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

extension Byte: BsonCodable {
    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        let value = try NumberCodableHelper.decodeInt32(reader: reader)
        if value < Byte.min || value > Byte.max {
            throw BSONError.invalidOperation("\(value) can not be converted into a Byte.")
        }
        self.init(value)
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeInt32(value: Int32(self))
    }
}
