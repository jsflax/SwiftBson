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
    public var transformer: Transformer? = nil
    public var isEncodingCollectibleDocument: Bool = false
    public var registry: CodableRegistry? = nil
    public var userInfo = [AnyHashable: Any]()

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
    public func encodeWithChildContext(encoder: BsonEncodable,
                                       writer: BsonWriter) throws {
        try encoder.encode(writer: writer, encoderContext: .defaultContext)
    }

    init(builder: Builder) {
        builder(&self)
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
}
