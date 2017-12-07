//
//  BsonDocumentTest.swift
//  bsonTests
//
//  Created by Jason Flax on 12/5/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation
import XCTest
@testable import bson

class BsonDocumentTest: XCTestCase {
    private let emptyDocument = BsonDocument();
    //private let emptyRawDocument = new RawBsonDocument(emptyDocument, new BsonDocumentCodec());
    private let document = BsonDocument([
        "a": BsonInt32.init(value: 1),
        "b": BsonInt32.init(value: 2),
        "c": BsonDocument(["x": BsonBool.yes]),
        "d": BsonArray.init(arrayLiteral: BsonDocument(["y": BsonBool.no]), BsonInt32(value: 1))
    ])

    //private BsonDocument rawDocument = new RawBsonDocument(document, new BsonDocumentCodec());

    public func shouldBeEqualToItself() {
        XCTAssertTrue(emptyDocument == emptyDocument)
        XCTAssertTrue(document == document)
    }


//    public func testShouldBeEqualToEquivalentBsonDocument() {
//        XCTAssertTrue(emptyDocument.equals(emptyRawDocument))
//        XCTAssertTrue(document.equals(rawDocument))
//        XCTAssertTrue(emptyRawDocument.equals(emptyDocument))
//        XCTAssertTrue(rawDocument.equals(document))
//    }
//
//
//    public func shouldNotBeEqualToDifferentBsonDocument() {
//        // expect
//        assertFalse(emptyDocument.equals(document));
//        assertFalse(document.equals(emptyRawDocument));
//        assertFalse(document.equals(emptyRawDocument));
//        assertFalse(emptyRawDocument.equals(document));
//        assertFalse(rawDocument.equals(emptyDocument));
//    }
//
//
//    public func shouldHaveSameHashCodeAsEquivalentBsonDocument() {
//    assertEquals(emptyDocument.hashCode(), new BsonDocument().hashCode());
//    assertEquals(emptyDocument.hashCode(), emptyRawDocument.hashCode());
//    assertEquals(document.hashCode(), rawDocument.hashCode());
//    }
//
//
//    public func toJsonShouldReturnEquivalent() {
//    assertEquals(new BsonDocumentCodec().decode(new JsonReader(document.toJson()), DecoderContext.builder().build()),
//    document);
//    }


    public func testToJsonShouldRespectDefaultJsonWriterSettings() throws {
        var writer: TextOutputStream = StringWriter()
        try document.encode(writer: JsonWriter(writer: &writer,
                                                 settings: JsonWriterSettings { _ in }),
                              encoderContext: EncoderContext { _ in })
        try XCTAssertEqual(strwtostr(writer), document.toJson())
    }


    public func testToJsonShouldRespectJsonWriterSettings() throws {
        var writer: TextOutputStream = StringWriter()
        let settings = JsonWriterSettings { $0.outputMode = .shell }
        try document.encode(writer: JsonWriter(writer: &writer, settings: settings),
                              encoderContext: EncoderContext { _ in })
        try XCTAssertEqual(strwtostr(writer), document.toJson(settings))
    }

    public func testShouldParseJson() throws {
        try XCTAssertEqual(BsonDocument(["a": BsonInt32(value: 1)]), BsonDocument.parse(json: "{\"a\" : 1}"))
    }
}
