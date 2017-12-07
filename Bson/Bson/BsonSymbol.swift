//
//  BsonSymbol.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Class to hold a BSON symbol object, which is an interned string in Ruby
 *
 * @since 3.0
 */
public final class BsonSymbol: BsonValue {
    public var bsonType: BsonType = .symbol

    public let symbol: String

    /**
     * Construct a new instance with the given code and scope.
     *
     * @param code the code
     * @param scope the scope
     */
    public init(symbol: String) {
        self.symbol = symbol
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.symbol = try reader.readSymbol()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeSymbol(value: symbol)
    }
}

extension BsonSymbol: Equatable {
    public static func ==(lhs: BsonSymbol, rhs: BsonSymbol) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}

extension BsonSymbol: Hashable {
    public var hashValue: Int {
        return symbol.hashValue
    }
}
