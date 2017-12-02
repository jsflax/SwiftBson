//
//  Encoder.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Instances of this class are capable of encoding an instance of the type parameter {@code T} into a BSON value.
 *
 * @param <T> the type that the instance can encode into BSON
 *
 * @since 3.0
 */
public protocol __Encoder__ {
    associatedtype Encodee
    /**
     * Encode an instance of the type parameter {@code T} into a BSON value.
     * @param writer the BSON writer to encode into
     * @param value the value to encode
     * @param encoderContext the encoder context
     */
    func encode(writer: BsonWriter, value: Encodee, encoderContext: EncoderContext) throws
}
