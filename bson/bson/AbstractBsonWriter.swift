//
//  AbstractBsonWriter.swift
//  bson
//
//  Created by Jason Flax on 11/29/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * The context for the writer. Records the parent context, creating a bread crumb trail to trace back up to the root context of the
 * reader. Also records the {@link org.bson.BsonContextType}, indicating whether the writer is reading a document, array, or other
 * complex sub-structure.
 */
public class WriterContext {
    public let parentContext: WriterContext?
    public let contextType: BsonContextType?
    public var name: String?

    /**
     * Creates a new instance, copying values from an existing context.
     *
     * @param from the {@code Context} to copy values from
     */
    public init(from context: WriterContext?) {
        self.parentContext = context?.parentContext
        self.contextType = context?.contextType
    }

    /**
     * Creates a new instance.
     *
     * @param parentContext the context of the parent node
     * @param contextType   the context type.
     */
    public init(parentContext: WriterContext?, contextType: BsonContextType) {
        self.parentContext = parentContext
        self.contextType = contextType
    }
}

public protocol AbstractBsonWriter: class, BsonWriter {
    var settings: BsonWriterSettings { get set }
    var fieldNameValidatorStack: Stack<FieldNameValidator> { get set }
    var state: State { get set }
    var context: WriterContext? { get }
    var serializationDepth: Int { get set }
    var isClosed: Bool { get }

    /**
     * Handles the logic to start writing a document
     */
    func doWriteStartDocument() throws

    /**
     * Handles the logic of writing the end of a document
     */
    func doWriteEndDocument() throws

    /**
     * Handles the logic to start writing an array
     */
    func doWriteStartArray() throws

    /**
     * Handles the logic of writing the end of an array
     */
    func doWriteEndArray() throws

    /**
     * Handles the logic of writing a {@code BsonBinary} value
     *
     * @param value the {@code BsonBinary} value to write
     */
    func doWriteBinaryData(value: BsonBinary) throws


    /**
     * Handles the logic of writing a boolean value
     *
     * @param value the {@code boolean} value to write
     */
    func doWriteBoolean(value: Bool) throws

    /**
     * Handles the logic of writing a date time value
     *
     * @param value the {@code long} value to write
     */
    func doWriteDateTime(value: Int64) throws

    /**
     * Handles the logic of writing a DbPointer value
     *
     * @param value the {@code BsonDbPointer} value to write
     */
    func doWriteDBPointer(value: BsonDbPointer) throws

    /**
     * Handles the logic of writing a Double value
     *
     * @param value the {@code double} value to write
     */
    func doWriteDouble(value: Double) throws

    /**
     * Handles the logic of writing an int32 value
     *
     * @param value the {@code int} value to write
     */
    func doWriteInt32(value: Int32) throws

    /**
     * Handles the logic of writing an int64 value
     *
     * @param value the {@code long} value to write
     */
    func doWriteInt64(value: Int64) throws

    /**
     * Handles the logic of writing a Decimal128 value
     *
     * @param value the {@code Decimal128} value to write
     * @since 3.4
     */
    func doWriteDecimal128(value: Decimal) throws

    /**
     * Handles the logic of writing a JavaScript function
     *
     * @param value the {@code String} value to write
     */
    func doWriteJavaScript(value: String) throws

    /**
     * Handles the logic of writing a scoped JavaScript function
     *
     * @param value the {@code boolean} value to write
     */
    func doWriteJavaScriptWithScope(value: String) throws

    /**
     * Handles the logic of writing a Max key
     */
    func doWriteMaxKey() throws

    /**
     * Handles the logic of writing a Min key
     */
    func doWriteMinKey() throws

    /**
     * Handles the logic of writing a Null value
     */
    func doWriteNull() throws

    /**
     * Handles the logic of writing an ObjectId
     *
     * @param value the {@code ObjectId} value to write
     */
    func doWriteObjectId(value: ObjectId) throws

    /**
     * Handles the logic of writing a regular expression
     *
     * @param value the {@code BsonRegularExpression} value to write
     */
    func doWriteRegularExpression(value: BsonRegularExpression) throws

    /**
     * Handles the logic of writing a String
     *
     * @param value the {@code String} value to write
     */
    func doWriteString(value: String) throws

    /**
     * Handles the logic of writing a Symbol
     *
     * @param value the {@code boolean} value to write
     */
    func doWriteSymbol(value: String) throws

    /**
     * Handles the logic of writing a timestamp
     *
     * @param value the {@code BsonTimestamp} value to write
     */
    func doWriteTimestamp(value: BsonTimestamp) throws

    /**
     * Handles the logic of writing an Undefined  value
     */
    func doWriteUndefined() throws
}

extension AbstractBsonWriter {

    public func writeStartDocument(name: String) throws {
        try writeName(name: name)
        try writeStartDocument()
    }

    public func writeStartDocument() throws {
        try checkPreconditions(validStates: .initial, .value, .scopeDocument, .done)
        guard let name = self.context?.name else {
            try throwInvalidState(validStates: .initial, .value, .scopeDocument, .done)
            return
        }
        self.fieldNameValidatorStack.push(
            fieldNameValidatorStack.peek().getValidator(forFieldName: name)
        )
        self.serializationDepth += 1
        if serializationDepth > settings.maxSerializationDepth {
            throw BSONError.serialization("Maximum serialization depth exceeded (does the object being "
                + "serialized have a circular reference?).")
        }

        try doWriteStartDocument()
        state = .name
    }


    public func writeEndDocument() throws {
        try checkPreconditions(validStates: .name)

        let contextType = context?.contextType
        if contextType != .document && contextType != .scopeDocument {
            try throwInvalidContextType(actualContextType: contextType!,
                                        validContextTypes: .document, .scopeDocument)
        }

        if (context?.parentContext != nil && context?.parentContext?.name != nil) {
            fieldNameValidatorStack.pop()
        }

        serializationDepth -= 1

        try doWriteEndDocument()

        if context != nil || context?.contextType == .topLevel {
            state = . done
        } else {
            state = nextState()
        }
    }


    public func writeStartArray(name: String) throws {
        try writeName(name: name)
        try writeStartArray()
    }


    public func writeStartArray() throws {
        try checkPreconditions(validStates: .value)

        if let name = context?.name {
            fieldNameValidatorStack.push(
                fieldNameValidatorStack.peek().getValidator(forFieldName: name)
            )
        }

        self.serializationDepth += 1
        if serializationDepth > settings.maxSerializationDepth {
            throw BSONError.serialization("Maximum serialization depth exceeded (does the object being "
                + "serialized have a circular reference?).")
        }

        try doWriteStartArray()
        self.state = .value
    }


    public func writeEndArray() throws {
        try checkPreconditions(validStates: .value)

        if context?.contextType != .array {
            try throwInvalidContextType(actualContextType: context!.contextType!,
                                        validContextTypes: .array)
        }

        if context?.parentContext?.name != nil {
            fieldNameValidatorStack.pop()
        }

        serializationDepth -= 1

        try doWriteEndArray()
        state = nextState()
    }


    public func writeBinaryData(name: String, binary: BsonBinary) throws {
        try writeName(name: name)
        try writeBinaryData(binary: binary)
    }

    public func writeBinaryData(binary: BsonBinary) throws {
        try checkPreconditions(validStates: .value, .initial)
        try doWriteBinaryData(value: binary)
        state = nextState()
    }


    public func writeBoolean(name: String, value: Bool) throws {
        try writeName(name: name)
        try writeBoolean(value: value)
    }


    public func writeBoolean(value: Bool) throws {
        try checkPreconditions(validStates: .value, .initial)
        try doWriteBoolean(value: value)
        state = nextState()
    }


    public func writeDateTime(name: String, value: Int64) throws {
        try writeName(name: name)
        try writeDateTime(value: value)
    }


    public func writeDateTime(value: Int64) throws {
        try checkPreconditions(validStates: .value, .initial)
        try doWriteDateTime(value: value)
        state = nextState()
    }


    public func writeDBPointer(name: String, value: BsonDbPointer) throws {
        try writeName(name: name)
        try writeDBPointer(value: value)
    }


    public func writeDBPointer(value: BsonDbPointer) throws {
        try checkPreconditions(validStates: .value, .initial)
        try doWriteDBPointer(value: value)
        state = nextState()
    }


    public func writeDouble(name: String, value: Double) throws {
        try writeName(name: name)
        try writeDouble(value: value)
    }


    public func writeDouble(value: Double) throws {
        try checkPreconditions(validStates: .value, .initial)
        try doWriteDouble(value: value)
        state = nextState()
    }


    public func writeInt32(name: String, value: Int32) throws {
        try writeName(name: name)
        try writeInt32(value: value)
    }


    public func writeInt32(value: Int32) throws {
        try checkPreconditions(validStates: .value)
        try doWriteInt32(value: value)
        state = nextState()
    }


    public func writeInt64(name: String, value: Int64) throws {
        try writeName(name: name)
        try writeInt64(value: value)
    }


    public func writeInt64(value: Int64) throws {
        try checkPreconditions(validStates: .value)
        try doWriteInt64(value: value)
        state = nextState()
    }


    public func writeDecimal128(value: Decimal) throws {
        try checkPreconditions(validStates: .value)
        try doWriteDecimal128(value: value)
        state = nextState()
    }


    public func writeDecimal128(name: String, value: Decimal) throws {
        try writeName(name: name)
        try writeDecimal128(value: value)
    }


    public func writeJavaScript(name: String, code: String) throws {
        try writeName(name: name)
        try writeJavaScript(code: code)
    }


    public func writeJavaScript(code: String) throws {
        try checkPreconditions(validStates: .value)
        try doWriteJavaScript(value: code)
        state = nextState()
    }


    public func writeJavaScriptWithScope(name: String, code: String) throws {
        try writeName(name: name)
        try writeJavaScriptWithScope(code: code)
    }


    public func writeJavaScriptWithScope(code: String) throws {
        try checkPreconditions(validStates: .value)
        try doWriteJavaScriptWithScope(value: code)
        state = .scopeDocument
    }


    public func writeMaxKey(name: String) throws {
        try writeName(name: name)
        try writeMaxKey()
    }


    public func writeMaxKey() throws {
        try checkPreconditions(validStates: .value)
        try doWriteMaxKey()
        state = nextState()
    }


    public func writeMinKey(name: String) throws {
        try writeName(name: name)
        try writeMinKey()
    }


    public func writeMinKey() throws {
        try checkPreconditions(validStates: .value)
        try doWriteMinKey()
        state = nextState()
    }


    public func writeName(name: String) throws {
        if (state != .name) {
            try throwInvalidState(validStates: .name)
        }
        if (!fieldNameValidatorStack.peek().validate(fieldName: name)) {
            throw RuntimeError.illegalArgument("Invalid BSON field name \(name)")
        }
        doWriteName(name: name)
        context?.name = name
        state = .value
    }

    /**
     * Handles the logic of writing the element name.
     *
     * @param name the name of the element
     * @since 3.5
     */
    internal func doWriteName(name: String) {
    }


    public func writeNull(name: String) throws {
        try writeName(name: name)
        try writeNull()
    }


    public func writeNull() throws {
        try checkPreconditions(validStates: .value)
        try doWriteNull()
        state = nextState()
    }


    public func writeObjectId(name: String, objectId: ObjectId) throws {
        try writeName(name: name)
        try writeObjectId(objectId: objectId)
    }


    public func writeObjectId(objectId: ObjectId) throws {
        try checkPreconditions(validStates: .value)
        try doWriteObjectId(value: objectId)
        state = nextState()
    }


    public func writeRegularExpression(name: String,
                                       regularExpression: BsonRegularExpression) throws {
        try writeName(name: name)
        try writeRegularExpression(regularExpression: regularExpression)
    }


    public func writeRegularExpression(regularExpression: BsonRegularExpression) throws {
        try checkPreconditions(validStates: .value)
        try doWriteRegularExpression(value: regularExpression)
        state = nextState()
    }


    public func writeString(name: String, value: String) throws {
        try writeName(name: name)
        try writeString(value: value)
    }


    public func writeString(value: String) throws {
        try checkPreconditions(validStates: .value)
        try doWriteString(value: value)
        state = nextState()
    }


    public func writeSymbol(name: String, value: String) throws {
        try writeName(name: name)
        try writeSymbol(value: value)
    }


    public func writeSymbol(value: String) throws {
        try checkPreconditions(validStates: .value)
        try doWriteSymbol(value: value)
        state = nextState()
    }


    public func writeTimestamp(name: String, value: BsonTimestamp) throws {
        try writeName(name: name)
        try writeTimestamp(value: value)
    }


    public func writeTimestamp(value: BsonTimestamp) throws {
        try checkPreconditions(validStates: .value)
        try doWriteTimestamp(value: value)
        state = nextState()
    }


    public func writeUndefined(name: String) throws {
        try writeName(name: name)
        try writeUndefined()
    }


    public func writeUndefined() throws {
        try checkPreconditions(validStates: .value)
        try doWriteUndefined()
        state = nextState()
    }

    /**
     * Returns the next valid state for this writer.  For example, transitions from {@link State#VALUE} to {@link State#NAME} once a value
     * is written.
     *
     * @return the next {@code State}
     */
    internal func nextState() -> State {
        if context?.contextType == .array {
            return .value
        } else {
            return .name
        }
    }

    internal func checkState(validStates: [State]) -> Bool {
        return validStates.contains(state)
    }

    /**
     * Checks if this writer's current state is in the list of given states.
     *
     * @param validStates an array of {@code State}s to compare this writer's state to.
     * @return true if this writer's state is in the given list.
     */
    internal func checkState(validStates: State...) -> Bool {
        return self.checkState(validStates: validStates)
    }

    /**
     * Checks the writer is in the correct state. If the writer's current state is in the list of given states, this method will complete
     * without exception.  Throws an {@link java.lang.IllegalStateException} if the writer is closed.  Throws BsonInvalidOperationException
     * if the method is trying to do something that is not permitted in the current state.
     *
     * @param methodName  the name of the method being performed that checks are being performed for
     * @param validStates the list of valid states for this operation
     * @see #throwInvalidState(String, org.bson.AbstractBsonWriter.State...)
     */
    func checkPreconditions(_ methodName: String = #function, validStates: State...) throws {
        if isClosed {
            throw RuntimeError.illegalState("BsonWriter is closed")
        }

        let (states) = validStates
        if !checkState(validStates: states) {
            try throwInvalidState(validStates: validStates)
        }
    }

    /**
     * Throws an InvalidOperationException when the method called is not valid for the current ContextType.
     *
     * @param methodName        The name of the method.
     * @param actualContextType The actual ContextType.
     * @param validContextTypes The valid ContextTypes.
     * @throws BsonInvalidOperationException when the method called is not valid for the current ContextType.
     */
    internal func throwInvalidContextType(_ methodName: String = #function,
                                          actualContextType: BsonContextType,
                                          validContextTypes: BsonContextType...) throws {
        let validContextTypesString = validContextTypes.join(separator: " or ")
        throw BSONError.invalidOperation(
            "\(methodName) can only be called when ContextType is \(validContextTypesString), "
            + "not when ContextType is \(actualContextType).")
    }

    /**
     * Throws a {@link BsonInvalidOperationException} when the method called is not valid for the current state.
     *
     * @param methodName  The name of the method.
     * @param validStates The valid states.
     * @throws BsonInvalidOperationException when the method called is not valid for the current state.
     */
    internal func throwInvalidState(_ methodName: String = #function,
                                    validStates: [State]) throws {
        if state == .initial || state == .scopeDocument || state == .done {
            if !methodName.starts(with: "end") && methodName != "writeName" { // NOPMD
                //NOPMD collapsing these if statements will not aid readability
                var typeName = methodName[methodName.startIndex...methodName.index(methodName.startIndex,
                                                                                   offsetBy: 5)]
                if typeName.starts(with: "start") {
                    typeName = typeName[0...5]
                }
                var article = "A"
                if ["A", "E", "I", "O", "U"].contains(typeName[0]) {
                    article = "An"
                }
                throw BSONError.invalidOperation(
                    "\(article) \(typeName) value cannot be written to the root level of a BSON document.")
            }
        }

        let validStatesString = validStates.join(separator: "or")
        throw BSONError.invalidOperation(
            "\(methodName) can only be called when State is \(validStatesString), not when State is \(state)")
    }

    /**
     * Throws a {@link BsonInvalidOperationException} when the method called is not valid for the current state.
     *
     * @param methodName  The name of the method.
     * @param validStates The valid states.
     * @throws BsonInvalidOperationException when the method called is not valid for the current state.
     */
    internal func throwInvalidState(_ methodName: String = #function,
                                    validStates: State...) throws {
        try self.throwInvalidState(methodName, validStates: validStates)
    }

    public func pipe(reader: BsonReader) throws {
        try reader.readStartDocument()
        try writeStartDocument()
        while try reader.readBsonType() != .endOfDocument {
            try writeName(name: reader.readName())
            try pipeValue(reader: reader)
        }
        try reader.readEndDocument()
        try writeEndDocument()
    }

    private func pipeDocument(reader: BsonReader) throws {
        try reader.readStartDocument()
        try writeStartDocument()
        while try reader.readBsonType() != .endOfDocument {
            try writeName(name: reader.readName())
            try pipeValue(reader: reader)
        }
        try reader.readEndDocument()
        try writeEndDocument()
    }

    private func pipeJavascriptWithScope(reader: BsonReader) throws {
        try writeJavaScriptWithScope(code: reader.readJavaScriptWithScope())
        try pipeDocument(reader: reader)
    }

    private func pipeValue(reader: BsonReader) throws {
        switch reader.currentBsonType {
        case .document: try pipeDocument(reader: reader)
        case .array: try pipeArray(reader: reader)
        case .double: try writeDouble(value: reader.readDouble())
        case .string: try writeString(value: reader.readString())
        case .binary: try writeBinaryData(binary: reader.readBinaryData())
        case .undefined:
            try reader.readUndefined()
            try writeUndefined()
        case .objectId: try writeObjectId(objectId: reader.readObjectId())
        case .boolean: try writeBoolean(value: reader.readBoolean())
        case .dateTime: try writeDateTime(value: reader.readDateTime())
        case .null:
            try reader.readNull()
            try writeNull()
        case .regularExpression: try writeRegularExpression(regularExpression: reader.readRegularExpression())
        case .javascript: try writeJavaScript(code: reader.readJavaScript())
        case .symbol: try writeSymbol(value: reader.readSymbol())
        case .javascriptWithScope: try pipeJavascriptWithScope(reader: reader)
        case .int32: try writeInt32(value: reader.readInt32())
        case .timestamp: try writeTimestamp(value: reader.readTimestamp())
        case .int64: try writeInt64(value: reader.readInt64())
        case .decimal128: try writeDecimal128(value: reader.readDecimal())
        case .minKey:
            try reader.readMinKey()
            try writeMinKey()
        case .dbPointer: try writeDBPointer(value: reader.readDBPointer())
        case .maxKey:
            try reader.readMaxKey()
            try writeMaxKey()
        default: throw RuntimeError.illegalArgument(
            "unhandled BSON type: \(reader.currentBsonType)")
        }
    }

    private func pipeDocument(value: BsonDocument) throws {
        try writeStartDocument()
        try value.forEach { cur in
            try writeName(name: cur.key)
            try pipeValue(value: cur.value)
        }
        try writeEndDocument()
    }

    private func pipeArray(reader: BsonReader) throws {
        try reader.readStartArray()
        try writeStartArray()
        while try reader.readBsonType() != .endOfDocument {
            try pipeValue(reader: reader)
        }
        try reader.readEndArray()
        try writeEndArray()
    }

    private func pipeArray(array: BsonArray) throws {
        try writeStartArray()
        try array.forEach { try pipeValue(value: $0) }
        try writeEndArray()
    }

    private func pipeJavascriptWithScope(javaScriptWithScope: BsonJavascriptWithScope) throws {
        try writeJavaScriptWithScope(code: javaScriptWithScope.code)
        try pipeDocument(value: javaScriptWithScope.scope)
    }

    private func pipeValue(value: BsonValue) throws {
        switch value.bsonType {
        case .document: try pipeDocument(value: value.asType())
        case .array: try pipeArray(array: value.asType())
        case .double: try writeDouble(value: value.asType(BsonDouble.self).value)
        case .string: try writeString(value: value.asType(BsonString.self).value)
        case .binary: try writeBinaryData(binary: value.asType())
        case .undefined: try writeUndefined()
        case .objectId: try writeObjectId(objectId: value.asType(BsonObjectId.self).value)
        case .boolean: try writeBoolean(value: value.asType(BsonBool.self).value)
        case .dateTime: try writeDateTime(value: value.asType(BsonDateTime.self).value)
        case .null: try writeNull()
        case .regularExpression: try writeRegularExpression(regularExpression: value.asType())
        case .javascript: try writeJavaScript(code: value.asType(BsonJavascript.self).code)
        case .symbol: try writeSymbol(value: value.asType(BsonSymbol.self).symbol)
        case .javascriptWithScope: try pipeJavascriptWithScope(javaScriptWithScope: value.asType())
        case .int32: try writeInt32(value: value.asType(BsonInt32.self).value)
        case .timestamp: try writeTimestamp(value: value.asType())
        case .int64: try writeInt64(value: value.asType(BsonInt64.self).value)
        case .decimal128: try writeDecimal128(value: value.asType(BsonDecimal.self).value)
        case .minKey: try writeMinKey()
        case .dbPointer: try writeDBPointer(value: value.asType(BsonDbPointer.self))
        case .maxKey: try writeMaxKey()
        default: throw RuntimeError.illegalArgument(
            "unhandled BSON type: \(value.bsonType)")
        }
    }
}
