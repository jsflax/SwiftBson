//
//  DecoderContext.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation


func > <T>(left: Any, right: T.Type) -> T? {
    return left as? T
}

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
    public var transformer: Transformer? = nil
    public var registry: CodableRegistry? = nil
    public var userInfo = [AnyHashable: Any]()
    
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
    public func decodeWithChildContext<D: BsonDecodable>(decoder: D,
                                                         reader: BsonReader) throws -> D {
        return try type(of: decoder).init(reader: reader, decoderContext: .defaultContext)
    }

    public func info<T>(forKey key: AnyHashable) throws -> T {
        guard let value = self.userInfo[key] as? T else {
            throw BSONError.unexpected(
                "DecoderContext.userInfo did not contain required key \(key)")
        }

        return value
    }

    public subscript<T>(key: AnyHashable) -> T? {
        guard let value = self.userInfo[key]
            as? T else {
            return nil
        }

        return value
    }

    init(builder: Builder) {
        builder(&self)
    }
}
