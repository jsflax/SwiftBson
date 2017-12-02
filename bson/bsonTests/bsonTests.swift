//
//  bsonTests.swift
//  bsonTests
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import XCTest
@testable import bson

class bsonTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    public let defaultBsonTypeClassMap: [BsonType: BsonValue.Type.Type] = [
        .null: BsonNull.Type.self,
        .array: BsonArray.Type.self,
        .binary: BsonBinary.Type.self,
        .boolean: BsonBool.Type.self,
        .dateTime: BsonDateTime.Type.self,
        .dbPointer: BsonDbPointer.Type.self,
        .document: BsonDocument.Type.self,
        .double: BsonDouble.Type.self,
        .int32: BsonInt32.Type.self,
        .int64: BsonInt64.Type.self,
        .decimal128: BsonDecimal.Type.self,
        .maxKey: BsonMaxKey.Type.self,
        .minKey: BsonMinKey.Type.self,
        .javascript: BsonJavascript.Type.self,
        .javascriptWithScope: BsonJavascriptWithScope.Type.self,
        .objectId: BsonObjectId.Type.self,
        .regularExpression: BsonRegularExpression.Type.self,
        .string: BsonString.Type.self,
        .symbol: BsonSymbol.Type.self,
        .timestamp: BsonTimestamp.Type.self,
        .undefined: BsonUndefined.Type.self
    ]

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let mirrInst = Mirror(reflecting: BsonArray())

        let mirr = Mirror(reflecting: BsonArray.self)
        let oid = ObjectIdentifier(BsonArray.Type.self)

        let mirr2 = Mirror(reflecting: BsonInt64.self)
        let oid2 = ObjectIdentifier(BsonInt64.Type.self)

        XCTAssertTrue(mirr.subjectType == BsonArray.Type.self)
        XCTAssertTrue(oid == ObjectIdentifier(mirr.subjectType))

        XCTAssertFalse(mirr2.subjectType == BsonArray.Type.self)
        XCTAssertFalse(oid2 == ObjectIdentifier(mirr.subjectType))

        let type = defaultBsonTypeClassMap[.array]
        XCTAssertTrue(mirr.subjectType == type)
        XCTAssertTrue(mirrInst.subjectType == type)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
