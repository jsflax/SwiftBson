//
//  JsonWriterTest.swift
//  bsonTests
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation
import XCTest
@testable import bson

class JsonWriterTest: XCTestCase {
    class StringWriter: TextOutputStream {
        var chars: [Character] = []
        func write(_ string: String) {
            chars.append(contentsOf: string)
        }
    }

    private func strwtostr() -> String {
        return String((stringWriter as! StringWriter).chars)
    }

    private var stringWriter: TextOutputStream = StringWriter()
    private lazy var writer: JsonWriter = JsonWriter(writer: &stringWriter,
                                                     settings: JsonWriterSettings {_ in })

    override func setUp() {
        stringWriter = StringWriter()
        writer = JsonWriter(writer: &stringWriter,
                            settings: JsonWriterSettings {_ in })
    }

    private struct TestData<T> {
        public let value: T
        public let expected: String

        init(_ value: T, _ expected: String) {
            self.value = value
            self.expected = expected
        }
    }

    public func testShouldThrowExceptionForBooleanWhenWritingBeforeStartingDocument() throws {
        XCTAssertThrowsError(try writer.writeBoolean(name: "b1", value: true))
    }

    public func testShouldThrowExceptionForNameWhenWritingBeforeStartingDocument() throws {
        XCTAssertThrowsError(try writer.writeName(name: "name"))
    }

    public func testShouldThrowExceptionForStringWhenStateIsValue() throws {
        try writer.writeStartDocument()
        XCTAssertThrowsError(try writer.writeString(value: "SomeString"))
    }

    public func shouldThrowExceptionWhenEndingAnArrayWhenStateIsValue() throws {
        try writer.writeStartDocument()
        XCTAssertThrowsError(try writer.writeEndArray())
    }

    public func testShouldThrowExceptionWhenWritingASecondName() throws {
        try writer.writeStartDocument()
        try writer.writeName(name: "f1")
        XCTAssertThrowsError(try writer.writeName(name: "i2"))
    }


    public func testShouldThrowExceptionWhenEndingADocumentBeforeValueIsWritten() throws {
        try writer.writeStartDocument()
        try writer.writeName(name: "f1")
        XCTAssertThrowsError(try writer.writeEndDocument())
    }

    public func testShouldThrowAnExceptionWhenTryingToWriteASecondValue() throws {
        XCTAssertThrowsError(try writer.writeDouble(value: 100))
        XCTAssertThrowsError(try writer.writeString(value: "i2"))
    }

    public func testShouldThrowAnExceptionWhenTryingToWriteJavaScript() throws {
        XCTAssertThrowsError(try writer.writeDouble(value: 100))
        XCTAssertThrowsError(try writer.writeJavaScript(code: "var i"))
    }

    public func testShouldThrowAnExceptionWhenWritingANameInAnArray() throws {
        try writer.writeStartDocument()
        try writer.writeStartArray(name: "f2")
        XCTAssertThrowsError(try writer.writeName(name: "i3"))
    }

    public func testShouldThrowAnExceptionWhenEndingDocumentInTheMiddleOfWritingAnArray() throws {
        try writer.writeStartDocument()
        try writer.writeStartArray(name: "f2")
        XCTAssertThrowsError(try writer.writeEndDocument())
    }


    public func testShouldThrowAnExceptionWhenEndingAnArrayInASubDocument() throws {
        try writer.writeStartDocument()
        try writer.writeStartArray(name: "f2")
        try writer.writeStartDocument()
        XCTAssertThrowsError(try writer.writeEndArray())
    }

    public func testShouldThrowAnExceptionWhenWritingANameInAnArrayEvenWhenSubDocumentExistsInArray() throws {
        try writer.writeStartDocument()
        try writer.writeStartArray(name: "f2")
        try writer.writeStartDocument()
        try writer.writeEndDocument()
        XCTAssertThrowsError(try writer.writeName(name: "i3"))
    }

    public func testShouldThrowAnExceptionWhenAttemptingToEndAnArrayThatWasNotStarted() throws {
        try writer.writeStartDocument()
        try writer.writeStartArray(name: "f2")
        try writer.writeEndArray()
        XCTAssertThrowsError(try writer.writeEndArray())
    }

    public func testShouldThrowAnErrorIfTryingToWriteNameIntoAJavascriptScope() throws {
        try writer.writeStartDocument()
        try writer.writeJavaScriptWithScope(name: "js1", code: "var i = 1")
        XCTAssertThrowsError(try writer.writeName(name: "b1"))
    }

    public func testShouldThrowAnErrorIfTryingToWriteValueIntoAJavascriptScope() throws {
        try writer.writeStartDocument()
        try writer.writeJavaScriptWithScope(name: "js1", code: "var i = 1")
        XCTAssertThrowsError(try writer.writeBinaryData(binary: BsonBinary(data: [0, 0, 1, 0])))
    }

    public func testShouldThrowAnErrorIfTryingToWriteArrayIntoAJavascriptScope() throws {
        try writer.writeStartDocument()
        try writer.writeJavaScriptWithScope(name: "js1", code: "var i = 1")
        XCTAssertThrowsError(try writer.writeStartArray())
    }

    public func testShouldThrowAnErrorIfTryingToWriteEndDocumentIntoAJavascriptScope() throws {
        try writer.writeStartDocument()
        try writer.writeJavaScriptWithScope(name: "js1", code: "var i = 1")
        XCTAssertThrowsError(try writer.writeEndDocument())
    }

    public func testEmptyDocument() throws {
        try writer.writeStartDocument()
        try writer.writeEndDocument()
        let expected = "{ }"

        XCTAssertEqual(expected, strwtostr())
    }

    public func testSingleElementDocument() throws {
        try writer.writeStartDocument();
        try writer.writeName(name: "s");
        try writer.writeString(value: "str");
        try writer.writeEndDocument();
        let expected = "{ \"s\" : \"str\" }";
        XCTAssertEqual(expected, strwtostr())
    }

    public func testTwoElementDocument() throws {
        try writer.writeStartDocument();
        try writer.writeName(name: "s");
        try writer.writeString(value: "str");
        try writer.writeName(name: "d");
        try writer.writeString(value: "str2");
        try writer.writeEndDocument();
        let expected = "{ \"s\" : \"str\", \"d\" : \"str2\" }";
        XCTAssertEqual(expected, strwtostr());
    }


    public func testNestedDocument() throws {
        try writer.writeStartDocument();
        try writer.writeName(name: "doc");
        try writer.writeStartDocument();
        try writer.writeName(name: "doc");
        try writer.writeStartDocument();
        try writer.writeName(name: "s");
        try writer.writeString(value: "str");
        try writer.writeEndDocument();
        try writer.writeEndDocument();
        try writer.writeEndDocument();
        let expected = "{ \"doc\" : { \"doc\" : { \"s\" : \"str\" } } }";
        XCTAssertEqual(expected, strwtostr());
    }


    public func testSingleString() throws {
        try writer.writeStartDocument();
        try writer.writeString(name: "abc", value: "xyz");
        try writer.writeEndDocument();
        let expected = "{ \"abc\" : \"xyz\" }";
        XCTAssertEqual(expected, strwtostr());
    }



    public func testBoolean() throws {
        try writer.writeStartDocument();
        try writer.writeBoolean(name: "abc", value: true);
        try writer.writeEndDocument();
        let expected = "{ \"abc\" : true }";
        XCTAssertEqual(expected, strwtostr());
    }

    public func testDouble() throws {
        let tests = [
            TestData<Double>(0.0, "0.0"), TestData<Double>(0.0005, "5.0E-4"),
            TestData<Double>(0.5, "0.5"), TestData<Double>(1.0, "1.0"),
            TestData<Double>(1.5, "1.5"), TestData<Double>(1.5E+40, "1.5E40"),
            TestData<Double>(1.5E-40, "1.5E-40"),
            TestData<Double>(1234567890.1234568E+123, "1.2345678901234568E132"),
            TestData<Double>(Double.greatestFiniteMagnitude, "1.7976931348623157E308"),
            TestData<Double>(Double.leastNormalMagnitude, "4.9E-324"),
            TestData<Double>(-0.0005, "-5.0E-4"),
            TestData<Double>(-0.5, "-0.5"),
            TestData<Double>(-1.0, "-1.0"),
            TestData<Double>(-1.5, "-1.5"),
            TestData<Double>(-1.5E+40, "-1.5E40"),
            TestData<Double>(-1.5E-40, "-1.5E-40"),
            TestData<Double>(-1234567890.1234568E+123, "-1.2345678901234568E132"),
            TestData<Double>(Double.nan, "NaN"),
            TestData<Double>(-Double.infinity, "-Infinity"),
            TestData<Double>(Double.infinity, "Infinity")
        ]
        for cur in tests {
            self.stringWriter = StringWriter()
            self.writer = JsonWriter(writer: &stringWriter,
                                     settings: JsonWriterSettings { builder in
                builder.outputMode = .extended
            })
            try writer.writeStartDocument()
            try writer.writeDouble(name: "d", value: cur.value);
            try writer.writeEndDocument();
            let expected = "{ \"d\" : { \"$numberDouble\" : \"" + cur.expected + "\" } }";
            XCTAssertEqual(expected, strwtostr());
        }
    }


    public func testUndefinedShell() throws {
        writer = JsonWriter(writer: &stringWriter, settings: JsonWriterSettings { $0.outputMode = .shell })
        try writer.writeStartDocument();
        try writer.writeUndefined(name: "undefined");
        try writer.writeEndDocument();
        let expected = "{ \"undefined\" : undefined }";
        XCTAssertEqual(expected, strwtostr());
    }

    public func testDBPointer() throws {
        try writer.writeStartDocument();
        try writer.writeDBPointer(name: "dbPointer",
                                  value: BsonDbPointer(namespace: "my.test",
                                                       id: ObjectId(hexString: "4d0ce088e447ad08b4721a37")));
        try writer.writeEndDocument();
        let expected = "{ \"dbPointer\" : { \"$ref\" : \"my.test\", \"$id\" : { \"$oid\" : \"4d0ce088e447ad08b4721a37\" } } }";
        XCTAssertEqual(expected, strwtostr());
    }
}
