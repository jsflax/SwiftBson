//
//  Document.swift
//  bson
//
//  Created by Jason Flax on 11/29/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public struct Document: Collection, BsonCodable, Bson {
    private static let idFieldName = "_id";

    public typealias DictionaryType = [String: Any]

    public typealias Index = DictionaryType.Index
    public typealias Element = DictionaryType.Element
    private var storage: DictionaryType

    // The upper and lower bounds of the collection, used in iterations
    public var startIndex: Index { return storage.startIndex }
    public var endIndex: Index { return storage.endIndex }

    public static func parse(json: String) throws -> Document {
        let bsonReader = JsonReader(json: json)
        return try Document.init(reader: bsonReader, decoderContext: DecoderContext { _ in })
    }
    
    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        self.storage = [:]

        try reader.readStartDocument()
        while try reader.readBsonType() != .endOfDocument {
            let fieldName = try reader.readName()
            self[fieldName] = try readValue(reader: reader, decoderContext: decoderContext)
        }

        try reader.readEndDocument()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writeMap(writer: writer, value: self.storage, encoderContext: encoderContext)
    }

    // Required subscript, based on a dictionary index
    public subscript(index: Index) -> Iterator.Element {
        get { return storage[index] }
    }

    // Method that returns the next index when iterating
    public func index(after i: Index) -> Index {
        return storage.index(after: i)
    }

    private func writeMap(writer: BsonWriter, value: [String: Any], encoderContext: EncoderContext) throws {
        try writer.writeStartDocument()

        try beforeFields(bsonWriter: writer, encoderContext: encoderContext)

        for entry in self {
            if skipField(encoderContext: encoderContext, key: entry.key) {
                continue
            }
            try writer.writeName(name: entry.key)
            try writeValue(writer: writer, encoderContext: encoderContext, value: entry.value)
        }
        try writer.writeEndDocument()
    }

    private func beforeFields(bsonWriter: BsonWriter, encoderContext: EncoderContext) throws {
        if encoderContext.isEncodingCollectibleDocument && self.contains { $0.key == Document.idFieldName } {
            try bsonWriter.writeName(name: Document.idFieldName)
            try writeValue(writer: bsonWriter, encoderContext: encoderContext, value: self[Document.idFieldName])
        }
    }

    private func skipField(encoderContext: EncoderContext, key: String) -> Bool {
        return encoderContext.isEncodingCollectibleDocument && key == Document.idFieldName
    }

    private func writeValue(writer: BsonWriter, encoderContext: EncoderContext, value: Any?) throws {
        if value == nil {
            try writer.writeNull()
        } else if value is AnySequence<Any> {
            try writeIterable(writer: writer, list: value as! AnySequence<Any>, encoderContext: EncoderContext.defaultContext)
        } else if value is [String: Any] {
            try writeMap(writer: writer, value: value as! [String : Any], encoderContext: EncoderContext.defaultContext)
        } else {
            guard let codec = value as? BsonCodable else {
                throw BSONError.serialization(
                    "Value did not implement Codec protocol: \(String(describing: value))")
            }
            try encoderContext.encodeWithChildContext(encoder: codec, writer: writer)
        }
    }

    private func writeIterable(writer: BsonWriter, list: AnySequence<Any>, encoderContext: EncoderContext) throws {
        try writer.writeStartArray()
        for value in list {
            try writeValue(writer: writer, encoderContext: encoderContext, value: value)
        }
        try writer.writeEndArray()
    }

    private func readValue(reader: BsonReader, decoderContext: DecoderContext) throws -> Any? {
        let bsonType = reader.currentBsonType
        if bsonType == .null {
            try reader.readNull()
            return nil
        } else if bsonType == .array {
            return try readList(reader: reader, decoderContext: decoderContext)
        } else if bsonType == .binary {
            if BsonBinarySubType.isUuid(value: try reader.peekBinarySubType()) {
                if try reader.peekBinarySize() == 16 {
                    return try UUID(reader: reader, decoderContext: decoderContext)
                }
            }
        }

        return nil
        //return valueTransformer.transform(bsonTypeCodecMap.get(bsonType).decode(reader, decoderContext));
    }

    private func readList(reader: BsonReader, decoderContext: DecoderContext) throws -> [Any?] {
        try reader.readStartArray()
        var list = [Any?]()
        while try reader.readBsonType() != .endOfDocument {
            list.append(try readValue(reader: reader, decoderContext: decoderContext))
        }
        try reader.readEndArray()
        return list
    }

    func toBsonDocument<T>(documentClass: T.Type) -> BsonDocument {
        return BsonDocument()///BsonDocumentWrapper<Document>(self, codecRegistry.get(Document.self))
    }
}

extension Document {
    subscript(index: String) -> Any? {
        get { return storage[index] }
        set { storage[index] = newValue }
    }
}
