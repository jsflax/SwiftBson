//
//  BsonJavascriptWithScope.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonJavascriptWithScope: BsonValue {
    public var bsonType: BsonType = .javascriptWithScope

    public let code: String
    public let scope: BsonDocument

    /**
     * Construct a new instance with the given code and scope.
     *
     * @param code the code
     * @param scope the scope
     */
    public init(code: String, scope: BsonDocument) {
        self.code = code
        self.scope = scope
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.code = try reader.readJavaScriptWithScope()
        self.scope = try BsonDocument.init(reader: reader, decoderContext: decoderContext)
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeJavaScriptWithScope(code: self.code)
        try self.scope.encode(writer: writer, encoderContext: encoderContext)
    }
}

extension BsonJavascriptWithScope: Equatable {
    public static func ==(lhs: BsonJavascriptWithScope, rhs: BsonJavascriptWithScope) -> Bool {
        return lhs.code == rhs.code && lhs.scope == rhs.scope
    }
}

extension BsonJavascriptWithScope: Hashable {
    public var hashValue: Int {
        var result = code.hashValue
        result = 31 * result + scope.hashValue
        return result
    }
}
