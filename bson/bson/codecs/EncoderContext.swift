//
//  EncoderContext.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * The context for encoding values to BSON.
 *
 * @see org.bson.codecs.Encoder
 * @since 3.0
 */
public struct EncoderContext {
    public static let defaultContext = EncoderContext { _ in }

    public let isEncodingCollectibleDocument: Bool = false

    /**
     * Create a builder.
     *
     * @return the builder
     */
    typealias Builder = (inout EncoderContext) -> Void

    /**
     * Creates a child context based on this and serializes the value with it to the writer.
     *
     * @param encoder the encoder to encode value with
     * @param writer the writer to encode to
     * @param value the value to encode
     * @param <T> the type of the value
     */
    public func encodeWithChildContext(encoder: BoxedCodec,
                                       writer: BsonWriter,
                                       value: Any) throws {
        try encoder.encode(writer: writer, value: value, encoderContext: .defaultContext)
    }

    init(builder: Builder) {
        builder(&self)
    }
}
