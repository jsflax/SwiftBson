//
//  BsonDocument.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public typealias BsonElement = (String, BsonValue)

public class BsonDocument: BsonValue, Bson, Collection, ExpressibleByDictionaryLiteral {
    private static let idFieldName = "_id";
    private static let defaultRegistry = CodableRegistry.from(providers: BsonValueCodableProvider())

    public var bsonType: BsonType = .document
    private var _storage = [String: BsonValue]()

    public typealias Element = (key: String, value: BsonValue)

    public init() {
    }

    public init(_ dictionary: [String: BsonValue]) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }

    public required init(reader: BsonReader, decoderContext: DecoderContext) throws {
        try reader.readStartDocument()

        while try reader.readBsonType() != .endOfDocument {
            let fieldName = try reader.readName()
            let registry = decoderContext.registry ?? BsonDocument.defaultRegistry

            self[fieldName] = try registry.decode(withIdentifier: defaultBsonTypeClassMap[reader.currentBsonType]!,
                                                  reader: reader,
                                                  decoderContext: decoderContext)
        }

        try reader.readEndDocument()
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeStartDocument()

        try beforeFields(writer: writer, encoderContext: encoderContext)
        for entry in self {
            if skipField(encoderContext: encoderContext, key: entry.key) { continue }

            try writer.writeName(name: entry.key)
            try entry.value.encode(writer: writer, encoderContext: encoderContext)
        }

        try writer.writeEndDocument()
    }

    /**
     * Gets a JSON representation of this document using the given {@code JsonWriterSettings}.
     * @param settings the JSON writer settings
     * @return a JSON representation of this document
     */
    public func toJson(_ settings: JsonWriterSettings = JsonWriterSettings { _ in }) throws -> String {
        var writer: TextOutputStream = StringWriter()
        try encode(writer: JsonWriter(writer: &writer, settings: settings), encoderContext: EncoderContext { _ in })
        return String((writer as! StringWriter).chars)
    }

    /**
     * Parses a string in MongoDB Extended JSON format to a {@code BsonDocument}
     *
     * @param json the JSON string
     * @return a corresponding {@code BsonDocument} object
     * @see org.bson.json.JsonReader
     * @mongodb.driver.manual reference/mongodb-extended-json/ MongoDB Extended JSON
     */
    public static func parse(json: String) throws -> BsonDocument {
        return try BsonDocument.init(reader: JsonReader(json: json), decoderContext: DecoderContext { _ in })
    }

    private func beforeFields(writer: BsonWriter, encoderContext: EncoderContext) throws {
        if encoderContext.isEncodingCollectibleDocument && self.contains { $0.key == BsonDocument.idFieldName } {
            try writer.writeName(name: BsonDocument.idFieldName);
            try self[BsonDocument.idFieldName]?.encode(writer: writer, encoderContext: encoderContext)
        }
    }

    private func skipField(encoderContext: EncoderContext, key: String) -> Bool {
        return encoderContext.isEncodingCollectibleDocument && key == BsonDocument.idFieldName
    }

    public func index(after i: Dictionary<String, BsonValue>.Index) -> Dictionary<String, BsonValue>.Index {
        return self._storage.index(after: i)
    }

    public subscript(position: Dictionary<String, BsonValue>.Index) -> (key: String, value: BsonValue) {
        return self._storage[position]
    }

    public var startIndex: Dictionary<String, BsonValue>.Index {
        return self._storage.startIndex
    }

    public var endIndex: Dictionary<String, BsonValue>.Index {
        return self._storage.endIndex
    }

    public subscript(key: String) -> BsonValue? {
        get {
            return self._storage[key]
        }
        set(val) {
            self._storage[key] = val
        }
    }

    func toBsonDocument<TDocument>(documentClass: TDocument.Type) -> BsonDocument {
        return self
    }

    public func isEqual(to: BsonValue) -> Bool {
        guard let to = to as? BsonDocument else {
            return false
        }

        return self == to
    }

    public required init(dictionaryLiteral elements: (String, BsonValue)...) {
        for element in elements {
            self._storage[element.0] = element.1
        }
    }
}

extension BsonDocument: Hashable {
    public var hashValue: Int {
        return arc4random().hashValue
    }

    public static func ==(lhs: BsonDocument, rhs: BsonDocument) -> Bool {
        return try! lhs._storage.elementsEqual(rhs._storage,
                                               by: { (l: BsonElement, r: BsonElement) throws -> Bool in
            return l.0 == r.0 && l.1.isEqual(to: r.1)
        })
    }
}

