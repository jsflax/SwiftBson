//
//  BsonBinaryReader.swift
//  bson
//
//  Created by Jason Flax on 12/5/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public class BsonBinaryReader: AbstractBsonReader {
    public var currentName: String = ""
    public var state: State = .initial
    public var context: Context
    public var currentBsonType: BsonType = .null
    public var isClosed: Bool = false
    public var mark: BsonReaderMark?
    public let bsonInput: BsonInput

    /**
     * Construct an instance.
     *
     * @param byteBuffer the input for this reader
     */
    public convenience init(byteBuffer: [Byte]) {
        self.init(bsonInput: ByteBufferBsonInput(byteBuffer: byteBuffer))
    }

    /**
     * Construct an instance.
     *
     * @param bsonInput the input for this reader
     */
    public init(bsonInput: BsonInput) {
        self.bsonInput = bsonInput;
        context = BinaryContext(parentContext: nil, contextType: .topLevel, startPosition: 0, size: 0)
    }

    public func doReadBinaryData() throws -> BsonBinary {
        fatalError()
    }

    public func doPeekBinarySubType() throws -> Byte {
        fatalError()
    }

    public func doPeekBinarySize() throws -> Int {
        fatalError()
    }

    public func doReadBoolean() throws -> Bool {
        fatalError()
    }

    public func doReadDateTime() throws -> Int64 {
        fatalError()
    }

    public func doReadDouble() throws -> Double {
        fatalError()
    }

    public func doReadEndArray() throws {
        fatalError()
    }

    public func doReadEndDocument() throws {
        fatalError()
    }

    public func doReadInt32() throws -> Int32 {
        fatalError()
    }

    public func doReadInt64() throws -> Int64 {
        fatalError()
    }

    public func doReadDecimal() throws -> Decimal {
        fatalError()
    }

    public func doReadJavaScript() throws -> String {
        fatalError()
    }

    public func doReadJavaScriptWithScope() throws -> String {
        fatalError()
    }

    public func doReadMaxKey() throws {
        fatalError()
    }

    public func doReadMinKey() throws {
        fatalError()
    }

    public func doReadNull() throws {
        fatalError()
    }

    public func doReadObjectId() throws -> ObjectId {
        fatalError()
    }

    public func doReadRegularExpression() throws -> BsonRegularExpression {
        fatalError()
    }

    public func doReadDBPointer() throws -> BsonDbPointer {
        fatalError()
    }

    public func doReadStartArray() throws {
        fatalError()
    }

    public func doReadStartDocument() throws {
        fatalError()
    }

    public func doReadString() throws -> String {
        fatalError()
    }

    public func doReadSymbol() throws -> String {
        fatalError()
    }

    public func doReadTimestamp() throws -> BsonTimestamp {
        fatalError()
    }

    public func doReadUndefined() throws {
        fatalError()
    }

    public func doSkipName() throws {
        fatalError()
    }

    public func doSkipValue() throws {
        fatalError()
    }

    public func readBsonType() throws -> BsonType {
        if isClosed {
            throw RuntimeError.illegalState("BSONBinaryWriter")
        }

        if state == .initial || state == .done || state == .scopeDocument {
            // there is an implied type of Document for the top level and for scope documents
            currentBsonType = .document
            state = .value
            return currentBsonType
        }
        if state != .type {
            try throwInvalidState(validStates: .type)
        }

        let bsonTypeByte = bsonInput.readByte()
        guard let bsonType = BsonType(rawValue: Int(bsonTypeByte)) else {
            let name = bsonInput.readCString()
            throw BSONError.serialization("Detected unknown BSON type \"\\x\(bsonTypeByte)\" for fieldname \"\(name)\". "
                + "Are you using the latest driver version?")
        }
        currentBsonType = bsonType

        if currentBsonType == .endOfDocument {
            switch context.contextType {
            case .array:
                state = .endOfArray
                return .endOfDocument
            case .document, .scopeDocument:
                state = .endOfDocument
                return .endOfDocument
            default:
                throw BSONError.serialization(
                    "BSONType EndOfDocument is not valid when ContextType is \(context.contextType).")
            }
        } else {
            switch context.contextType {
            case .array:
                bsonInput.skipCString() // ignore array element names
                state = .value
            case .document, .scopeDocument:
                currentName = bsonInput.readCString()
                state = .name
            default:
                throw BSONError.unexpected("Unexpected ContextType.");
            }

            return currentBsonType
        }
    }

    public func reset() throws {

    }

    internal class BinaryMark: Mark {
        fileprivate let startPosition: Int
        fileprivate let size: Int

        override init(abstractBsonReader: inout AbstractBsonReader) {
            startPosition = abstractBsonReader.context.asBinaryContext().startPosition
            size = abstractBsonReader.context.asBinaryContext().size
            (abstractBsonReader as! BsonBinaryReader).bsonInput.mark(readLimit: Int.max)
            super.init(abstractBsonReader: &abstractBsonReader)
        }

        public override func reset() {
            super.reset();
            (abstractBsonReader as! BsonBinaryReader).bsonInput.reset();
            abstractBsonReader.context = BinaryContext(parentContext: parentContext,
                                                       contextType: contextType,
                                                       startPosition: startPosition,
                                                       size: size)
        }
    }

    internal class BinaryContext: Context {
        fileprivate let startPosition: Int
        fileprivate let size: Int

        var parentContext: Context?
        var contextType: BsonContextType

        init(parentContext: Context?,
             contextType: BsonContextType,
             startPosition: Int,
             size: Int) {
            self.parentContext = parentContext
            self.contextType = contextType
            self.startPosition = startPosition
            self.size = size
        }

        func popContext(position: Int) throws -> Context? {
            let actualSize = position - startPosition
            if actualSize != size {
                throw BSONError.serialization("Expected size to be \(size), not \(actualSize).")
            }
            return parentContext
        }
    }
}
