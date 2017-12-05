//
//  Bool+Codable.swift
//  bson
//
//  Created by Jason Flax on 12/3/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

extension Bool: BsonCodable {
    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.init(try reader.readBoolean())
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeBoolean(value: self)
    }
}
