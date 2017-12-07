//
//  Code.swift
//  bson
//
//  Created by Jason Flax on 12/3/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * For using the Code type.
 */
public class Code: BsonCodable {
    public let code: String

    /**
     * Construct a new instance with the given code.
     *
     * @param code the Javascript code
     */
    public init(code: String) {
        self.code = code
    }

    public required init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.code = try reader.readJavaScript()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeJavaScript(code: self.code)
    }
}

extension Code: Hashable {
    public var hashValue: Int {
        return code.hashValue
    }

    public static func ==(lhs: Code, rhs: Code) -> Bool {
        return lhs.code == rhs.code
    }
}
