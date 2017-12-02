//
//  JsonScannerTest.swift
//  bsonTests
//
//  Created by Jason Flax on 11/27/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

import XCTest
@testable import bson

class JsonScannerTest: XCTestCase {
    func testEndOfFile() throws {
        let json = "\t "
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.endOfFile, token.type)
        XCTAssertEqual("<eof>", try token.valueAs(type: String.self))
    }

    public func testBeginObject() throws {
        let json = "\t {x"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.beginObject, token.type)
        XCTAssertEqual("{", try token.valueAs(type: String.self))
        XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func testEndObject() throws {
        let json = "\t }x"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.endObject, token.type)
        XCTAssertEqual("}", try token.valueAs(type: String.self))
        XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func testBeginArray() throws {
        let json = "\t [x"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.beginArray, token.type)
        XCTAssertEqual("[", try token.valueAs())
        XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func testEndArray() throws {
        let json = "\t ]x"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.endArray, token.type)
        XCTAssertEqual("]", try token.valueAs())
        XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func testParentheses() throws {
    let json = "\t (jj)x"
    let buffer = JsonBuffer(buffer: json)
    let scanner = JsonScanner(buffer: buffer)
    var token = try scanner.nextToken()
    XCTAssertEqual(.leftParen, token.type)
    XCTAssertEqual("(", try token.valueAs())
    token = try scanner.nextToken()
    token = try scanner.nextToken()
    XCTAssertEqual(.rightParen, token.type)
    XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }



    public func testNameSeparator() throws {
    let json = "\t :x"
    let buffer = JsonBuffer(buffer: json)
    let scanner = JsonScanner(buffer: buffer)
    let token = try scanner.nextToken()
    XCTAssertEqual(.colon, token.type)
    XCTAssertEqual(":", try token.valueAs())
    XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func testValueSeparator() throws {
    let json = "\t ,x"
    let buffer = JsonBuffer(buffer: json)
    let scanner = JsonScanner(buffer: buffer)
    let token = try scanner.nextToken()
    XCTAssertEqual(.comma, token.type)
    XCTAssertEqual(",", try token.valueAs())
    XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func testEmptyString() throws {
    let json = "\t \"\"x"
    let buffer = JsonBuffer(buffer: json)
    let scanner = JsonScanner(buffer: buffer)
    let token = try scanner.nextToken()
    XCTAssertEqual(.string, token.type)
    XCTAssertEqual("", try token.valueAs())
    XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func test1CharacterString() throws {
    let json = "\t \"1\"x"
    let buffer = JsonBuffer(buffer: json)
    let scanner = JsonScanner(buffer: buffer)
    let token = try scanner.nextToken()
    XCTAssertEqual(.string, token.type)
    XCTAssertEqual("1", try token.valueAs())
    XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func test2CharacterString() throws {
    let json = "\t \"12\"x"
    let buffer = JsonBuffer(buffer: json)
    let scanner = JsonScanner(buffer: buffer)
    let token = try scanner.nextToken()
    XCTAssertEqual(.string, token.type)
    XCTAssertEqual("12", try token.valueAs())
    XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func test3CharacterString() throws {
    let json = "\t \"123\"x"
    let buffer = JsonBuffer(buffer: json)
    let scanner = JsonScanner(buffer: buffer)
    let token = try scanner.nextToken()
    XCTAssertEqual(.string, token.type)
    XCTAssertEqual("123", try token.valueAs())
    XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }


    public func testEscapeSequences() throws {
        let json = "\t \"x\\\"\\\\\\/\\b\\f\\n\\r\\t\\u{0030}y\"x"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.string, token.type)
        XCTAssertEqual("x\"\\/\\b\\f\\n\\r\\t0y", try token.valueAs(type: String.self))
        XCTAssertEqual("x", UnicodeScalar(try buffer.read()))
    }



    public func testTrue() throws {
        let json = "\t true,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.unquotedString, token.type)
        XCTAssertEqual("true", try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusInfinity() throws {
        let json = "\t -Infinity]"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(-Double.infinity, try token.valueAs())
        XCTAssertEqual("]", UnicodeScalar(try buffer.read()))
    }


    public func testFalse() throws {
        let json = "\t false,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.unquotedString, token.type)
        XCTAssertEqual("false", try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testNull() throws {
        let json = "\t null,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.unquotedString, token.type)
        XCTAssertEqual("null", try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testUndefined() throws {
        let json = "\t undefined,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.unquotedString, token.type)
        XCTAssertEqual("undefined", try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testUnquotedStringWithSeparator() throws {
        let json = "\t name123:1"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.unquotedString, token.type)
        XCTAssertEqual("name123", try token.valueAs())
        XCTAssertEqual(":", UnicodeScalar(try buffer.read()))
    }


    public func testUnquotedString() throws {
        let json = "name123"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.unquotedString, token.type)
        XCTAssertEqual("name123", try token.valueAs())
        XCTAssertEqual(-1, try buffer.read())
    }


    public func testZero() throws {
        let json = "\t 0,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.int32, token.type)
        XCTAssertEqual(0, try token.valueAs(type: Int32.self))
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusZero() throws {
        let json = "\t -0,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.int32, token.type)
        XCTAssertEqual(-0, try token.valueAs(type: Int32.self))
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testOne() throws {
        let json = "\t 1,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.int32, token.type)
        XCTAssertEqual(1, try token.valueAs(type: Int32.self))
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusOne() throws {
        let json = "\t -1,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.int32, token.type)
        XCTAssertEqual(-1, try token.valueAs(type: Int32.self))
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testTwelve() throws {
        let json = "\t 12,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.int32, token.type)
        XCTAssertEqual(12, try token.valueAs(type: Int32.self))
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusTwelve() throws {
        let json = "\t -12,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.int32, token.type)
        XCTAssertEqual(-12, try token.valueAs(type: Int32.self))
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testZeroPointZero() throws {
        let json = "\t 0.0,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(0.0, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusZeroPointZero() throws {
        let json = "\t -0.0,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(-0.0, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testZeroExponentOne() throws {
        let json = "\t 0e1,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(0e1, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusZeroExponentOne() throws {
        let json = "\t -0e1,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(-0e1, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testZeroExponentMinusOne() throws {
        let json = "\t 0e-1,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(0e-1, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusZeroExponentMinusOne() throws {
        let json = "\t -0e-1,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(-0e-1, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testOnePointTwo() throws {
        let json = "\t 1.2,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(1.2, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusOnePointTwo() throws {
        let json = "\t -1.2,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(-1.2, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testOneExponentTwelve() throws {
        let json = "\t 1e12,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(1e12, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusZeroExponentTwelve() throws {
        let json = "\t -1e12,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(-1e12, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testOneExponentMinuesTwelve() throws {
        let json = "\t 1e-12,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(1e-12, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testMinusZeroExponentMinusTwelve() throws {
        let json = "\t -1e-12,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.double, token.type)
        XCTAssertEqual(-1e-12, try token.valueAs())
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testRegularExpressionEmpty() throws {
        let json = "\t //,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.regularExpression, token.type)

        let regularExpression = try token.valueAs(type: BsonRegularExpression.self)

        XCTAssertEqual("", regularExpression.pattern)
        XCTAssertEqual("", regularExpression.options)
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testRegularExpressionPattern() throws {
        let json = "\t /pattern/,"

        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.regularExpression, token.type)
        XCTAssertEqual("pattern", try token.valueAs(type: BsonRegularExpression.self).pattern)
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testRegularExpressionPatternAndOptions() throws {
        let json = "\t /pattern/im,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.regularExpression, token.type)

        let regularExpression = try token.valueAs(type: BsonRegularExpression.self)
        XCTAssertEqual("pattern", regularExpression.pattern)
        XCTAssertEqual("im", regularExpression.options)
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }


    public func testRegularExpressionPatternAndEscapeSequence() throws {
        let json = "\t /patte\\.n/,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        let token = try scanner.nextToken()
        XCTAssertEqual(.regularExpression, token.type)
        XCTAssertEqual("patte\\.n", try token.valueAs(type: BsonRegularExpression.self).pattern)
        XCTAssertEqual(",", UnicodeScalar(try buffer.read()))
    }

    public func testInvalidRegularExpression() throws {
        let json = "\t /pattern/nsk,"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        XCTAssertThrowsError(try scanner.nextToken())
    }

    public func testInvalidRegularExpressionNoEnd() throws {
        let json = "/b"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        XCTAssertThrowsError(try scanner.nextToken())
    }

    public func testInvalidInput() throws {
        let json = "\t &&"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        XCTAssertThrowsError(try scanner.nextToken())
    }

    public func testInvalidNumber() throws {
        let json = "\t 123a]"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        XCTAssertThrowsError(try scanner.nextToken())
    }

    public func testInvalidInfinity() throws {
        let json = "\t -Infinnity]"
        let buffer = JsonBuffer(buffer: json)
        let scanner = JsonScanner(buffer: buffer)
        XCTAssertThrowsError(try scanner.nextToken())
    }
}
