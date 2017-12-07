//
//  DocumentCodableSpecification.swift
//  bsonTests
//
//  Created by Jason Flax on 12/5/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation
import Quick
import Nimble
import XCTest
@testable import bson

var bsonDoc = BsonDocument()
var stringWriter = ""

func given() throws -> Document {
    return Document([
        "null": nil,
        "int32": Int32(42),
        "int64": Int64(52),
        "booleanTrue": true,
        "booleanFalse": false,
        "date": Date(),
        "dbPointer": BsonDbPointer(namespace: "foo.bar", id: try ObjectId()),
        "double": 62.0,
        "minKey": MinKey(),
        "maxKey": MaxKey(),
        "code": Code(code: "int i = 0;"),
        "codeWithScope": CodeWithScope(code: "int x = y", scope: Document(key: "y", value: 1)),
        "objectId": try ObjectId(),
        "regex": BsonRegularExpression(pattern: "^test.*regex.*xyz$", options: "i"),
        "string": "the fox ...",
        "symbol": Symbol(symbol: "ruby stuff"),
        "timestamp": BsonTimestamp(seconds: 0x12345678, increment: 5),
        "undefined": BsonUndefined(),
        "binary": Binary(data: [5, 4, 3, 2, 1], type: BsonBinarySubType(rawValue: 0x80)!),
        "array": [Any?].init(arrayLiteral: 1, Int64(1), true, [1, 2, 3], Document(key: "a", value: 1), nil),
        "uuid": UUID.init(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"),
        "document": Document(key: "a", value: 2),
        "map": ["a": 1, "b": 2]
    ])
}

func when(_ writer: BsonWriter, _ originalDocument: Document) throws -> Document {
    try! originalDocument.encode(writer: writer, encoderContext: EncoderContext { _ in })
    let reader: BsonReader
    if writer is BsonDocumentWriter {
        reader = BsonDocumentReader(document: bsonDoc)
    } else {
        reader = JsonReader(json: stringWriter)
    }
    return try Document(reader: reader, decoderContext: DecoderContext { _ in })
}

fileprivate var bsonDocument = BsonDocument()

class DocumentCodableConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("documents") { (sharedExampleContext: @escaping SharedExampleContext) in
            it("should encode and decode all default types with all readers and writers") {
                let writer = sharedExampleContext()["writer"] as! BsonWriter

                do {
                    let originalDocument = try given()
                    let decodedDocument = try when(writer, originalDocument)
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }
    }
}

class BsonWriterSpec: QuickSpec {
    override func spec() {
        var mackerel: BsonWriter = BsonDocumentWriter(document: bsonDocument)
        beforeEach {
            mackerel = BsonDocumentWriter(document: bsonDocument)
        }

        itBehavesLike("documents") { ["writer": mackerel] }
    }
}
