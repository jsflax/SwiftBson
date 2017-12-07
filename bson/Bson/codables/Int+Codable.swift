//
//  Int+Codable.swift
//  bson
//
//  Created by Jason Flax on 12/5/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

extension Int: BsonCodable {
    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self = try Int(NumberCodableHelper.decodeInt32(reader: reader))
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeInt32(value: Int32(self))
    }
}
