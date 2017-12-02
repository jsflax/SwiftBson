//
//  CodecRegistry.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A registry of Codec instances searchable by the class that the Codec can encode and decode.
 *
 * <p>While the {@code CodecRegistry} interface adds no stipulations to the general contract for the Object.equals,
 * programmers who implement the {@code CodecRegistry} interface "directly" must exercise care if they choose to override the
 * {@code Object.equals}. It is not necessary to do so, and the simplest course of action is to rely on Object's implementation, but the
 * implementer may wish to implement a "value comparison" in place of the default "reference comparison."</p>
 *
 * @since 3.0
 */
public protocol CodecRegistry {
    /**
     * Gets a {@code Codec} for the given Class.
     *
     * @param clazz the class
     * @param <T> the class type
     * @return a codec for the given class
     * @throws CodecConfigurationException if the registry does not contain a codec for the given class.
     */
    func get<T>(type: T.Type) throws -> BoxedCodec
}

//extension CodecRegistry {
//    func get<T>(instance: T) throws -> BoxedCodec {
//        return try get(type: type(of: instance))
//    }
//
//    func get<T>(_ proto: T) throws -> BoxedCodec {
//        return try get(type: proto.self)
//    }
//}

