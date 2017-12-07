//
//  CodeWithScope.swift
//  bson
//
//  Created by Jason Flax on 12/3/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A representation of the JavaScript Code with Scope BSON type.
 *
 * @since 3.0
 */
public class CodeWithScope: Code {
    public let scope: Document

    /**
     * Construct an instance.
     *
     * @param code the code
     * @param scope the scope
     */
    public init(code: String, scope: Document) {
        self.scope = scope
        super.init(code: code)
    }

    public required init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.scope = try Document(reader: reader, decoderContext: decoderContext)
        try super.init(code: reader.readJavaScriptWithScope())
    }

    public override func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeJavaScriptWithScope(code: self.code)
        try self.scope.encode(writer: writer, encoderContext: encoderContext)
    }
}

