//
//  BsonDocumentReader.swift
//  bsonTests
//
//  Created by Jason Flax on 12/5/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A {@code BsonReader} implementation that reads from an instance of {@code BsonDocument}.  This can be used to decode a {@code
 * BsonDocument} using a {@code Decoder}.
 *
 * @see BsonDocument
 * @see org.bson.codecs.Decoder
 *
 * @since 3.0
 */
public class BsonDocumentReader: AbstractBsonReader {
    public var mark: BsonReaderMark?

    public var currentName: String = ""
    public var isClosed: Bool = false

    private var currentValue: BsonValue?
    public var currentBsonType: BsonType = .null

    public var context: Context
    public var state: State = .initial

    /**
     * Construct a new instance.
     *
     * @param document the document to read from
     */
    public init(document: BsonDocument) {
        context = ReaderContext(parentContext: nil,
                                contextType: .topLevel,
                                document: document)
        currentValue = document
    }


    public func doReadBinaryData() throws -> BsonBinary {
        return try currentValue!.asType()
    }


    public func doPeekBinarySubType() throws -> Byte {
        return try currentValue!.asType(BsonBinary.self).type.rawValue
    }


    public func doPeekBinarySize() throws -> Int {
        return try currentValue!.asType(BsonBinary.self).data.count
    }


    public func doReadBoolean() throws -> Bool {
        return try currentValue!.asType(BsonBool.self).value
    }


    public func doReadDateTime() throws -> Int64 {
        return try currentValue!.asType(BsonDateTime.self).value
    }


    public func doReadDouble() throws -> Double {
        return try currentValue!.asType(BsonDouble.self).value
    }


    public func doReadEndArray() throws {
        context = context.parentContext!
    }


    public func doReadEndDocument() throws {
        context = context.parentContext!
        switch context.contextType {
        case .array, .document:
            state = .type
        case .topLevel:
            state = .done
        default:
            throw BSONError.invalidOperation("Unexpected ContextType.")
        }
    }


    public func doReadInt32() throws -> Int32 {
        return try currentValue!.asType(BsonInt32.self).value
    }


    public func doReadInt64() throws -> Int64 {
        return try currentValue!.asType(BsonInt64.self).value
    }


    public func doReadDecimal() throws -> Decimal {
        return try currentValue!.asType(BsonDecimal.self).value
    }


    public func doReadJavaScript() throws -> String {
        return try currentValue!.asType(BsonJavascript.self).code
    }


    public func doReadJavaScriptWithScope() throws -> String {
        return try currentValue!.asType(BsonJavascriptWithScope.self).code
    }


    public func doReadMaxKey() throws {
    }


    public func doReadMinKey() throws {
    }


    public func doReadNull() throws {
    }


    public func doReadObjectId() throws -> ObjectId {
        return try currentValue!.asType(BsonObjectId.self).value
    }


    public func doReadRegularExpression() throws -> BsonRegularExpression {
        return try currentValue!.asType()
    }


    public func doReadDBPointer() throws -> BsonDbPointer {
        return try currentValue!.asType()
    }


    public func doReadStartArray() throws {
        let array = try currentValue!.asType(BsonArray.self)
        context = ReaderContext(parentContext: context as? BsonDocumentReader.ReaderContext,
                                contextType: .array,
                                array: array)
    }


    public func doReadStartDocument() throws {
        let document: BsonDocument
        if currentValue!.bsonType == .javascriptWithScope {
            document = try currentValue!.asType(BsonJavascriptWithScope.self).scope
        } else {
            document = try currentValue!.asType()
        }
        context = ReaderContext(parentContext: context.asReaderContext(),
                                contextType: .document,
                                document: document)
    }


    public func doReadString() throws -> String {
        return try currentValue!.asType(BsonString.self).value
    }


    public func doReadSymbol() throws -> String {
        return try currentValue!.asType(BsonSymbol.self).symbol
    }


    public func doReadTimestamp() throws -> BsonTimestamp {
        return try currentValue!.asType()
    }


    public func doReadUndefined() throws {
    }


    public func doSkipName() throws {
    }


    public func doSkipValue() throws {
    }


    public func readBsonType() throws -> BsonType {
        if state == .initial || state == .scopeDocument {
            // there is an implied type of Document for the top level and for scope documents
            currentBsonType = .document
            state = .value
            return currentBsonType
        }

        if state != .type {
            try throwInvalidState("ReadBSONType", validStates: .type);
        }

        switch context.contextType {
        case .array:
            currentValue = context.asReaderContext().getNextValue()
            if currentValue == nil {
                state = .endOfArray
                return .endOfDocument
            }
            state = .value
        case .document:
            let currentElement = context.asReaderContext().getNextElement()
            if currentElement == nil {
                state = .endOfDocument
                return .endOfDocument
            }
            currentName = currentElement!.0
            currentValue = currentElement!.1
            state = .name
            break;
        default:
            throw BSONError.invalidOperation("Invalid ContextType.")
        }

        currentBsonType = currentValue!.bsonType
        return currentBsonType
    }

    public func getMark() -> BsonReaderMark {
        var temp = self
        return ReaderMark(abstractBsonReader: &temp)
    }


    public func reset() throws {
        if mark == nil {
            throw BSONError.invalidOperation("trying to reset a mark before creating it")
        }
        mark!.reset()
        mark = nil
    }

    internal class ReaderMark: Mark {
        private let currentValue: BsonValue
        private let context: Context

        internal init(abstractBsonReader: inout BsonDocumentReader) {
            var temp: AbstractBsonReader = abstractBsonReader
            currentValue = abstractBsonReader.currentValue!
            context = abstractBsonReader.context
            context.asReaderContext().mark()
            
            super.init(abstractBsonReader: &temp)
        }

        public override func reset() {
            super.reset()
            (abstractBsonReader as! BsonDocumentReader).currentValue = currentValue
            (abstractBsonReader as! BsonDocumentReader).context = context
            context.asReaderContext().reset()
        }
    }

    fileprivate struct BsonDocumentMarkableIterator<T>: IteratorProtocol where T: Collection {
        typealias Element = T.Element

        private var baseIterator: IndexingIterator<T>
        private var markIterator = [T.Element].init()
        private var curIndex: Int
        private var marking: Bool

        internal init(_ baseIterator: IndexingIterator<T>) {
            self.baseIterator = baseIterator
            curIndex = 0
            marking = false
        }

        mutating func next() -> T.Element? {
            let value: T.Element
            //TODO: check closed
            if curIndex < markIterator.count {
                value = markIterator[curIndex]
                if marking {
                    curIndex += 1
                } else {
                    markIterator.remove(at: 0)
                }
            } else {
                value = baseIterator.next()!
                if (marking) {
                    markIterator.append(value)
                    curIndex += 1
                }
            }

            return value;
        }

        /**
         *
         */
        public mutating func mark() {
            marking = true
        }

        /**
         *
         */
        public mutating func reset() {
            curIndex = 0
            marking = false
        }

        public func hasNext() -> Bool {
            return curIndex < markIterator.count
        }

        public func remove() {
            // iterator is read only
        }
    }

    internal class ReaderContext: Context {
        var parentContext: Context?
        var contextType: BsonContextType

        private var documentIterator: BsonDocumentMarkableIterator<BsonDocument>?
        private var arrayIterator: BsonDocumentMarkableIterator<BsonArray>?

        internal init(parentContext: ReaderContext?, contextType: BsonContextType, array: BsonArray) {
            self.parentContext = parentContext
            self.contextType = contextType
            arrayIterator = BsonDocumentMarkableIterator<BsonArray>(array.makeIterator())
        }

        internal init(parentContext: ReaderContext?, contextType: BsonContextType, document: BsonDocument) {
            self.parentContext = parentContext
            self.contextType = contextType
            documentIterator = BsonDocumentMarkableIterator<BsonDocument>(document.makeIterator())
        }

        public func getNextElement() -> (String, BsonValue)? {
            if var documentIterator = documentIterator,
                documentIterator.hasNext() {
                return documentIterator.next()
            } else {
                return nil
            }
        }
        
        public func mark() {
            if documentIterator != nil {
                documentIterator?.mark()
            } else {
                arrayIterator?.mark()
            }

            if let parentContext = parentContext as? ReaderContext {
                parentContext.mark()
            }
        }

        public func reset() {
            if var documentIterator = documentIterator {
                documentIterator.reset()
            } else {
                arrayIterator?.reset()
            }

            if let parentContext = parentContext {
                parentContext.asReaderContext().reset()
            }
        }

        public func getNextValue() -> BsonValue? {
            if var arrayIterator = arrayIterator,
                arrayIterator.hasNext() {
                return arrayIterator.next()
            } else {
                return nil
            }
        }
    }
}
