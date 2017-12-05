//
//  JsonWriter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A {@code BsonWriter} implementation that outputs a JSON representation of BSON.
 *
 * @since 3.0
 */
public class JsonWriter: AbstractBsonWriter {
    public var fieldNameValidatorStack: Stack<FieldNameValidator> = Stack<FieldNameValidator>()
    public var serializationDepth: Int = 0
    
    public var isClosed: Bool = false
    
    public var settings: BsonWriterSettings
    private var _settings: JsonWriterSettings {
        return settings as! JsonWriterSettings
    }
    private let strictJsonWriter: StrictCharacterStreamJsonWriter
    public var context: WriterContext?
    public var state: State = .initial
    
    /**
     * Creates a new instance which uses {@code writer} to write JSON to and uses the given settings.
     *
     * @param writer   the writer to write JSON to.
     * @param settings the settings to apply to this writer.
     */
    public init(writer: inout TextOutputStream,
                settings: JsonWriterSettings,
                validator: FieldNameValidator = NoOpFieldNameValidator()) {
        self.settings = settings
        self.context = Context(parentContext: nil, contextType: .topLevel)
        strictJsonWriter =
            StrictCharacterStreamJsonWriter(writer: &writer,
                                            settings: StrictCharacterStreamJsonWriterSettings(
                                                StrictCharacterStreamJsonWriterSettings.Builder {
                                                $0.indent = settings.indent
                                                $0.newLineCharacters = settings.newLineCharacters
                                                $0.indentCharacters = settings.indentCharacters
            }))
        self.fieldNameValidatorStack.push(validator)
    }


    public func doWriteName(name: String) throws {
        try strictJsonWriter.write(name: name)
    }


    public func doWriteStartDocument() throws {
        try strictJsonWriter.writeStartObject()

        let contextType: BsonContextType = state == .scopeDocument ? .scopeDocument : .document
        context = Context(parentContext: context, contextType: contextType)
    }


    public func doWriteEndDocument() throws {
        try strictJsonWriter.writeEndObject()
        if context?.contextType == .scopeDocument {
            context = context?.parentContext
            try writeEndDocument()
        } else {
            context = context?.parentContext
        }
    }


    public func doWriteStartArray() throws {
        try strictJsonWriter.writeStartArray()
        context = Context(parentContext: context, contextType: .array)
    }


    public func doWriteEndArray() throws {
        try strictJsonWriter.writeEndArray()
        context = context?.parentContext
    }



    public func doWriteBinaryData(value: BsonBinary) throws {
        try _settings.binaryConverter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteBoolean(value: Bool) throws {
        try _settings.boolConverter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteDateTime(value: Int64) throws {
        try _settings.dateTimeConverter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteDBPointer(value: BsonDbPointer) throws {
        if _settings.outputMode == .extended {
            try strictJsonWriter.writeStartObject()
            try strictJsonWriter.writeStartObject(name: "$dbPointer")
            try strictJsonWriter.write(name: "$ref", string: value.namespace)
            try strictJsonWriter.write(name: "$id")
            try doWriteObjectId(value: value.id)
            try strictJsonWriter.writeEndObject()
            try strictJsonWriter.writeEndObject()
        } else {
            try strictJsonWriter.writeStartObject()
            try strictJsonWriter.write(name: "$ref", string: value.namespace)
            try strictJsonWriter.write(name: "$id")
            try doWriteObjectId(value: value.id)
            try strictJsonWriter.writeEndObject()
        }
    }


    public func doWriteDouble(value: Double) throws {
        try _settings.doubleConverter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteInt32(value: Int32) throws {
        try _settings.int32Converter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteInt64(value: Int64) throws {
        try _settings.int64Converter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteDecimal128(value: Decimal) throws {
        try _settings.decimalConverter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteJavaScript(value code: String) throws {
        try _settings.javaScriptConverter.convert(value: code, writer: strictJsonWriter)
    }


    public func doWriteJavaScriptWithScope(value code: String) throws {
        try writeStartDocument()
        try writeString(name: "$code", value: code)
        try writeName(name: "$scope")
    }


    public func doWriteMaxKey() throws {
        try _settings.maxKeyConverter.convert(value: BsonMaxKey(), writer: strictJsonWriter)
    }


    public func doWriteMinKey() throws {
        try _settings.minKeyConverter.convert(value: BsonMinKey(), writer: strictJsonWriter)
    }


    public func doWriteNull() throws {
        try _settings.nullConverter.convert(value: BsonNull(), writer: strictJsonWriter)
    }


    public func doWriteObjectId(value objectId: ObjectId) throws {
        try _settings.objectIdConverter.convert(value: objectId, writer: strictJsonWriter)
    }


    public func doWriteRegularExpression(value regularExpression: BsonRegularExpression) throws {
        try _settings.regularExpressionConverter.convert(value: regularExpression, writer: strictJsonWriter)
    }


    public func doWriteString(value: String) throws {
        try _settings.stringConverter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteSymbol(value: String) throws {
        try _settings.symbolConverter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteTimestamp(value: BsonTimestamp) throws {
        try _settings.timestampConverter.convert(value: value, writer: strictJsonWriter)
    }


    public func doWriteUndefined() throws {
        try _settings.undefinedConverter.convert(value: BsonUndefined(), writer: strictJsonWriter)
    }

    /**
     * The context for the writer, inheriting all the values from {@link org.bson.AbstractBsonWriter.Context}, and additionally providing
     * _settings for the indentation level and whether there are any child elements at this level.
     */
    public class Context: WriterContext {

        /**
         * Creates a new context.
         *
         * @param parentContext the parent context that can be used for going back up to the parent level
         * @param contextType   the type of this context
         */
        public override init(parentContext: WriterContext?, contextType: BsonContextType) {
            super.init(parentContext: parentContext, contextType: contextType)
        }
    }
}
