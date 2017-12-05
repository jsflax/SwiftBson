//
//  BsonValueCodecProvider.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public let defaultBsonTypeClassMap: [BsonType: ObjectIdentifier] = [
    .null: *BsonNull.self,
    .array: *BsonArray.self,
    .binary: *BsonBinary.self,
    .boolean: *BsonBool.self,
    .dateTime: *BsonDateTime.self,
    .dbPointer: *BsonDbPointer.self,
    .document: *BsonDocument.self,
    .double: *BsonDouble.self,
    .int32: *BsonInt32.self,
    .int64: *BsonInt64.self,
    .decimal128: *BsonDecimal.self,
    .maxKey: *BsonMaxKey.self,
    .minKey: *BsonMinKey.self,
    .javascript: *BsonJavascript.self,
    .javascriptWithScope: *BsonJavascriptWithScope.self,
    .objectId: *BsonObjectId.self,
    .regularExpression: *BsonRegularExpression.self,
    .string: *BsonString.self,
    .symbol: *BsonSymbol.self,
    .timestamp: *BsonTimestamp.self,
    .undefined: *BsonUndefined.self
]

public typealias BsonDecoderFunc = (_ reader: BsonReader, _ decoderContext: DecoderContext) throws -> BsonValue
public typealias AnyDecoderFunc = (_ reader: BsonReader, _ decoderContext: DecoderContext) throws -> Any

public struct BsonValueCodableProvider: CodableProvider {
    public let codables: [ObjectIdentifier: DecoderLambda] = [
        *BsonNull.self: BsonNull.init(reader: decoderContext:),
        *BsonArray.self: BsonArray.init(reader: decoderContext:),
        *BsonBinary.self: BsonBinary.init(reader: decoderContext:),
        *BsonType.self: BsonBool.init(reader: decoderContext:),
        *BsonDateTime.self: BsonDateTime.init(reader: decoderContext:),
        *BsonDbPointer.self: BsonDbPointer.init(reader: decoderContext:),
        *BsonDocument.self: BsonDocument.init(reader: decoderContext:),
        *BsonDouble.self: BsonDouble.init(reader: decoderContext:),
        *BsonInt32.self: BsonInt32.init(reader: decoderContext:),
        *BsonInt64.self: BsonInt64.init(reader: decoderContext:),
        *BsonDecimal.self: BsonDecimal.init(reader: decoderContext:),
        *BsonMaxKey.self: BsonMaxKey.init(reader: decoderContext:),
        *BsonMinKey.self: BsonMinKey.init(reader: decoderContext:),
        *BsonJavascript.self: BsonJavascript.init(reader: decoderContext:),
        *BsonJavascriptWithScope.self: BsonJavascriptWithScope.init(reader: decoderContext:),
        *BsonObjectId.self: BsonObjectId.init(reader: decoderContext:),
        *BsonRegularExpression.self: BsonRegularExpression.init(reader: decoderContext:),
        *BsonString.self: BsonString.init(reader: decoderContext:),
        *BsonSymbol.self: BsonSymbol.init(reader: decoderContext:),
        *BsonTimestamp.self: BsonTimestamp.init(reader: decoderContext:),
        *BsonUndefined.self: BsonUndefined.init(reader: decoderContext:)
    ]
}

public let defaultBsonTypeDecoderClassMap: [BsonType: DecoderLambda] = [
    .array: Array<Any>.init(reader: decoderContext:),
    .binary: UUID.init(reader: decoderContext:)
]
