//
//  ArrayCodec.swift
//  bson
//
//  Created by Jason Flax on 12/2/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

extension Array: BsonCodable {
    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        try reader.readStartArray();

        self.init([Element]())

        while try reader.readBsonType() != .endOfDocument {
            try self.append(readValue(reader: reader, decoderContext: decoderContext)!)
        }

        try reader.readEndArray()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeStartArray()
        for cur in self {
            try writeValue(writer: writer, encoderContext: encoderContext, value: cur)
        }
        try writer.writeEndArray()
    }

    private func writeValue(writer: BsonWriter, encoderContext: EncoderContext, value: Element?) throws {
        if value == nil {
            try writer.writeNull()
        } else {
            guard let val = value as? BsonEncodable else {
                throw BSONError.serialization(
                    "Value does not implement BsonEncodable: \(String(describing: value))")
            }
            try encoderContext.encodeWithChildContext(encoder: val, writer: writer);
        }
    }

    private func readValue(reader: BsonReader, decoderContext: DecoderContext) throws -> Element? {
        let bsonType = reader.currentBsonType
        if bsonType == .null {
            try reader.readNull()
            return nil
        } else if try (bsonType == .binary &&
                BsonBinarySubType.isUuid(value: reader.peekBinarySubType()) &&
                reader.peekBinarySize() == 16) {
            return nil
            //return registry.get(UUID.class).decode(reader, decoderContext);
        }
        return nil//return valueTransformer.transform(bsonTypeCodecMap.get(bsonType).decode(reader, decoderContext));
    }
}
