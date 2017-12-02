//
//  Codec.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Instances of this class are capable of encoding and decoding an instance of the type parameter {@code Mod} into a BSON value.
 *
 * @param <Mod> the type that the instance can encode into BSON
 *
 * @since 3.0
 */
public protocol Codec: __Decoder__, __Encoder__ {
}

final class AnyDecoder<D>: __Decoder__ {
    private let _decode: (_ reader: BsonReader, _ decoderContext: DecoderContext) throws -> D

    init<Concrete: __Decoder__>(_ concrete: Concrete) where Concrete.Decodee == D{
        _decode = concrete.decode
    }

    func decode(reader: BsonReader, decoderContext: DecoderContext) throws -> D {
        return try _decode(reader, decoderContext)
    }
}

final class AnyEncoder<E>: __Encoder__ {
    private let _encode: (_ writer: BsonWriter, _ value: E, _ encoderContext: EncoderContext) throws -> Void

    init<Concrete: __Encoder__>(_ concrete: Concrete) where Concrete.Encodee == E {
        _encode = concrete.encode
    }

    func encode(writer: BsonWriter, value: E, encoderContext: EncoderContext) throws {
        return try _encode(writer, value, encoderContext)
    }
}

protocol Initializable {
    init()
}

protocol InitializableWithRegistry {
    init(registry: CodecRegistry)
}

public final class BoxedCodec {
    private var _decode: (_ reader: BsonReader, _ decoderContext: DecoderContext) throws -> Any
    private var _encode: (_ writer: BsonWriter, _ value: Any, _ encoderContext: EncoderContext) throws -> Void

    public init<U: Codec>(_ concrete: U) {
        self._decode = concrete.decode
        self._encode = concrete.encode as! (BsonWriter, Any, EncoderContext) throws -> Void
    }

    public init<T>(_ registry: CodecRegistry, type: T.Type) throws {
        let codec = try registry.get(type: type)
        self._decode = codec.decode
        self._encode = codec.encode
    }

    public func decode<T>(reader: BsonReader, decoderContext: DecoderContext) throws -> T {
        return try _decode(reader, decoderContext) as! T
    }

    public func encode<T>(writer: BsonWriter, value: T, encoderContext: EncoderContext) throws {
        return try _encode(writer, value, encoderContext)
    }
}

public final class AnyCodec<T>: Codec {
    private var _decode: (_ reader: BsonReader, _ decoderContext: DecoderContext) throws -> T
    private var _encode: (_ writer: BsonWriter, _ value: T, _ encoderContext: EncoderContext) throws -> Void

    public required init<U: Codec>(_ concrete: U) where U.Decodee == T, U.Encodee == T {
        _decode = concrete.decode
        _encode = concrete.encode
    }

    public func decode(reader: BsonReader, decoderContext: DecoderContext) throws -> T {
        return try _decode(reader, decoderContext)
    }

    public func encode(writer: BsonWriter, value: T, encoderContext: EncoderContext) throws {
        return try _encode(writer, value, encoderContext)
    }
}
