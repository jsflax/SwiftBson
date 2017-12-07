//
//  Int32+Codable.swift
//
//  Created by Jason Flax on 12/5/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

extension Int32: BsonCodable {
    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self = try NumberCodableHelper.decodeInt32(reader: reader)
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeInt32(value: self)
    }
}
