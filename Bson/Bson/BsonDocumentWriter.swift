//
//  BsonDocumentWriter.swift
//  bson
//
//  Created by Jason Flax on 11/29/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonDocumentWriterContext: WriterContext {
    fileprivate var container: BsonValue?

    init(container: BsonValue,
         contextType: BsonContextType,
         parent: WriterContext?) {
        self.container = container
        super.init(parentContext: parent, contextType: contextType)
    }

    init() {
        super.init(parentContext: nil, contextType: .topLevel)
    }

    func add(value: BsonValue) {
        if var container = self.container as? BsonArray {
            container.append(value)
        } else if let container = self.container as? BsonDocument {
            container[name!] = value
        }
    }
}

public class BsonDocumentWriter: AbstractBsonWriter {
    private var __context: BsonDocumentWriterContext?
    // Intermediary value to avoid casting
    private var _context: BsonDocumentWriterContext? {
        get {
            return __context
        }
        set(value) {
            self.context = value
            self.__context = value
        }
    }
    // Double backed context to avoid casting
    public var context: WriterContext?
    public var settings: BsonWriterSettings = BsonWriterSettings()
    public var fieldNameValidatorStack: Stack<FieldNameValidator> = Stack<FieldNameValidator>()
    public var state: State = .initial
    public var serializationDepth: Int = 0
    public var isClosed: Bool = false
    public let document: BsonDocument

    
    init(document: BsonDocument) {
        self.document = document
        self._context = BsonDocumentWriterContext()
        self.fieldNameValidatorStack.push(NoOpFieldNameValidator())
    }

    private func write(value: BsonValue) {
        self._context?.add(value: value)
    }

    public func doWriteStartDocument() throws {
        switch state {
        case .initial:
            self.context = BsonDocumentWriterContext(container: document,
                                                     contextType: .document,
                                                     parent: context)
        case .value:
            self.context = BsonDocumentWriterContext(container: BsonDocument(),
                                                     contextType: .document,
                                                     parent: context)
        case .scopeDocument:
            self.context = BsonDocumentWriterContext(container: BsonDocument(),
                                                     contextType: .scopeDocument,
                                                     parent: context)
        default:
            throw BSONError.invalidOperation("Unexpected state \(state)");
        }
    }

    public func doWriteEndDocument() throws {
        let value = self._context?.container
        self.context = context?.parentContext as? BsonDocumentWriterContext

        if self.context?.contextType == .javascriptWithScope {
            let scope = value as? BsonDocument
            let code = self._context?.container as? BsonString
            context = context?.parentContext as? BsonDocumentWriterContext
            write(value: BsonJavascriptWithScope(code: (code?.value)!, scope: scope!))
        } else if context?.contextType != .topLevel {
            write(value: value!)
        }
    }

    public func doWriteStartArray() throws {
        self.context = BsonDocumentWriterContext(container: BsonArray(),
                                                 contextType: .array,
                                                 parent: self.context)
    }

    public func doWriteEndArray() throws {
        let array = self._context?.container
        self.context = self.context?.parentContext as? BsonDocumentWriterContext
        write(value: array!)
    }

    public func doWriteBinaryData(value: BsonBinary) throws {
        write(value: value)
    }

    public func doWriteBoolean(value: Bool) throws {
        write(value: BsonBool(value: value))
    }

    public func doWriteDateTime(value: Int64) throws {
        write(value: BsonDateTime(value: value))
    }

    public func doWriteDBPointer(value: BsonDbPointer) throws {
        write(value: value)
    }

    public func doWriteDouble(value: Double) throws {
        write(value: BsonDouble(value: value))
    }

    public func doWriteInt32(value: Int32) throws {
        write(value: BsonInt32(value: value))
    }

    public func doWriteInt64(value: Int64) throws {
        write(value: BsonInt64(value: value))
    }

    public func doWriteDecimal128(value: Decimal) throws {
        write(value: BsonDecimal(value: value))
    }

    public func doWriteJavaScript(value: String) throws {
        write(value: BsonJavascript(code: value))
    }

    public func doWriteJavaScriptWithScope(value: String) throws {
        self.context = BsonDocumentWriterContext(container: BsonString(value: value),
                                                 contextType: .javascriptWithScope,
                                                 parent: self.context)
    }

    public func doWriteMaxKey() throws {
        write(value: BsonMaxKey())
    }

    public func doWriteMinKey() throws {
        write(value: BsonMinKey())
    }

    public func doWriteNull() throws {
        write(value: BsonNull.value)
    }

    public func doWriteObjectId(value: ObjectId) throws {
        write(value: BsonObjectId(value: value))
    }

    public func doWriteRegularExpression(value: BsonRegularExpression) throws {
        write(value: value)
    }

    public func doWriteString(value: String) throws {
        write(value: BsonString(value: value))
    }

    public func doWriteSymbol(value: String) throws {
        write(value: BsonSymbol(symbol: value))
    }

    public func doWriteTimestamp(value: BsonTimestamp) throws {
        write(value: value)
    }

    public func doWriteUndefined() throws {
        write(value: BsonUndefined())
    }

    public func doWriteName(name: String) throws {
    }

    public func flush() {
    }
}
