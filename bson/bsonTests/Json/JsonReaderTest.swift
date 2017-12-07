//
//  JsonReaderTest.swift
//  bsonTests
//
//  Created by Jason Flax on 11/27/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

import XCTest
@testable import bson

class JsonReaderTest: XCTestCase {
    private var bsonReader: AbstractBsonReader = JsonReader(json: "")

    func testArrayEmpty() throws {
        let json = "[]"
        bsonReader = JsonReader(json: json)

        XCTAssertEqual(.array, try bsonReader.readBsonType())
        try bsonReader.readStartArray()
        XCTAssertEqual(.endOfDocument, try bsonReader.readBsonType())
        try bsonReader.readEndArray()
        XCTAssertEqual(.done, bsonReader.state)
    }

    func testArrayOneElement() throws {
        let json = "[1]"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.array, try bsonReader.readBsonType())
        try bsonReader.readStartArray()
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual(1, try bsonReader.readInt32())
        XCTAssertEqual(.endOfDocument, try bsonReader.readBsonType())
        try bsonReader.readEndArray()
        XCTAssertEqual(.done, bsonReader.state)
    }

    func testArrayTwoElements() throws {
        let json = "[1, 2]"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.array, try bsonReader.readBsonType())
        try bsonReader.readStartArray()
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual(1, try bsonReader.readInt32())
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual(2, try bsonReader.readInt32())
        XCTAssertEqual(.endOfDocument, try bsonReader.readBsonType())
        try bsonReader.readEndArray()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testBooleanFalse() throws {
        let json = "false"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.boolean, try bsonReader.readBsonType())
        XCTAssertEqual(false, try bsonReader.readBoolean())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testBooleanTrue() throws {
        let json = "true"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.boolean, try bsonReader.readBsonType())
        XCTAssertEqual(true, try bsonReader.readBoolean())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDateTimeMinBson() throws {
        let json = "new Date(-9223372036854775808)"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertEqual(-9223372036854775808, try bsonReader.readDateTime())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDateTimeMaxBson() throws {
        let json = "new Date(9223372036854775807)"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        let k = try bsonReader.readDateTime()
        XCTAssertEqual(9223372036854775807, k)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDateTimeShell() throws {
        let json = "ISODate(\"1970-01-01T00:00:00Z\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertEqual(0, try bsonReader.readDateTime())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDateTimeShellWith24HourTimeSpecification() throws {
        let json = "ISODate(\"2013-10-04T12:07:30.443Z\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertEqual(1380888450443, try bsonReader.readDateTime())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDateTimeStrict() throws {
        let json = "{ \"$date\" : 0 }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertEqual(Int64(0), try bsonReader.readDateTime())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testNestedDateTimeStrict() throws {
        let json = "{d1 : { \"$date\" : 0 }, d2 : { \"$date\" : 1 } }"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        XCTAssertEqual(Int64(0), try bsonReader.readDateTime(name: "d1"))
        XCTAssertEqual(Int64(1), try bsonReader.readDateTime(name: "d2"))
        try bsonReader.readEndDocument()
    }


    public func testDateTimeISOString() throws {
        let json = "{ \"$date\" : \"2015-04-16T14:55:57.626Z\" }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertEqual(1429196157626, try bsonReader.readDateTime())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDateTimeISOStringWithTimeOffset() throws {
        let json = "{ \"$date\" : \"2015-04-16T16:55:57.626+02:00\" }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertEqual(1429196157626, try bsonReader.readDateTime())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDateTimeTengen() throws {
        let json = "new Date(0)"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertEqual(0, try bsonReader.readDateTime())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDocumentEmpty() throws {
        let json = "{ }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        try bsonReader.readStartDocument()
        XCTAssertEqual(.endOfDocument, try bsonReader.readBsonType())
        try bsonReader.readEndDocument()
    }


    public func testDocumentNested() throws {
        let json = "{ \"a\" : { \"x\" : 1 }, \"y\" : 2 }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        try bsonReader.readStartDocument()
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        XCTAssertEqual("a", try bsonReader.readName())
        try bsonReader.readStartDocument()
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual("x", try bsonReader.readName())
        XCTAssertEqual(1, try bsonReader.readInt32())
        XCTAssertEqual(.endOfDocument, try bsonReader.readBsonType())
        try bsonReader.readEndDocument()
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual("y", try bsonReader.readName())
        XCTAssertEqual(2, try bsonReader.readInt32())
        XCTAssertEqual(.endOfDocument, try bsonReader.readBsonType())
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDocumentOneElement() throws {
        let json = "{ \"x\" : 1 }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        try bsonReader.readStartDocument()
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual("x", try bsonReader.readName())
        XCTAssertEqual(1, try bsonReader.readInt32())
        XCTAssertEqual(.endOfDocument, try bsonReader.readBsonType())
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDocumentTwoElements() throws {
        let json = "{ \"x\" : 1, \"y\" : 2 }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        try bsonReader.readStartDocument()
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual("x", try bsonReader.readName())
        XCTAssertEqual(1, try bsonReader.readInt32())
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual("y", try bsonReader.readName())
        XCTAssertEqual(2, try bsonReader.readInt32())
        XCTAssertEqual(.endOfDocument, try bsonReader.readBsonType())
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDouble() throws {
        let json = "1.5"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.double, try bsonReader.readBsonType())
        XCTAssertEqual(1.5, try bsonReader.readDouble(), accuracy: 0)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testHexData() throws {
        let expectedBytes: [Byte] = [0x01, 0x23]
        let json = "HexData(0, \"0123\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(expectedBytes, binary.data)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testHexDataWithNew() throws {
        let expectedBytes: [Byte] = [0x01, 0x23]
        let json = "new HexData(0, \"0123\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(expectedBytes, binary.data)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testInt32() throws {
        let json = "123"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual(123, try bsonReader.readInt32())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testInt64() throws {
        let json = String(Int64.max)
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.int64, try bsonReader.readBsonType())
        XCTAssertEqual(Int64.max, try bsonReader.readInt64())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testNumberLongExtendedJson() throws {
        let json = "{\"$numberLong\":\"123\"}"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.int64, try bsonReader.readBsonType())
        XCTAssertEqual(123, try bsonReader.readInt64())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testNumberLong() throws {
        let jsonTexts = [
            "NumberLong(123)",
            "NumberLong(\"123\")",
            "new NumberLong(123)",
            "new NumberLong(\"123\")"
        ]
        for json in jsonTexts {
            bsonReader = JsonReader(json: json)
            XCTAssertEqual(.int64, try bsonReader.readBsonType())
            XCTAssertEqual(123, try bsonReader.readInt64())
            XCTAssertEqual(.done, bsonReader.state)
        }
    }


    public func testNumberInt() throws {
        let jsonTexts = [
            "NumberInt(123)",
            "NumberInt(\"123\")",
            "new NumberInt(123)",
            "new NumberInt(\"123\")"
        ]
        for json in jsonTexts {
            bsonReader = JsonReader(json: json)
            XCTAssertEqual(.int32, try bsonReader.readBsonType())
            XCTAssertEqual(123, try bsonReader.readInt32())
            XCTAssertEqual(.done, bsonReader.state)
        }
    }


    public func testDecimal128StringConstructor() throws {
        let json = "NumberDecimal(\"314E-2\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.decimal128, try bsonReader.readBsonType())
        XCTAssertEqual(Decimal(string: "314E-2"), try bsonReader.readDecimal())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDecimal128Int32Constructor() throws {
        let json = "NumberDecimal(\(Int32.max))"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.decimal128, try bsonReader.readBsonType())
        XCTAssertEqual(Decimal(Int32.max), try bsonReader.readDecimal())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDecimal128Int64Constructor() throws {
        let json = "NumberDecimal(\(Int64.max))"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.decimal128, try bsonReader.readBsonType())
        XCTAssertEqual(Decimal(Int64.max), try bsonReader.readDecimal())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDecimal128DoubleConstructor() throws {
        let json = "NumberDecimal(\(1.0))"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.decimal128, try bsonReader.readBsonType())
        XCTAssertEqual(Decimal(string: "1"), try bsonReader.readDecimal())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDecimal128BooleanConstructor() throws {
        let json = "NumberDecimal(true)"
        bsonReader = JsonReader(json: json)
        XCTAssertThrowsError(try bsonReader.readBsonType())
    }


    public func testDecimal128WithNew() throws {
        let json = "new NumberDecimal(\"314E-2\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.decimal128, try bsonReader.readBsonType())
        XCTAssertEqual(Decimal(string: "314E-2"), try bsonReader.readDecimal())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testDecimal128ExtendedJson() throws {
        let json = "{\"$numberDecimal\":\"314E-2\"}"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.decimal128, try bsonReader.readBsonType())
        XCTAssertEqual(Decimal(string: "314E-2"), try bsonReader.readDecimal())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testJavaScript() throws {
        let json = "{ \"$code\" : \"function f() throws { return 1 }\" }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.javascript, try bsonReader.readBsonType())
        XCTAssertEqual("function f() throws { return 1 }", try bsonReader.readJavaScript())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testJavaScriptWithScope() throws {
        let json = "{\"codeWithScope\": { \"$code\" : \"function f() throws { return n }\", \"$scope\" : { \"n\" : 1 } } }"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        XCTAssertEqual(.javascriptWithScope, try bsonReader.readBsonType())
        XCTAssertEqual("codeWithScope", try bsonReader.readName())
        XCTAssertEqual("function f() throws { return n }", try bsonReader.readJavaScriptWithScope())
        try bsonReader.readStartDocument()
        XCTAssertEqual(.int32, try bsonReader.readBsonType())
        XCTAssertEqual("n", try bsonReader.readName())
        XCTAssertEqual(1, try bsonReader.readInt32())
        try bsonReader.readEndDocument()
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testMaxKey() throws {
        for maxKeyJson in ["{ \"$maxKey\" : 1 }", "MaxKey", "MaxKey()", "new MaxKey", "new MaxKey()"] {
            let json = "{ maxKey : " + maxKeyJson + " }"
            bsonReader = JsonReader(json: json)
            try bsonReader.readStartDocument()
            XCTAssertEqual("maxKey", try bsonReader.readName())
            XCTAssertEqual(.maxKey, bsonReader.currentBsonType)
            try bsonReader.readMaxKey()
            try bsonReader.readEndDocument()
            XCTAssertEqual(.done, bsonReader.state)
        }
    }


    public func testMinKey() throws {
        for minKeyJson in ["{ \"$minKey\" : 1 }", "MinKey", "MinKey()", "new MinKey", "new MinKey()"] {
            let json = "{ minKey : " + minKeyJson + " }"
            bsonReader = JsonReader(json: json)
            try bsonReader.readStartDocument()
            XCTAssertEqual("minKey", try bsonReader.readName())
            XCTAssertEqual(.minKey, bsonReader.currentBsonType)
            try bsonReader.readMinKey()
            try bsonReader.readEndDocument()
            XCTAssertEqual(.done, bsonReader.state)
        }
    }


    public func testNestedArray() throws {
        let json = "{ \"a\" : [1, 2] }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        try bsonReader.readStartDocument()
        XCTAssertEqual(.array, try bsonReader.readBsonType())
        XCTAssertEqual("a", try bsonReader.readName())
        try bsonReader.readStartArray()
        XCTAssertEqual(1, try bsonReader.readInt32())
        XCTAssertEqual(2, try bsonReader.readInt32())
        try bsonReader.readEndArray()
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testNestedDocument() throws {
        let json = "{ \"a\" : { \"b\" : 1, \"c\" : 2 } }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        try bsonReader.readStartDocument()
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        XCTAssertEqual("a", try bsonReader.readName())
        try bsonReader.readStartDocument()
        XCTAssertEqual("b", try bsonReader.readName())
        XCTAssertEqual(1, try bsonReader.readInt32())
        XCTAssertEqual("c", try bsonReader.readName())
        XCTAssertEqual(2, try bsonReader.readInt32())
        try bsonReader.readEndDocument()
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)

    }


    public func testNull() throws {
        let json = "null"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.null, try bsonReader.readBsonType())
        try bsonReader.readNull()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testObjectIdShell() throws {
        let json = "ObjectId(\"4d0ce088e447ad08b4721a37\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.objectId, try bsonReader.readBsonType())
        let objectId = try bsonReader.readObjectId()
        XCTAssertEqual("4d0ce088e447ad08b4721a37", objectId.asHexString)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testObjectIdWithNew() throws {
        let json = "new ObjectId(\"4d0ce088e447ad08b4721a37\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.objectId, try bsonReader.readBsonType())
        let objectId = try bsonReader.readObjectId()
        XCTAssertEqual("4d0ce088e447ad08b4721a37", objectId.asHexString)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testObjectIdStrict() throws {
        let json = "{ \"$oid\" : \"4d0ce088e447ad08b4721a37\" }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.objectId, try bsonReader.readBsonType())
        let objectId = try bsonReader.readObjectId()
        XCTAssertEqual("4d0ce088e447ad08b4721a37", objectId.asHexString)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testObjectIdTenGen() throws {
        let json = "ObjectId(\"4d0ce088e447ad08b4721a37\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.objectId, try bsonReader.readBsonType())
        let objectId = try bsonReader.readObjectId()
        XCTAssertEqual("4d0ce088e447ad08b4721a37", objectId.asHexString)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testRegularExpressionShell() throws {
        let json = "/pattern/imxs"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.regularExpression, try bsonReader.readBsonType())
        let regex = try bsonReader.readRegularExpression()
        XCTAssertEqual("pattern", regex.pattern)
        XCTAssertEqual("imsx", regex.options)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testRegularExpressionStrict() throws {
        let json = "{ \"$regex\" : \"pattern\", \"$options\" : \"imxs\" }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.regularExpression, try bsonReader.readBsonType())
        let regex = try bsonReader.readRegularExpression()
        XCTAssertEqual("pattern", regex.pattern)
        XCTAssertEqual("imsx", regex.options)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testRegularExpressionCanonical() throws {
        let json = "{ \"$regularExpression\" : { \"pattern\" : \"pattern\", \"options\" : \"imxs\" }}"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.regularExpression, try bsonReader.readBsonType())
        let regex = try bsonReader.readRegularExpression()
        XCTAssertEqual("pattern", regex.pattern)
        XCTAssertEqual("imsx", regex.options)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testRegularExpressionQuery() throws {
        let json = "{ \"$regex\" : { \"$regularExpression\" : { \"pattern\" : \"pattern\", \"options\" : \"imxs\" }}}"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        let regex = try bsonReader.readRegularExpression(name: "$regex")
        XCTAssertEqual("pattern", regex.pattern)
        XCTAssertEqual("imsx", regex.options)
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testRegularExpressionQueryShell() throws {
        let json = "{ \"$regex\" : /pattern/imxs}"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        let regex = try bsonReader.readRegularExpression(name: "$regex")
        XCTAssertEqual("pattern", regex.pattern)
        XCTAssertEqual("imsx", regex.options)
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testString() throws {
        var str = "abc"
        var json = "\"\(str)\""
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.string, try bsonReader.readBsonType())
        XCTAssertEqual(str, try bsonReader.readString())
        XCTAssertEqual(.done, bsonReader.state)

        str = "𑯸👜"
        json = "\"\(str)\""
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.string, try bsonReader.readBsonType())
        XCTAssertEqual(str, try bsonReader.readString())
        XCTAssertEqual(.done, bsonReader.state)

        str = "\\u{1189B}\\u{1F45C}"
        json = "\"\(str)\""
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.string, try bsonReader.readBsonType())
        XCTAssertEqual("\u{1189B}\u{1F45C}", try bsonReader.readString())
        XCTAssertEqual(.done, bsonReader.state)

        str = "快速的棕色狐狸"
        json = "\"\(str)\""
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.string, try bsonReader.readBsonType())
        XCTAssertEqual(str, try bsonReader.readString())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testStringEmpty() throws {
        let json = "\"\""
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.string, try bsonReader.readBsonType())
        XCTAssertEqual("", try bsonReader.readString())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testSymbol() throws {
        let json = "{ \"$symbol\" : \"symbol\" }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.symbol, try bsonReader.readBsonType())
        XCTAssertEqual("symbol", try bsonReader.readSymbol())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testTimestampStrict() throws {
        let json = "{ \"$timestamp\" : { \"t\" : 1234, \"i\" : 1 } }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.timestamp, try bsonReader.readBsonType())
        XCTAssertEqual(BsonTimestamp(seconds: 1234, increment: 1), try bsonReader.readTimestamp())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testTimestampStrictWithOutOfOrderFields() throws {
        let json = "{ \"$timestamp\" : { \"i\" : 1, \"t\" : 1234 } }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.timestamp, try bsonReader.readBsonType())
        XCTAssertEqual(BsonTimestamp(seconds: 1234, increment: 1), try bsonReader.readTimestamp())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testTimestampShell() throws {
        let json = "Timestamp(1234, 1)"
        bsonReader = JsonReader(json: json)

        XCTAssertEqual(.timestamp, try bsonReader.readBsonType())
        XCTAssertEqual(BsonTimestamp(seconds: 1234, increment: 1), try bsonReader.readTimestamp())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testUndefined() throws {
        let json = "undefined"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.undefined, try bsonReader.readBsonType())
        try bsonReader.readUndefined()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testUndefinedExtended() throws {
        let json = "{ \"$undefined\" : true }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.undefined, try bsonReader.readBsonType())
        try bsonReader.readUndefined()
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testClosedState() throws {
        bsonReader = JsonReader(json: "")
        bsonReader.close()
        XCTAssertThrowsError(try bsonReader.readBinaryData())
    }

    public func testEndOfFile0() throws {
        let json = "{"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        try bsonReader.readStartDocument()
        XCTAssertThrowsError(try bsonReader.readBsonType())
    }

    public func testEndOfFile1() throws {
        let json = "{ test : "
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.document, try bsonReader.readBsonType())
        try bsonReader.readStartDocument()
        XCTAssertThrowsError(try bsonReader.readBsonType())
    }


    public func testLegacyBinary() throws {
        let json = "{ \"$binary\" : \"AQID\", \"$type\" : \"0\" }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(.binary, binary.type)
        XCTAssertEqual([1, 2, 3], binary.data)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testLegacyBinaryWithNumericType() throws {
        let json = "{ \"$binary\" : \"AQID\", \"$type\" : 0 }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(.binary, binary.type)
        XCTAssertEqual([1, 2, 3], binary.data)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testLegacyUserDefinedBinary() throws {
        let json = "{ \"$binary\" : \"AQID\", \"$type\" : \"80\" }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(.userDefined, binary.type)
        XCTAssertEqual([1, 2, 3], binary.data)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testLegacyUserDefinedBinaryWithKeyOrderReversed() throws {
        let json = "{ \"$type\" : \"80\", \"$binary\" : \"AQID\" }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(.userDefined, binary.type)
        XCTAssertEqual([1, 2, 3], binary.data)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testLegacyUserDefinedBinaryWithNumericType() throws {
        let json = "{ \"$binary\" : \"AQID\", \"$type\" : 128 }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(.userDefined, binary.type)
        XCTAssertEqual([1, 2, 3], binary.data)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testCanonicalExtendedJsonBinary() throws {
        let json = "{ \"$binary\" : { \"base64\" : \"AQID\", \"subType\" : \"80\" } }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(.userDefined, binary.type)
        XCTAssertEqual([1, 2, 3], binary.data)
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testCanonicalExtendedJsonBinaryWithKeysReversed() throws {
        let json = "{ \"$binary\" : { \"subType\" : \"80\", \"base64\" : \"AQID\" } }"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(.userDefined, binary.type)
        XCTAssertEqual([1, 2, 3], binary.data)
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testCanonicalExtendedJsonBinaryWithIncorrectFirstKey() throws {
        let json = "{ \"$binary\" : { \"badKey\" : \"80\", \"base64\" : \"AQID\" } }"
        bsonReader = JsonReader(json: json)
        XCTAssertThrowsError(try bsonReader.readBsonType())
    }


    public func testInfinity() throws {
        let json = "{ \"value\" : Infinity }"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        XCTAssertEqual(.double, try bsonReader.readBsonType())
        try bsonReader.readName()
        XCTAssertEqual(Double.infinity, try bsonReader.readDouble())
    }


    public func testNaN() throws {
        let json = "{ \"value\" : NaN }"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        XCTAssertEqual(.double, try bsonReader.readBsonType())
        try bsonReader.readName()
        XCTAssertTrue(try bsonReader.readDouble().isNaN)
    }


    public func testBinData() throws {
        let json = "{ \"a\" : BinData(3, AQID) }"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(3, binary.type.rawValue)
        XCTAssertEqual([1, 2, 3], binary.data)
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testBinDataUserDefined() throws {
        let json = "{ \"a\" : BinData(128, AQID) }"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(.userDefined, binary.type)
        XCTAssertEqual([1, 2, 3], binary.data)
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testBinDataWithNew() throws {
        let json = "{ \"a\" : new BinData(3, AQID) }"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(3, binary.type.rawValue)
        XCTAssertEqual([1, 2, 3], binary.data)
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testBinDataQuoted() throws {
        let json = "{ \"a\" : BinData(3, \"AQIDBA==\") }"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        XCTAssertEqual(.binary, try bsonReader.readBsonType())
        let binary = try bsonReader.readBinaryData()
        XCTAssertEqual(3, binary.type.rawValue)
        XCTAssertEqual([1, 2, 3, 4], binary.data)
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testDateWithNumbers() throws {
        let json = "new Date(1988, 06, 13 , 22 , 1)"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertEqual(584834460000, try bsonReader.readDateTime())
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testDateTimeConstructorWithNew() throws {
        let json = "new Date(\"Sat Jul 13 2013 11:10:05 UTC\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertEqual(1373713805000, try bsonReader.readDateTime())
        XCTAssertEqual(.done, bsonReader.state)
    }


    public func testEmptyDateTimeConstructorWithNew() throws {
        let currentTime = Date().timeIntervalSince1970
        let json = "new Date()"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertTrue(try bsonReader.readDateTime() >= Int64(currentTime * 1000))
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testDateTimeWithOutNew() throws {
        let currentTime = currentTimeWithoutMillis()
        let json = "Date()"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.string, try bsonReader.readBsonType())
        XCTAssertTrue(dateStringToTime(date: try bsonReader.readString()) >= currentTime)
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testDateTimeWithOutNewContainingJunk() throws {
        let currentTime = currentTimeWithoutMillis()
        let json = "Date({ok: 1}, 1234)"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.string, try bsonReader.readBsonType())
        XCTAssertTrue(dateStringToTime(date: try bsonReader.readString()) >= currentTime)
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testEmptyISODateTimeConstructorWithNew() throws {
        let currentTime = Date().timeIntervalSince1970
        let json = "new ISODate()"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertTrue(try bsonReader.readDateTime() >= Int64(currentTime * 1000))
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testEmptyISODateTimeConstructor() throws {
        let currentTime = Date().timeIntervalSince1970
        let json = "ISODate()"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dateTime, try bsonReader.readBsonType())
        XCTAssertTrue(try bsonReader.readDateTime() >= Int64(currentTime * 1000))
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testRegExp() throws {
        let json = "RegExp(\"abc\",\"im\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.regularExpression, try bsonReader.readBsonType())
        let regularExpression = try bsonReader.readRegularExpression()
        XCTAssertEqual("abc", regularExpression.pattern)
        XCTAssertEqual("im", regularExpression.options)
    }

    public func testRegExpWithNew() throws {
        let json = "new RegExp(\"abc\",\"im\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.regularExpression, try bsonReader.readBsonType())
        let regularExpression = try bsonReader.readRegularExpression()
        XCTAssertEqual("abc", regularExpression.pattern)
        XCTAssertEqual("im", regularExpression.options)
    }

    public func testSkip() throws {
        let json = "{ \"a\" : 2 }"
        bsonReader = JsonReader(json: json)
        try bsonReader.readStartDocument()
        try bsonReader.readBsonType()
        try bsonReader.skipName()
        try bsonReader.skipValue()
        XCTAssertEqual(.endOfDocument, try bsonReader.readBsonType())
        try bsonReader.readEndDocument()
        XCTAssertEqual(.done, bsonReader.state)
    }

    public func testDBPointer() throws {
        let json = "DBPointer(\"b\",\"5209296cd6c4e38cf96fffdc\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dbPointer, try bsonReader.readBsonType())
        let dbPointer = try bsonReader.readDBPointer()
        XCTAssertEqual("b", dbPointer.namespace)
        XCTAssertEqual(try ObjectId(hexString: "5209296cd6c4e38cf96fffdc"), dbPointer.id)
    }

    public func testDBPointerWithNew() throws {
        let json = "new DBPointer(\"b\",\"5209296cd6c4e38cf96fffdc\")"
        bsonReader = JsonReader(json: json)
        XCTAssertEqual(.dbPointer, try bsonReader.readBsonType())
        let dbPointer = try bsonReader.readDBPointer()
        XCTAssertEqual("b", dbPointer.namespace)
        XCTAssertEqual(try ObjectId(hexString: "5209296cd6c4e38cf96fffdc"), dbPointer.id)
    }

    private func dateStringToTime(date: String) -> Int64 {
        let df = DateFormatter()
        df.dateFormat = "EEE MMM dd yyyy HH:mm:ss z"
        return Int64(df.date(from: date)!.timeIntervalSince1970 * 1000)
    }

    private func currentTimeWithoutMillis() -> Int64 {
        let currentTime = Date().timeIntervalSince1970
        return Int64(currentTime - (currentTime.truncatingRemainder(dividingBy: 1000)))
    }
}
