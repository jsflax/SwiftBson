//
//  BsonRegularExpression.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public class BsonRegularExpression: BsonValue {
    public var bsonType: BsonType = .regularExpression

    let pattern: String
    let options: String

    /**
     * Creates a new instance
     *
     * @param pattern the regular expression {@link java.util.regex.Pattern}
     * @param options the options for the regular expression
     */
    public init(pattern: String, options: String = "") {
        self.pattern = pattern
        self.options = String(options.sorted())
    }

    public required init(reader: BsonReader, decoderContext: DecoderContext) throws {
        let regex = try reader.readRegularExpression()
        self.pattern = regex.pattern
        self.options = regex.options
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeRegularExpression(regularExpression: self)
    }
}

extension BsonRegularExpression: Equatable {
    public static func ==(lhs: BsonRegularExpression, rhs: BsonRegularExpression) -> Bool {
        if lhs.options != rhs.options {
            return false
        }
        if lhs.pattern != rhs.pattern {
            return false
        }

        return true
    }
}

extension BsonRegularExpression: Hashable {
    public var hashValue: Int {
        var result = pattern.hashValue
        result = 31 * result + options.hashValue
        return result
    }
}
