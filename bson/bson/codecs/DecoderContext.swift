//
//  DecoderContext.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * The context for decoding values to BSON.
 *
 * @see org.bson.codecs.Decoder
 * @since 3.0
 */
public struct DecoderContext {
    private static let defaultContext = DecoderContext { _ in }

    /**
     * @return true if the discriminator has been checked
     */
    public var hasCheckedDiscriminator: Bool = false

    /**
     * Create a builder.
     *
     * @return the builder
     */
    typealias Builder = (inout DecoderContext) -> Void

    /**
     * Creates a child context and then deserializes using the reader.
     *
     * @param decoder the decoder to decode with
     * @param reader the reader to decode to
     * @param <T> the type of the decoder
     * @return the decoded value
     * @since 3.5
     */
    public func decodeWithChildContext<D: __Decoder__>(decoder: D,
                                                   reader: BsonReader) throws -> D.Decodee {
        return try decoder.decode(reader: reader, decoderContext: .defaultContext)
    }

    init(builder: Builder) {
        builder(&self)
    }
}
