//
//  BsonArrayCodec.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A codec for BsonArray instances.
 *
 * @since 3.0
 */
//public class BsonArrayCodec: Codec {
//    private static let defaultRegistry =
//        CodecRegistries.fromProviders(providers: BsonValueCodecProvider())
//    private let codecRegistry: CodecRegistry
//
//    init(codecRegistry: CodecRegistry = defaultRegistry) {
//        self.codecRegistry = codecRegistry
//    }
//
//    public func decode(reader: BsonReader, decoderContext: DecoderContext) throws -> BsonArray {
//        try reader.readStartArray()
//
//        var list = BsonArray()
//        while try reader.readBsonType() != .endOfDocument {
//            list.append(try readValue(reader: reader, decoderContext: decoderContext))
//        }
//
//        try reader.readEndArray();
//
//        return list
//    }
//
//    public func encode(writer: BsonWriter, value: BsonArray, encoderContext: EncoderContext) throws {
//        try writer.writeStartArray();
//
//        try value.forEach { val in
//            let codec: BoxedCodec = try codecRegistry.get(instance: val)
//            try encoderContext.encodeWithChildContext(encoder: codec,
//                                                      writer: writer,
//                                                      value: val)
//        }
//
//        try writer.writeEndArray()
//    }
//
//
//    /**
//     * This method may be overridden to change the behavior of reading the current value from the given {@code BsonReader}.  It is required
//     * that the value be fully consumed before returning.
//     *
//     * @param reader the read to read the value from
//     * @param decoderContext the decoder context
//     * @return the non-null value read from the reader
//     */
//    func readValue(reader: BsonReader, decoderContext: DecoderContext) throws -> BsonValue {
//        fatalError()
//        let type = BsonValueCodecProvider.get(bsonType: reader.currentBsonType)
//        let codec: BoxedCodec = try codecRegistry.get(type: type)
//
//        return try codec.decode(reader: reader, decoderContext: decoderContext)
//    }
//}

