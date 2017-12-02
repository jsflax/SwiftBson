//
//  AbstractBsonReader.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * The state of a reader.  Indicates where in a document the reader is.
 */
public enum State {
    /**
     * The initial state.
     */
    case initial,

    /**
     * The reader is positioned at the type of an element or value.
     */
    type,

    /**
     * The reader is positioned at the name of an element.
     */
    name,

    /**
     * The reader is positioned at a value.
     */
    value,

    /**
     * The reader is positioned at a scope document.
     */
    scopeDocument,

    /**
     * The reader is positioned at the end of a document.
     */
    endOfDocument,

    /**
     * The reader is positioned at the end of an array.
     */
    endOfArray,

    /**
     * The reader has finished reading a document.
     */
    done,

    /**
     * The reader is closed.
     */
    closed
}
/**
 * The context for the reader. Records the parent context, creating a bread crumb trail to trace back up to the root context of the
 * reader. Also records the {@link org.bson.BsonContextType}, indicating whether the reader is reading a document, array, or other
 * complex sub-structure.
 */
public protocol Context {
    var parentContext: Context? { get }
    var contextType: BsonContextType { get }
}

class Mark: BsonReaderMark {
    private let state: State
    let parentContext: Context?
    let contextType: BsonContextType
    private let currentBsonType: BsonType
    private let currentName: String

    private var abstractBsonReader: AbstractBsonReader

    init(abstractBsonReader: inout AbstractBsonReader) {
        self.abstractBsonReader = abstractBsonReader
        self.state = abstractBsonReader.state
        self.parentContext = abstractBsonReader.context.parentContext
        self.contextType = abstractBsonReader.context.contextType
        self.currentBsonType = abstractBsonReader.currentBsonType
        self.currentName = abstractBsonReader.currentName
    }

    public func reset() {
        abstractBsonReader.state = state
        abstractBsonReader.currentBsonType = currentBsonType
        abstractBsonReader.currentName = currentName
    }
}

public protocol AbstractBsonReader: class, BsonReader {
    var state: State { get set }
    var context: Context { get }
    var currentBsonType: BsonType { get set }
    var currentName: String { get set }
    var isClosed: Bool { get set }

    /**
     * Handles the logic to read binary data
     *
     * @return the BsonBinary value
     */
    func doReadBinaryData() -> BsonBinary

    /**
     * Handles the logic to peek at the binary subtype.
     *
     * @return the binary subtype
     */
    func doPeekBinarySubType() -> Byte

    /**
     * Handles the logic to peek at the binary size.
     *
     * @return the binary size
     * @since 3.4
     */
    func doPeekBinarySize() -> Int

    /**
     * Handles the logic to read booleans
     *
     * @return the boolean value
     */
    func doReadBoolean() -> Bool

    /**
     * Handles the logic to read date time
     *
     * @return the long value
     */
    func doReadDateTime() -> Int64

    /**
     * Handles the logic to read doubles
     *
     * @return the double value
     */
    func doReadDouble() -> Double

    /**
     * Handles the logic when reading the end of an array
     */
    func doReadEndArray() throws

    /**
     * Handles the logic when reading the end of a document
     */
    func doReadEndDocument() throws

    /**
     * Handles the logic to read 32 bit ints
     *
     * @return the int value
     */
    func doReadInt32() -> Int32

    /**
     * Handles the logic to read 64 bit ints
     *
     * @return the long value
     */
    func doReadInt64() -> Int64


    /**
     * Handles the logic to read Decimal128
     *
     * @return the Decimal128 value
     * @since 3.4
     */
    func doReadDecimal() -> Decimal

    /**
     * Handles the logic to read Javascript functions
     *
     * @return the String value
     */
    func doReadJavaScript() -> String

    /**
     * Handles the logic to read scoped Javascript functions
     *
     * @return the String value
     */
    func doReadJavaScriptWithScope() -> String

    /**
     * Handles the logic to read a Max key
     */
    func doReadMaxKey()

    /**
     * Handles the logic to read a Min key
     */
    func doReadMinKey()

    /**
     * Handles the logic to read a null value
     */
    func doReadNull()

    /**
     * Handles the logic to read an ObjectId
     *
     * @return the ObjectId value
     */
    func doReadObjectId() -> ObjectId

    /**
     * Handles the logic to read a regular expression
     *
     * @return the BsonRegularExpression value
     */
    func doReadRegularExpression() -> BsonRegularExpression

    /**
     * Handles the logic to read a DBPointer
     *
     * @return the BsonDbPointer value
     */
    func doReadDBPointer() -> BsonDbPointer

    /**
     * Handles the logic to read the start of an array
     */
    func doReadStartArray()

    /**
     * Handles the logic to read the start of a document
     */
    func doReadStartDocument()

    /**
     * Handles the logic to read a String
     *
     * @return the String value
     */
    func doReadString() -> String

    /**
     * Handles the logic to read a Symbol
     *
     * @return the String value
     */
    func doReadSymbol() -> String

    /**
     * Handles the logic to read a timestamp
     *
     * @return the BsonTimestamp value
     */
    func doReadTimestamp() -> BsonTimestamp

    /**
     * Handles the logic to read an Undefined value
     */
    func doReadUndefined()

    /**
     * Handles any logic required to skip the name (reader must be positioned on a name).
     */
    func doSkipName() throws

    /**
     * Handles any logic required to skip the value (reader must be positioned on a value).
     */
    func doSkipValue() throws

    func close()
}

extension AbstractBsonReader {
    /**
     * Closes the reader.
     */
    public func close() {
        isClosed = true
    }

    public func currentName() throws -> String {
        if state != .value {
            try throwInvalidState(validStates: .value)
        }
        return currentName
    }

    @discardableResult
    public func readBinaryData() throws -> BsonBinary {
        try checkPreconditions(.binary)
        state = try nextState()
        return doReadBinaryData()
    }

    public func peekBinarySubType() throws -> Byte {
        try checkPreconditions(.binary)
        return doPeekBinarySubType()
    }

    public func peekBinarySize() throws -> Int {
        try checkPreconditions(.binary)
        return doPeekBinarySize();
    }

    @discardableResult
    public func readBoolean() throws -> Bool {
        try checkPreconditions(.boolean)
        state = try nextState()
        return doReadBoolean()
    }

    @discardableResult
    public func readDateTime() throws -> Int64 {
        try checkPreconditions(.dateTime)
        state = try nextState()
        return doReadDateTime()
    }

    @discardableResult
    public func readDouble() throws -> Double {
        try checkPreconditions(.double)
        state = try nextState()
        return doReadDouble()
    }

    public func readEndArray() throws {
        if isClosed {
            throw RuntimeError.illegalState("BSONBinaryWriter");
        }
        if context.contextType != .array {
            try throwInvalidContextType(actualContextType: context.contextType,
                                        validContextTypes: .array)
        }
        if state == .type {
            try readBsonType() // will set state to EndOfArray if at end of array
        }
        if state != .endOfArray {
            try throwInvalidState(validStates: .endOfArray)
        }

        try doReadEndArray()

        try setStateOnEnd()
    }

    public func readEndDocument() throws {
        if isClosed {
            throw RuntimeError.illegalState("BSONBinaryWriter");
        }
        if context.contextType != .document && context.contextType != .scopeDocument {
            try throwInvalidContextType(actualContextType: context.contextType,
                                        validContextTypes: .document, .scopeDocument)
        }
        if state == .type {
            try readBsonType() // will set state to EndOfDocument if at end of document
        }
        if state != .endOfDocument {
            try throwInvalidState(validStates: .endOfDocument)
        }

        try doReadEndDocument()

        try setStateOnEnd()
    }

    @discardableResult
    public func readInt32() throws -> Int32 {
        try checkPreconditions(.int32)
        state = try nextState()
        return doReadInt32()
    }

    @discardableResult
    public func readInt64() throws -> Int64 {
        try checkPreconditions(.int64)
        state = try nextState()
        return doReadInt64()
    }

    @discardableResult
    public func readDecimal() throws -> Decimal {
        try checkPreconditions(.decimal128)
        state = try nextState()
        return doReadDecimal()
    }

    @discardableResult
    public func readJavaScript() throws -> String {
        try checkPreconditions(.javascript)
        state = try nextState()
        return doReadJavaScript()
    }

    @discardableResult
    public func readJavaScriptWithScope() throws -> String {
        try checkPreconditions(.javascriptWithScope)
        state = .scopeDocument
        return doReadJavaScriptWithScope()
    }

    public func readMaxKey() throws {
        try checkPreconditions(.maxKey)
        state = try nextState()
        doReadMaxKey()
    }

    public func readMinKey() throws {
        try checkPreconditions(.minKey)
        state = try nextState()
        doReadMinKey()
    }

    public func readNull() throws {
        try checkPreconditions(.null)
        state = try nextState()
        doReadNull()
    }

    @discardableResult
    public func readObjectId() throws -> ObjectId {
        try checkPreconditions(.objectId)
        state = try nextState()
        return doReadObjectId()
    }

    @discardableResult
    public func readRegularExpression() throws -> BsonRegularExpression {
        try checkPreconditions(.regularExpression)
        state = try nextState()
        return doReadRegularExpression()
    }

    @discardableResult
    public func readDBPointer() throws -> BsonDbPointer {
        try checkPreconditions(.dbPointer)
        state = try nextState()
        return doReadDBPointer()
    }

    public func readStartArray() throws {
        try checkPreconditions(.array)
        doReadStartArray()
        state = .type
    }

    public func readStartDocument() throws {
        try checkPreconditions(.document)
        doReadStartDocument()
        state = .type
    }

    @discardableResult
    public func readString() throws -> String {
        try checkPreconditions(.string)
        state = try nextState()
        return doReadString()
    }

    @discardableResult
    public func readSymbol() throws -> String {
        try checkPreconditions(.symbol)
        state = try nextState()
        return doReadSymbol()
    }

    @discardableResult
    public func readTimestamp() throws -> BsonTimestamp {
        try checkPreconditions(.timestamp)
        state = try nextState()
        return doReadTimestamp()
    }

    public func readUndefined() throws {
        try checkPreconditions(.undefined)
        state = try nextState()
        doReadUndefined()
    }

    public func skipName() throws {
        if isClosed {
            throw RuntimeError.illegalState("This instance has been closed")
        }
        if state != .name {
            try throwInvalidState(validStates: .name)
        }
        state = .value
        try doSkipName()
    }

    public func skipValue() throws {
        if isClosed {
            throw RuntimeError.illegalState("BSONBinaryWriter")
        }
        if state != .value {
            try throwInvalidState(validStates: .value)
        }

        try doSkipValue()

        state = .type
    }

    public func readBinaryData(name: String) throws -> BsonBinary {
        try verifyName(expectedName: name)
        return try readBinaryData()
    }

    public func readBoolean(name: String) throws -> Bool {
        try verifyName(expectedName: name)
        return try readBoolean()
    }

    public func readDateTime(name: String) throws -> Int64 {
        try verifyName(expectedName: name)
        return try readDateTime()
    }

    public func readDouble(name: String) throws -> Double {
        try verifyName(expectedName: name)
        return try readDouble()
    }

    public func readInt32(name: String) throws -> Int32 {
        try verifyName(expectedName: name)
        return try readInt32()
    }

    public func readInt64(name: String) throws -> Int64 {
        try verifyName(expectedName: name)
        return try readInt64()
    }

    public func readDecimal(name: String) throws -> Decimal {
        try verifyName(expectedName: name)
        return try readDecimal()
    }

    public func readJavaScript(name: String) throws -> String {
        try verifyName(expectedName: name)
        return try readJavaScript()
    }

    public func readJavaScriptWithScope(name: String) throws -> String {
        try verifyName(expectedName: name)
        return try readJavaScriptWithScope()
    }

    public func readMaxKey(name: String) throws {
        try verifyName(expectedName: name)
        try readMaxKey()
    }

    public func readMinKey(name: String) throws {
        try verifyName(expectedName: name)
        try readMinKey()
    }

    public func readName() throws -> String {
        if state == .type {
            try readBsonType()
        }
        if state != .name {
            try throwInvalidState(validStates: .name)
        }

        state = .value
        return currentName
    }

    public func readName(name: String) throws {
        try verifyName(expectedName: name)
    }

    public func readNull(name: String) throws {
        try verifyName(expectedName: name)
        try readNull()
    }

    public func readObjectId(name: String) throws -> ObjectId {
        try verifyName(expectedName: name)
        return try readObjectId()
    }

    public func readRegularExpression(name: String) throws -> BsonRegularExpression {
        try verifyName(expectedName: name)
        return try readRegularExpression();
    }

    public func readDBPointer(name: String) throws -> BsonDbPointer {
        try verifyName(expectedName: name)
        return try readDBPointer()
    }

    public func readString(name: String) throws -> String {
        try verifyName(expectedName: name)
        return try readString()
    }

    public func readSymbol(name: String) throws -> String {
        try verifyName(expectedName: name)
        return try readSymbol()
    }

    public func readTimestamp(name: String) throws -> BsonTimestamp {
        try verifyName(expectedName: name)
        return try readTimestamp()
    }

    public func readUndefined(name: String) throws {
        try verifyName(expectedName: name)
        try readUndefined()
    }

    /**
     * Throws an InvalidOperationException when the method called is not valid for the current ContextType.
     *
     * @param methodName        The name of the method.
     * @param actualContextType The actual ContextType.
     * @param validContextTypes The valid ContextTypes.
     * @throws BsonInvalidOperationException when the method called is not valid for the current ContextType.
     */
    internal func throwInvalidContextType(_ function: String = #function,
                                          actualContextType: BsonContextType,
                                          validContextTypes: BsonContextType...) throws {
        let validContextTypesString = validContextTypes.join(separator: "or")

        let message = "\(function) can only be called when ContextType" +
            " is \(validContextTypesString), not when ContextType is \(actualContextType)."
        throw BSONError.invalidOperation(message)
    }

    /**
     * Throws an InvalidOperationException when the method called is not valid for the current state.
     *
     * @param methodName  The name of the method.
     * @param validStates The valid states.
     * @throws BsonInvalidOperationException when the method called is not valid for the current state.
     */
    internal func throwInvalidState(_ function: String = #function,
                                    validStates: State...) throws {
        let validStatesString = validStates.join(separator: " or ")
        let message = "\(function) can only be called when State" +
            " is \(validStatesString), not when State is \(state)."
        throw BSONError.invalidOperation(message)
    }



    /**
     * Verifies the name of the current element.
     *
     * @param expectedName The expected name.
     * @throws BsonSerializationException when the name read is not the expected name
     */
    internal func verifyName(expectedName: String) throws {
        try readBsonType()
        let actualName = try readName()
        if actualName != expectedName {
            throw BSONError.serialization(
                "Expected element name to be '\(expectedName)', not '\(actualName)'.")
        }
    }

    /**
     * Verifies the current state and BSONType of the reader.
     *
     * @param methodName       The name of the method calling this one.
     * @param requiredBsonType The required BSON type.
     */
    internal func verifyBSONType(requiredBsonType: BsonType,
                                 _ function: String = #function) throws {
        if (state == .initial || state == .scopeDocument || state == .type) {
            try readBsonType()
        }
        if (state == .name) {
            // ignore name
            try skipName()
        }
        if (state != .value) {
            try throwInvalidState(function, validStates: .value);
        }
        if (currentBsonType != requiredBsonType) {
            throw BSONError.invalidOperation(
                "\(function) can only be called when CurrentBSONType is \(requiredBsonType), "
                + "not when CurrentBSONType is \(currentBsonType).")
        }
    }

    /**
     * Ensures any conditions are met before reading commences.  Throws exceptions if the conditions are not met.
     *
     * @param methodName the name of the current method, which will indicate the field being read
     * @param type       the type of this field
     */
    internal func checkPreconditions(_ type: BsonType, _ function: String = #function) throws {
        if isClosed {
            throw RuntimeError.illegalState("BsonWriter is closed")
        }

        try verifyBSONType(requiredBsonType: type, function)
    }

    /**
     * Returns the next {@code State} to transition to, based on the {@link org.bson.AbstractBsonReader.Context} of this reader.
     *
     * @return the next state
     */
    internal func nextState() throws -> State {
        switch context.contextType {
        case .array, .document, .scopeDocument: return .type
        case .topLevel: return .done
        default: throw BSONError.unexpected("Unexpected ContextType \(context.contextType).")
        }
    }

    private func setStateOnEnd() throws {
        switch context.contextType {
        case .array, .document: self.state = .type
        case .topLevel: self.state = .done
        default: throw BSONError.unexpected("Unexpected ContextType \(context.contextType).")
        }
    }
}
