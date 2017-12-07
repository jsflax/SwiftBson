//
//  BsonJavascript.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonJavascript: BsonValue {
    public var bsonType: BsonType = .javascript

    public let code: String

    /**
     * Construct a new instance with the given code and scope.
     *
     * @param code the code
     * @param scope the scope
     */
    public init(code: String) {
        self.code = code
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.code = try reader.readJavaScript()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeJavaScript(code: self.code)
    }
}

extension BsonJavascript: Equatable {
    public static func ==(lhs: BsonJavascript, rhs: BsonJavascript) -> Bool {
        return lhs.code == rhs.code
    }
}

extension BsonJavascript: Hashable {
    public var hashValue: Int {
        return code.hashValue
    }
}
