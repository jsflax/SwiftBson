//
//  BsonValueCodecProvider.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation


private let bsonCoderArchive: [BsonType: Any] = [
    .array: AnyCodec(BsonArrayCodec())
]

public let defaultBsonTypeClassMap: [BsonType: BsonValue.Type] = [
    .null: BsonNull.self,
    .array: BsonArray.self,
    .binary: BsonBinary.self,
    .boolean: BsonBool.self,
    .dateTime: BsonDateTime.self,
    .dbPointer: BsonDbPointer.self,
    .document: BsonDocument.self,
    .double: BsonDouble.self,
    .int32: BsonInt32.self,
    .int64: BsonInt64.self,
    .decimal128: BsonDecimal.self,
    .maxKey: BsonMaxKey.self,
    .minKey: BsonMinKey.self,
    .javascript: BsonJavascript.self,
    .javascriptWithScope: BsonJavascriptWithScope.self,
    .objectId: BsonObjectId.self,
    .regularExpression: BsonRegularExpression.self,
    .string: BsonString.self,
    .symbol: BsonSymbol.self,
    .timestamp: BsonTimestamp.self,
    .undefined: BsonUndefined.self
]

//public struct BsonValueCodecProvider: CodecProvider {
//
//
//    public static func get<T>(bsonType: BsonType) -> T.Type? where T: BsonValue, T: AnyObject {
//        return defaultBsonTypeClassMap[bsonType]
//    }
//
//    private let codecs: [ObjectIdentifier: BoxedCodec] = [
//        ObjectIdentifier(BsonInt64.self): BoxedCodec(BsonInt64Codec())
//    ]
//
//    public func get<T>(registry: CodecRegistry, type: T.Type) -> BoxedCodec? {
//        if let codec = codecs[ObjectIdentifier(T.self)] {
//            return codec
//        }
//
//        switch T.self {
//        case is BsonArray.Type: return try? BoxedCodec(registry, type: T.self)
//        default: return nil
//        }
//    }
//}

