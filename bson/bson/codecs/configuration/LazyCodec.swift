////
////  LazyCodec.swift
////  bson
////
////  Created by Jason Flax on 11/23/17.
////  Copyright © 2017 mongodb. All rights reserved.
////
//
//import Foundation
//
class LazyCodec<T>: Codec {
    private let registry: CodecRegistry
    private lazy var wrapped: BoxedCodec? = try? registry.get(type: T.self)

    init(registry: CodecRegistry) {
        self.registry = registry
    }

    func encode(writer: BsonWriter, value: T, encoderContext: EncoderContext) throws {
        try wrapped?.encode(writer: writer, value: value, encoderContext: encoderContext)
    }

    func decode(reader: BsonReader, decoderContext: DecoderContext) throws -> T {
        return try (wrapped?.decode(reader: reader, decoderContext: decoderContext))!
    }
}


