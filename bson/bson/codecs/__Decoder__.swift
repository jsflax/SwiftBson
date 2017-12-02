//
//  Decoder.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Decoders are used for reading BSON types from MongoDB and converting them into Swift objects.
 *
 * @param <T> the type to decode into, the return type of the {@link #decode(org.bson.BsonReader, DecoderContext)} method.
 * @since 3.0
 */
public protocol __Decoder__ {
    associatedtype Decodee
    /**
     * Decodes a BSON value from the given reader into an instance of the type parameter {@code T}.
     *
     * @param reader         the BSON reader
     * @param decoderContext the decoder context
     * @return an instance of the type parameter {@code T}.
     */
    func decode(reader: BsonReader, decoderContext: DecoderContext) throws -> Decodee
}
