//
//  JsonReader.swift
//  bson
//
//  Created by Jason Flax on 11/26/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class JsonReader: AbstractBsonReader {
    var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey : Any]

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {

    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {

    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        
    }

    private let scanner: JsonScanner

    var currentName: String = ""
    private var pushedToken: JsonToken?
    private var currentValue: Any?
    internal var mark: BsonReaderMark?

    var state: State
    var context: Context
    var currentBsonType: BsonType = .null
    var isClosed: Bool = false

    /**
     * Constructs a new instance with the given JSON string.
     *
     * @param json     A string representation of a JSON.
     */
    public init(json: String) {
        self.scanner = JsonScanner(json: json)
        self.context = JsonContext(parentContext: nil, contextType: .topLevel)
        self.state = .initial
        self.currentName = ""
    }

    func doReadBinaryData() -> BsonBinary {
        return currentValue as! BsonBinary
    }

    func doPeekBinarySubType() -> Byte {
        return doReadBinaryData().type.rawValue
    }

    func doPeekBinarySize() -> Int {
        return doReadBinaryData().data.count
    }

    func doReadBoolean() -> Bool {
        return currentValue as! Bool
    }

    func readBsonType() throws -> BsonType {
        if isClosed {
            throw RuntimeError.illegalState("This instance has been closed")
        }
        if state == .initial || state == .done || state == .scopeDocument {
            // in JSON the top level value can be of any type so fall through
            state = .type
        }
        if state != .type {
            try throwInvalidState(validStates: .type)
        }

        if context.contextType == .document {
            let nameToken = try popToken()
            switch nameToken.type {
            case .string, .unquotedString:
                currentName = try nameToken.valueAs(type: String.self)
            case .endObject:
                state = .endOfDocument
                return .endOfDocument
            default:
                throw JSONError.parse("JSON reader was expecting a name but found '\(nameToken.value)'.")
            }

            let colonToken = try popToken()
            if colonToken.type != .colon {
                throw JSONError.parse(
                    "JSON reader was expecting ':' but found '\(colonToken.value)'.")
            }
        }

        let token = try popToken()
        if context.contextType == .array && token.type == .endArray {
            state = .endOfArray
            return .endOfDocument
        }

        var noValueFound = false
        switch token.type {
        case .beginArray:
            currentBsonType = .array
        case .beginObject:
            try visitExtendedJson()
        case .double:
            currentBsonType = .double
            currentValue = token.value
        case .endOfFile: currentBsonType = .endOfDocument
        case .int32:
            currentBsonType = .int32
            currentValue = token.value
        case .int64:
            currentBsonType = .int64
            currentValue = token.value
        case .regularExpression:
            currentBsonType = .regularExpression
            currentValue = token.value
        case .string:
            currentBsonType = .string
            currentValue = token.value
        case .unquotedString:
            let value = try token.valueAs(type: String.self)

            switch value {
            case "false", "true":
                currentBsonType = .boolean
                currentValue = Bool(value)!
            case "Infinity":
                currentBsonType = .double
                currentValue = Double.infinity
            case "NaN":
                currentBsonType = .double
                currentValue = Double.nan
            case "null":
                currentBsonType = .null
            case "undefined":
                currentBsonType = .undefined
            case "MinKey":
                try visitEmptyConstructor()
                currentBsonType = .minKey
                currentValue = MinKey()
            case "MaxKey":
                try visitEmptyConstructor()
                currentBsonType = .maxKey
                currentValue = MaxKey()
            case "BinData":
                currentBsonType = .binary
                currentValue = try visitBinDataConstructor()
            case "Date":
                currentValue = try visitDateTimeConstructorWithOutNew()
                currentBsonType = .string
            case "HexData":
                currentBsonType = .binary
                currentValue = try visitHexDataConstructor()
            case "ISODate":
                currentBsonType = .dateTime
                currentValue = try visitISODateTimeConstructor()
            case "NumberInt":
                currentBsonType = .int32
                currentValue = try visitNumberIntConstructor()
            case "NumberLong":
                currentBsonType = .int64
                currentValue = try visitNumberLongConstructor()
            case "NumberDecimal":
                currentBsonType = .decimal128
                currentValue = try visitNumberDecimalConstructor()
            case "ObjectId":
                currentBsonType = .objectId
                currentValue = try visitObjectIdConstructor()
            case "Timestamp":
                currentBsonType = .timestamp
                currentValue = try visitTimestampConstructor()
            case "RegExp":
                currentBsonType = .regularExpression
                currentValue = try visitRegularExpressionConstructor()
            case "DBPointer":
                currentBsonType = .dbPointer
                currentValue = try visitDBPointerConstructor()
            case "UUID", "GUID", "CSUUID", "JUUID", "PYUUID", "PYGUID":
                currentBsonType = .binary
                currentValue = try visitUUIDConstructor(uuidConstructorName: value)
            case "new": try visitNew()
            default:
                noValueFound = true
            }
        default:
            noValueFound = true;
            break;
        }

        if noValueFound {
            throw JSONError.parse("JSON reader was expecting a value but found '\(token.value)'.")
        }

        if context.contextType == .array || context.contextType == .document {
            let commaToken = try self.popToken()
            if commaToken.type != .comma {
                try self.pushToken(token: commaToken)
            }
        }

        switch context.contextType {
        case .array, .javascriptWithScope, .topLevel: state = .value
        default: state = .name
        }

        return currentBsonType
    }

    func doReadDateTime() -> Int64 {
        return currentValue as! Int64
    }

    func doReadDouble() -> Double {
        return currentValue as! Double
    }

    func doReadEndArray() throws {
        context = context.parentContext!

        if context.contextType == .array || context.contextType == .document {
            let commaToken = try popToken()
            if commaToken.type != .comma {
                try self.pushToken(token: commaToken)
            }
        }
    }

    func doReadEndDocument() throws {
        guard let ctx = context.parentContext else {
            throw JSONError.parse("Unexpected end of document")
        }

        self.context = ctx

        if context.contextType == .scopeDocument {
            self.context = context.parentContext! // JavaScriptWithScope
            try self.verifyToken(expectedType: .endObject) // outermost closing bracket for JavaScriptWithScope
        }

        if self.context.contextType == .array || self.context.contextType == .document {
            let commaToken = try popToken()
            if commaToken.type != .comma {
                try self.pushToken(token: commaToken)
            }
        }
    }

    func doReadInt32() -> Int32 {
        return currentValue as! Int32
    }

    func doReadInt64() -> Int64 {
        return currentValue as! Int64
    }

    func doReadDecimal() -> Decimal {
        return currentValue as! Decimal
    }

    func doReadJavaScript() -> String {
        return currentValue as! String
    }

    func doReadJavaScriptWithScope() -> String {
        return currentValue as! String
    }

    func doReadMaxKey() {
    }

    func doReadMinKey() {
    }

    func doReadNull() {
    }

    func doReadObjectId() -> ObjectId {
        return currentValue as! ObjectId
    }

    func doReadRegularExpression() -> BsonRegularExpression {
        return currentValue as! BsonRegularExpression
    }

    func doReadDBPointer() -> BsonDbPointer {
        return currentValue as! BsonDbPointer
    }

    func doReadStartArray() {
        context = JsonContext(parentContext: context, contextType: .array)
    }

    func doReadStartDocument() {
        context = JsonContext(parentContext: context, contextType: .document)
    }

    func doReadString() -> String {
        return currentValue as! String
    }

    func doReadSymbol() -> String {
        return currentValue as! String
    }

    func doReadTimestamp() -> BsonTimestamp {
        return currentValue as! BsonTimestamp
    }

    func doReadUndefined() {
    }

    func doSkipName() throws {
    }

    func doSkipValue() throws {
        switch currentBsonType {
        case .array:
            try readStartArray()
            while try readBsonType() != .endOfDocument {
                try skipValue()
            }
            try readEndArray()
        case .binary: try readBinaryData()
        case .boolean: try readBoolean()
        case .dateTime: try readDateTime()
        case .document:
            try readStartDocument()
            while try readBsonType() != .endOfDocument {
                try skipName()
                try skipValue()
            }
            try readEndDocument()
        case .double: try readDouble()
        case .int32: try readInt32()
        case .int64: try readInt64()
        case .decimal128: try readDecimal()
        case .javascript: try readJavaScript()
        case .javascriptWithScope:
            try readJavaScriptWithScope();
            try readStartDocument();
            while try readBsonType() != .endOfDocument {
                try skipName()
                try skipValue()
            }
            try readEndDocument()
        case .maxKey: try readMaxKey()
        case .minKey: try readMinKey()
        case .null: try readNull()
        case .objectId: try readObjectId()
        case .regularExpression: try readRegularExpression()
        case .string: try readString()
        case .symbol: try readSymbol()
        case .timestamp: try readTimestamp()
        case .undefined: try readUndefined()
        default: break
        }
    }

    private func verifyToken(expectedType: JsonTokenType) throws {
        let token = try popToken()
        if expectedType != token.type {
            throw JSONError.parse(
                "JSON reader expected token type '\(expectedType)' but found '\(token.value)'.")
        }
    }

    private func verifyToken<T: Equatable>(expectedType: JsonTokenType, expectedValue: T) throws {
        let token = try popToken()
        if expectedType != token.type {
            throw JSONError.parse(
                "JSON reader expected token type '\(expectedType)' but found '\(token.value)'.")
        }
        if expectedValue != (try token.valueAs(type: T.self)) {
            throw JSONError.parse("JSON reader expected '\(expectedValue)' but found '\(token.value)'.")
        }
    }

    private func verifyString(expected: String) throws {
        let token = try popToken()
        let type = token.type
        let value = try token.valueAs(type: String.self)
        if type != .string && type != .unquotedString || expected != value {
            throw JSONError.parse("JSON reader expected '\(expected)' but found '\(token.value)'.")
        }
    }

    private func visitNew() throws {
        let typeToken = try self.popToken()
        if typeToken.type != .unquotedString {
            throw JSONError.parse(
                "JSON reader expected a type name but found '\(typeToken.value)'.")
        }

        let value = try typeToken.valueAs(type: String.self)

        switch value {
        case "MinKey":
            try visitEmptyConstructor()
            currentBsonType = .minKey
            currentValue = MinKey()
        case "MaxKey":
            try visitEmptyConstructor()
            currentBsonType = .maxKey
            currentValue = MaxKey()
        case "BinData":
            currentValue = try visitBinDataConstructor()
            currentBsonType = .binary
        case "Date":
            currentValue = try visitDateTimeConstructor()
            currentBsonType = .dateTime
        case "HexData":
            currentValue = try visitHexDataConstructor()
            currentBsonType = .binary
        case "ISODate":
            currentValue = try visitISODateTimeConstructor()
            currentBsonType = .dateTime
        case "NumberInt":
            currentValue = try visitNumberIntConstructor()
            currentBsonType = .int32
        case "NumberLong":
            currentValue = try visitNumberLongConstructor()
            currentBsonType = .int64
        case "NumberDecimal":
            currentValue = try visitNumberDecimalConstructor()
            currentBsonType = .decimal128
        case "ObjectId":
            currentValue = try visitObjectIdConstructor()
            currentBsonType = .objectId
        case "RegExp":
            currentValue = try visitRegularExpressionConstructor()
            currentBsonType = .regularExpression
        case "DBPointer":
            currentValue = try visitDBPointerConstructor()
            currentBsonType = .dbPointer
        case "UUID", "GUID", "CSUUID", "CSGUID", "JUUID", "JGUID", "PYUUID", "PYGUID":
            currentValue = try visitUUIDConstructor(uuidConstructorName: value)
        default:
            throw JSONError.parse("JSON reader expected a type name but found '\(value)'.")
        }
    }

    private func visitExtendedJson() throws {
        let nameToken = try popToken()
        let value = try nameToken.valueAs(type: String.self)
        let type = nameToken.type

        if type == .string || type == .unquotedString {
            switch value {
            case "$binary", "$type":
                currentValue = try self.visitBinDataExtendedJson(firstKey: value)
                if currentValue != nil {
                    currentBsonType = .binary
                    return
                }
            case "$regex", "$options":
                currentValue = try self.visitRegularExpressionExtendedJson(firstKey: value)
                if currentValue != nil {
                    currentBsonType = .regularExpression
                    return
                }
            case "$code":
                try visitJavaScriptExtendedJson()
                return
            case "$date":
                currentValue = try self.visitDateTimeExtendedJson()
                currentBsonType = .dateTime
                return
            case "$maxKey":
                currentValue = try self.visitMaxKeyExtendedJson()
                currentBsonType = .maxKey
                return
            case "$minKey":
                currentValue = try self.visitMinKeyExtendedJson()
                currentBsonType = .minKey
                return
            case "$oid":
                currentValue = try self.visitObjectIdExtendedJson()
                currentBsonType = .objectId
                return
            case "$regularExpression":
                currentValue = try visitNewRegularExpressionExtendedJson()
                currentBsonType = .regularExpression
                return
            case "$symbol":
                currentValue = try visitSymbolExtendedJson()
                currentBsonType = .symbol
                return
            case "$timestamp":
                currentValue = try visitTimestampExtendedJson()
                currentBsonType = .timestamp
                return
            case "$undefined":
                currentValue = try visitUndefinedExtendedJson()
                currentBsonType = .undefined
                return
            case "$numberLong":
                currentValue = try visitNumberLongExtendedJson();
                currentBsonType = .int64
                return
            case "$numberInt":
                currentValue = try visitNumberIntExtendedJson();
                currentBsonType = .int32
                return
            case "$numberDouble":
                currentValue = try visitNumberDoubleExtendedJson();
                currentBsonType = .double
                return
            case "$numberDecimal":
                currentValue = try visitNumberDecimalExtendedJson();
                currentBsonType = .decimal128
                return
            case "$dbPointer":
                currentValue = try visitDbPointerExtendedJson();
                currentBsonType = .dbPointer
                return
            default: break
            }
        }

        try pushToken(token: nameToken)
        currentBsonType = .document
    }

    private func visitEmptyConstructor() throws {
        let nextToken = try self.popToken()
        if nextToken.type == .leftParen {
            try verifyToken(expectedType: .rightParen)
        } else {
            try pushToken(token: nextToken)
        }
    }

    private func visitBinDataConstructor() throws -> BsonBinary {
        try verifyToken(expectedType: .leftParen)
        let subTypeToken = try self.popToken()
        if subTypeToken.type != .int32 {
            throw JSONError.parse("JSON reader expected a binary subtype but found '\(subTypeToken.value)'.")
        }
        try verifyToken(expectedType: .comma)
        let bytesToken = try self.popToken()
        if bytesToken.type != .unquotedString && bytesToken.type != .string {
            throw JSONError.parse("JSON reader expected a string but found '\(bytesToken.value)'.")
        }
        try verifyToken(expectedType: .rightParen)

        let bytes = try [Byte](base64Encoded: bytesToken.valueAs())
        let subType = BsonBinarySubType(rawValue: try subTypeToken.valueAs(type: Byte.self))!
        return BsonBinary(data: bytes, type: subType)
    }

    private func visitUUIDConstructor(uuidConstructorName: String) throws -> BsonBinary {
        try self.verifyToken(expectedType: .leftParen)
        let hexString = try readStringFromExtendedJson()
            .replacingOccurrences(of: "\\{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: "-", with: "")
        try self.verifyToken(expectedType: .rightParen)
        let bytes = try [Byte](fromHexEncodedString: hexString)
        var subType = BsonBinarySubType.uuidStandard
        if "UUID" != uuidConstructorName || "GUID" != uuidConstructorName {
            subType = .uuidLegacy
        }
        return BsonBinary(data: bytes, type: subType);
    }

    private func visitRegularExpressionConstructor() throws -> BsonRegularExpression {
        try self.verifyToken(expectedType: .leftParen)
        let pattern = try readStringFromExtendedJson()
        var options = ""
        let commaToken = try self.popToken()
        if commaToken.type == .comma {
            options = try readStringFromExtendedJson()
        } else {
            try self.pushToken(token: commaToken)
        }
        try self.verifyToken(expectedType: .rightParen)
        return BsonRegularExpression(pattern: pattern, options: options)
    }

    private func visitObjectIdConstructor() throws -> ObjectId {
        try self.verifyToken(expectedType: .leftParen)
        let objectId = try ObjectId(hexString: readStringFromExtendedJson())
        try self.verifyToken(expectedType: .rightParen)
        return objectId
    }

    private func visitTimestampConstructor() throws -> BsonTimestamp {
        try self.verifyToken(expectedType: .leftParen)
        let timeToken = try self.popToken()
        var time: Int32 = 0
        if timeToken.type != .int32 {
            throw JSONError.parse("JSON reader expected an integer but found '\(timeToken.value)'.")
        } else {
            time = try timeToken.valueAs()
        }
        try verifyToken(expectedType: .comma)
        let incrementToken = try self.popToken()
        var increment: Int32 = 0
        if incrementToken.type != .int32 {
            throw JSONError.parse("JSON reader expected an integer but found '\(timeToken.value)'.")
        } else {
            increment = try incrementToken.valueAs()
        }

        try self.verifyToken(expectedType: .rightParen)
        return BsonTimestamp(seconds: UInt(time), increment: UInt(increment));
    }

    private func visitDBPointerConstructor() throws -> BsonDbPointer {
        try self.verifyToken(expectedType: .leftParen)
        let namespace = try readStringFromExtendedJson()
        try self.verifyToken(expectedType: .comma)
        let id = try ObjectId(hexString: readStringFromExtendedJson())
        try self.verifyToken(expectedType: .rightParen)
        return BsonDbPointer(namespace: namespace, id: id)
    }

    private func visitNumberIntConstructor() throws -> Int32 {
        try self.verifyToken(expectedType: .leftParen)
        let valueToken = try self.popToken()
        var value: Int32 = 0
        if valueToken.type == .int32 {
            value = try valueToken.valueAs()
        } else if valueToken.type == .string {
            value = try Int32(valueToken.valueAs(type: String.self))!
        } else {
            throw JSONError.parse("JSON reader expected an integer or a string but found '\(valueToken.value)'.")
        }
        try self.verifyToken(expectedType: .rightParen)
        return value
    }

    private func visitNumberLongConstructor() throws -> Int64 {
        try self.verifyToken(expectedType: .leftParen)
        let valueToken = try self.popToken()
        var value: Int64 = 0
        if valueToken.type == .int32 || valueToken.type == .int64 {
            value = try valueToken.valueAs()
        } else if valueToken.type == .string {
            value = try Int64(valueToken.valueAs(type: String.self))!
        } else {
            throw JSONError.parse(
                "JSON reader expected an integer or a string but found '\(valueToken.value)'.")
        }
        try self.verifyToken(expectedType: .rightParen)
        return value
    }

    private func visitNumberDecimalConstructor() throws -> Decimal {
        try self.verifyToken(expectedType: .leftParen)
        let valueToken = try self.popToken()
        var value: Decimal = 0
        if valueToken.type == .int32 || valueToken.type == .int64
            || valueToken.type == .double {
            value = try valueToken.valueAs()
        } else if valueToken.type == .string {
            value = try Decimal(string: valueToken.valueAs())!
        } else {
            throw JSONError.parse("JSON reader expected a number or a string but found '\(valueToken.value)'.")
        }
        try self.verifyToken(expectedType: .rightParen)
        return value
    }

    private func visitISODateTimeConstructor() throws -> Int64 {
        try self.verifyToken(expectedType: .leftParen)

        let token = try self.popToken()
        if token.type == .rightParen {
            return Int64(Date().timeIntervalSince1970 * 1000)
        } else if token.type != .string {
            throw JSONError.parse("JSON reader expected a string but found '\(token.value)'.")
        }

        try self.verifyToken(expectedType: .rightParen);
        let patterns = ["yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ssz", "yyyy-MM-dd'T'HH:mm:ss.SSSz"]

        var s = try token.valueAs(type: String.self)

        if (s[s.index(before: s.endIndex)] == "Z") {
            s = s[s.startIndex ..< s.index(before: s.endIndex)] + "GMT-00:00"
        }

        for pattern in patterns {
            let formatter = DateFormatter()
            formatter.dateFormat = pattern
            if let date = formatter.date(from: s) {
                return Int64(date.timeIntervalSince1970 * 1000)
            }
        }
        throw JSONError.parse("Invalid date format.")
    }

    private func visitHexDataConstructor() throws -> BsonBinary {
        try self.verifyToken(expectedType: .leftParen)
        let subTypeToken = try self.popToken()
        if subTypeToken.type != .int32 {
            throw JSONError.parse(
                "JSON reader expected a binary subtype but found '\(subTypeToken.value)'.")
        }
        try self.verifyToken(expectedType: .comma);
        var hex = try readStringFromExtendedJson()
        try self.verifyToken(expectedType: .rightParen)

        if (hex.count & 1) != 0 {
            hex = "0" + hex
        }

        if let subType = try BsonBinarySubType(rawValue: subTypeToken.valueAs()) {
            return try BsonBinary.init(data: [Byte].init(fromHexEncodedString: hex),
                                       type: subType)
        }

        return try BsonBinary.init(data: [Byte].init(fromHexEncodedString: hex))
    }

    private func visitDateTimeConstructor() throws -> Int64 {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM dd yyyy HH:mm:ss z"

        try self.verifyToken(expectedType: .leftParen)

        var token = try self.popToken()
        switch token.type {
        case .rightParen: return Int64(Date().timeIntervalSince1970 * 1000)
        case .string:
            try self.verifyToken(expectedType: .rightParen);
            if let dateTime = try formatter.date(from: token.valueAs()) {
                return Int64(dateTime.timeIntervalSince1970 * 1000)
            } else {
                throw JSONError.parse(
                    "JSON reader expected a date in 'EEE MMM dd yyyy HH:mm:ss z' format but found '\(token.value)'.")
            }
        case .int32, .int64:
            var values = [Int64].init(repeating: 0, count: 7)
            var pos = 0
            while true {
                if (pos < values.count) {
                    values[pos] = try token.valueAs()
                    pos += 1
                }
                token = try self.popToken()
                if token.type == .rightParen {
                    break
                }
                if token.type != .comma {
                    throw JSONError.parse("JSON reader expected a ',' or a ')' but found '\(token.value)'.")
                }
                token = try self.popToken()
                if token.type != .int32 && token.type != .int64 {
                    throw JSONError.parse("JSON reader expected an integer but found '\(token.value)'.")
                }
            }
            if (pos == 1) {
                return values[0]
            } else if (pos < 3 || pos > 7) {
                throw JSONError.parse("JSON reader expected 1 or 3-7 integers but found \(pos).")
            }

            let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)

            let components = DateComponents.init(calendar: calendar,
                                                 timeZone: TimeZone(identifier: "UTC"),
                                                 year: Int(values[0]),
                                                 month: Int(values[1]) + 1,
                                                 day: Int(values[2]),
                                                 hour: Int(values[3]),
                                                 minute: Int(values[4]),
                                                 second: Int(values[5]),
                                                 nanosecond: Int(values[6])*1000000)
            guard let date = components.date?.timeIntervalSince1970 else { fallthrough }
            return Int64(date * 1000)
        default:
            throw JSONError.parse(
                "JSON reader expected an integer or a string but found '\(token.value)'.")
        }
    }

    private func visitDateTimeConstructorWithOutNew() throws -> String {
        try self.verifyToken(expectedType: .leftParen)
        var token = try self.popToken()
        if token.type != .rightParen {
            while token.type != .endOfFile {
                token = try self.popToken()
                if token.type == .rightParen {
                    break
                }
            }
            if token.type != .rightParen {
                throw JSONError.parse("JSON reader expected a ')' but found '\(token.value)'.")
            }
        }

        let df = DateFormatter()
        df.dateFormat = "EEE MMM dd yyyy HH:mm:ss z"
        return df.string(from: Date())
    }

    private func visitBinDataExtendedJson(firstKey: String) throws -> BsonBinary? {
        let mark = JsonMark(jsonReader: self)

        try self.verifyToken(expectedType: .colon)

        if firstKey == "$binary" {
            let nextToken = try self.popToken()
            if nextToken.type == .beginObject {
                let nameToken = try self.popToken()
                let firstNestedKey = try nameToken.valueAs(type: String.self)
                var data: [Byte]
                var type: Byte
                switch firstNestedKey {
                case "base64":
                    try self.verifyToken(expectedType: .colon)
                    data = try [Byte].init(base64Encoded: readStringFromExtendedJson())
                    try self.verifyToken(expectedType: .comma)
                    try self.verifyString(expected: "subType")
                    try self.verifyToken(expectedType: .colon)
                    type = try readBinarySubtypeFromExtendedJson()
                case "subType":
                    try self.verifyToken(expectedType: .colon)
                    type = try self.readBinarySubtypeFromExtendedJson()
                    try self.verifyToken(expectedType: .comma)
                    try self.verifyString(expected: "base64")
                    try self.verifyToken(expectedType: .colon)
                    data = try [Byte].init(base64Encoded: readStringFromExtendedJson())
                default:
                    throw JSONError.parse("Unexpected key for $binary: " + firstNestedKey)
                }

                try self.verifyToken(expectedType: .endObject)
                try self.verifyToken(expectedType: .endObject)

                guard let subType = BsonBinarySubType(rawValue: type) else {
                    throw JSONError.parse("Unexpected value for $subType: \(type)")
                }
                return BsonBinary(data: data, type: subType)
            } else {
                mark.reset()
                return try self.visitLegacyBinaryExtendedJson(firstKey: firstKey)
            }
        } else {
            mark.reset()
            return try self.visitLegacyBinaryExtendedJson(firstKey: firstKey)
        }
    }

    private func visitLegacyBinaryExtendedJson(firstKey: String) throws -> BsonBinary? {
        let mark = JsonMark(jsonReader: self)

        do {
            try self.verifyToken(expectedType: .colon)

            var data = [Byte]()
            var type: Byte = 0

            if firstKey == "$binary" {
                data = try [Byte](base64Encoded: readStringFromExtendedJson())
                try self.verifyToken(expectedType: .comma)
                try self.verifyString(expected: "$type")
                try self.verifyToken(expectedType: .colon)
                type = try readBinarySubtypeFromExtendedJson()
            } else {
                type = try readBinarySubtypeFromExtendedJson()
                try self.verifyToken(expectedType: .comma)
                try self.verifyString(expected: "$binary")
                try self.verifyToken(expectedType: .colon)
                data = try [Byte](base64Encoded: readStringFromExtendedJson())
            }

            try self.verifyToken(expectedType: .endObject)
            guard let subType = BsonBinarySubType(rawValue: type) else {
                throw JSONError.parse("Unexpected value for $subType: \(type)")
            }
            return BsonBinary(data: data, type: subType)
        } catch {
            mark.reset()
            return nil
        }
    }

    private func readBinarySubtypeFromExtendedJson() throws -> Byte {
        let subTypeToken = try self.popToken()
        if subTypeToken.type != .string && subTypeToken.type != .int32 {
            throw JSONError.parse(
                "JSON reader expected a string or number but found '\(subTypeToken.value)'.")
        }

        if subTypeToken.type == .string {
            guard let subType = try Byte(subTypeToken.valueAs(type: String.self),
                                         radix: 16) else {
                throw JSONError.parse(
                    "JSON reader expected a string or number but found '\(subTypeToken.value)'.");
            }
            return subType
        } else {
            return try subTypeToken.valueAs(type: UInt8.self)
        }
    }

    private func visitDateTimeExtendedJson() throws -> Int64 {
        var value: Int64 = 0
        try self.verifyToken(expectedType: .colon)
        let valueToken = try self.popToken()
        if valueToken.type == .beginObject {
            let nameToken = try self.popToken()
            let name = try nameToken.valueAs(type: String.self)
            if name != "$numberLong" {
                throw JSONError.parse("JSON reader expected $numberLong within $date, but found \(name)")
            }
            value = try visitNumberLongExtendedJson()
            try self.verifyToken(expectedType: .endObject)
        } else {
            switch valueToken.type {
            case .int32, .int64: value = try valueToken.valueAs()
            case .string:
                let dateTimeString = try valueToken.valueAs(type: String.self)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
                guard let val = dateFormatter.date(from: dateTimeString)?.timeIntervalSince1970 else {
                    throw JSONError.parse("Failed to parse string as a date: \(dateTimeString)")
                }
                value = Int64(val * 1000)
            default:
                throw JSONError.parse(
                    "JSON reader expected an integer or string but found '\(valueToken.value)'.");
            }

            try self.verifyToken(expectedType: .endObject)
        }
        return value
    }

    private func visitMaxKeyExtendedJson() throws -> MaxKey {
        try self.verifyToken(expectedType: .colon)
        try self.verifyToken(expectedType: .int32, expectedValue: Int32(1))
        try self.verifyToken(expectedType: .endObject)
        return MaxKey()
    }

    private func visitMinKeyExtendedJson() throws -> MinKey {
        try self.verifyToken(expectedType: .colon)
        try self.verifyToken(expectedType: .int32, expectedValue: Int32(1))
        try self.verifyToken(expectedType: .endObject)
        return MinKey()
    }

    private func visitObjectIdExtendedJson() throws -> ObjectId {
        try self.verifyToken(expectedType: .colon)
        let objectId = try ObjectId(hexString: readStringFromExtendedJson())
        try self.verifyToken(expectedType: .endObject)
        return objectId
    }

    private func visitNewRegularExpressionExtendedJson() throws -> BsonRegularExpression {
        try self.verifyToken(expectedType: .colon)
        try self.verifyToken(expectedType: .beginObject)

        let firstKey = try readStringFromExtendedJson()

        var pattern, options: String
        if firstKey == "pattern" {
            try self.verifyToken(expectedType: .colon)
            pattern = try readStringFromExtendedJson()
            try self.verifyToken(expectedType: .comma)
            try verifyString(expected: "options")
            try self.verifyToken(expectedType: .colon)
            options = try readStringFromExtendedJson()
        } else if firstKey == "options" {
            try self.verifyToken(expectedType: .colon)
            options = try readStringFromExtendedJson()
            try self.verifyToken(expectedType: .comma)
            try self.verifyString(expected: "pattern")
            try self.verifyToken(expectedType: .colon)
            pattern = try readStringFromExtendedJson()
        } else {
            throw JSONError.parse("Expected 't' and 'i' fields in $timestamp document but found " + firstKey)
        }

        try self.verifyToken(expectedType: .endObject)
        try self.verifyToken(expectedType: .endObject)
        return BsonRegularExpression(pattern: pattern,
                                     options: options)
    }

    private func visitRegularExpressionExtendedJson(firstKey: String) throws -> BsonRegularExpression? {
        let extendedJsonMark = JsonMark(jsonReader: self)

        do {
            try self.verifyToken(expectedType: .colon)

            let pattern, options: String
            if firstKey == "$regex" {
                pattern = try readStringFromExtendedJson()
                try self.verifyToken(expectedType: .comma)
                try self.verifyString(expected: "$options")
                try self.verifyToken(expectedType: .colon)
                options = try readStringFromExtendedJson()
            } else {
                options = try readStringFromExtendedJson()
                try self.verifyToken(expectedType: .comma)
                try self.verifyString(expected: "$regex")
                try self.verifyToken(expectedType: .colon)
                pattern = try readStringFromExtendedJson()
            }
            try self.verifyToken(expectedType: .endObject)
            return BsonRegularExpression(pattern: pattern, options: options)
        } catch {
            extendedJsonMark.reset()
            return nil
        }
    }

    private func readStringFromExtendedJson() throws -> String {
        let patternToken = try self.popToken()
        if patternToken.type != .string {
            throw JSONError.parse("JSON reader expected a string but found '\(patternToken.value)'.")
        }
        return try patternToken.valueAs()
    }

    private func visitSymbolExtendedJson() throws -> String {
        try self.verifyToken(expectedType: .colon)
        let symbol = try readStringFromExtendedJson()
        try self.verifyToken(expectedType: .endObject)
        return symbol
    }

    private func visitTimestampExtendedJson() throws -> BsonTimestamp {
        try self.verifyToken(expectedType: .colon)
        try self.verifyToken(expectedType: .beginObject)

        var time, increment: Int32

        let firstKey = try readStringFromExtendedJson()
        if firstKey == "t" {
            try self.verifyToken(expectedType: .colon)
            time = try readIntFromExtendedJson()
            try self.verifyToken(expectedType: .comma)
            try self.verifyString(expected: "i")
            try self.verifyToken(expectedType: .colon)
            increment = try readIntFromExtendedJson()
        } else if firstKey == "i" {
            try self.verifyToken(expectedType: .colon)
            increment = try readIntFromExtendedJson()
            try self.verifyToken(expectedType: .comma)
            try self.verifyString(expected: "t")
            try self.verifyToken(expectedType: .colon)
            time = try readIntFromExtendedJson()
        } else {
            throw JSONError.parse(
                "Expected 't' and 'i' fields in $timestamp document but found " + firstKey)
        }

        try self.verifyToken(expectedType: .endObject)
        try self.verifyToken(expectedType: .endObject)

        return BsonTimestamp(seconds: UInt(time), increment: UInt(increment))
    }

    private func readIntFromExtendedJson() throws -> Int32 {
        let nextToken = try self.popToken()
        var value: Int32
        if nextToken.type == .int32 {
            value = try nextToken.valueAs()
        } else if nextToken.type == .int64 {
            value = try Int32(nextToken.valueAs(type: Int64.self))
        } else {
            throw JSONError.parse("JSON reader expected an integer but found '\(nextToken.value)'.")
        }
        return value
    }

    private func visitJavaScriptExtendedJson() throws {
        try self.verifyToken(expectedType: .colon)
        let code = try readStringFromExtendedJson()
        let nextToken = try popToken()
        switch nextToken.type {
        case .comma:
            try self.verifyString(expected: "$scope")
            try self.verifyToken(expectedType: .colon)
            state = .value
            currentValue = code
            currentBsonType = .javascriptWithScope
            context = JsonContext(parentContext: context, contextType: .scopeDocument)
            break;
        case .endObject:
            currentValue = code
            currentBsonType = .javascript
        default:
            throw JSONError.parse("JSON reader expected ',' or '}' but found '\(nextToken)'.")
        }
    }

    private func visitUndefinedExtendedJson() throws -> BsonUndefined {
        try self.verifyToken(expectedType: .colon)
        let valueToken = try self.popToken()
        if try valueToken.valueAs(type: String.self) != "true" {
            throw JSONError.parse(
                "JSON reader requires $undefined to have the value of true but found '\(valueToken.value)'.")
        }
        try self.verifyToken(expectedType: .endObject)
        return BsonUndefined()
    }

    private func visitNumberLongExtendedJson() throws -> Int64 {
        try self.verifyToken(expectedType: .colon)
        let longAsString = try readStringFromExtendedJson()
        guard let value = Int64(longAsString) else {
            throw JSONError.parse(
                "Exception converting value '\(longAsString)' to type \(Int64.self)")
        }
        try self.verifyToken(expectedType: .endObject)
        return value
    }

    private func visitNumberIntExtendedJson() throws -> Int32 {
        try self.verifyToken(expectedType: .colon)
        let intAsString = try readStringFromExtendedJson()
        guard let value = Int32(intAsString) else {
            throw JSONError.parse("Exception converting value '\(intAsString)' to type \(Int32.self)")
        }
        try self.verifyToken(expectedType: .endObject)
        return value
    }

    private func visitNumberDoubleExtendedJson() throws -> Double {
        try self.verifyToken(expectedType: .colon)
        let doubleAsString = try readStringFromExtendedJson()
        guard let value = Double(doubleAsString) else {
            throw JSONError.parse("Exception converting value '\(doubleAsString)' to type \(Double.self)")
        }
        try self.verifyToken(expectedType: .endObject)
        return value
    }

    private func visitNumberDecimalExtendedJson() throws -> Decimal {
        try self.verifyToken(expectedType: .colon)
        let decimalAsString = try readStringFromExtendedJson()
        guard let value = Decimal(string: decimalAsString) else {
            throw JSONError.parse(
                "Exception converting value '\(decimalAsString)' to type \(Decimal.self)")
        }
        try self.verifyToken(expectedType: .endObject)
        return value
    }

    private func visitDbPointerExtendedJson() throws -> BsonDbPointer {
        try self.verifyToken(expectedType: .colon)
        try self.verifyToken(expectedType: .beginObject)

        var ref: String, oid: ObjectId

        let firstKey = try readStringFromExtendedJson()
        if firstKey == "$ref" {
            try self.verifyToken(expectedType: .colon)
            ref = try readStringFromExtendedJson()
            try self.verifyToken(expectedType: .comma)
            try self.verifyString(expected: "$id")
            oid = try readDbPointerIdFromExtendedJson()
            try self.verifyToken(expectedType: .endObject)
        } else if firstKey == "$id" {
            oid = try readDbPointerIdFromExtendedJson()
            try self.verifyToken(expectedType: .comma)
            try self.verifyString(expected: "$ref")
            try self.verifyToken(expectedType: .colon)
            ref = try readStringFromExtendedJson()
        } else {
            throw JSONError.parse(
                "Expected $ref and $id fields in $dbPointer document but found " + firstKey)
        }
        try self.verifyToken(expectedType: .endObject)
        return BsonDbPointer(namespace: ref, id: oid);
    }

    private func readDbPointerIdFromExtendedJson() throws -> ObjectId {
        try self.verifyToken(expectedType: .colon)
        try self.verifyToken(expectedType: .beginObject)
        try self.verifyToken(expectedType: .string, expectedValue: "$oid")
        return try self.visitObjectIdExtendedJson()
    }

    func reset() throws {
        if mark == nil {
            throw BSONError.invalidOperation("trying to reset a mark before creating it")
        }
        mark?.reset()
        mark = nil
    }

    private func popToken() throws -> JsonToken {
        if pushedToken != nil {
            let token = pushedToken
            pushedToken = nil
            return token!
        } else {
            return try scanner.nextToken()
        }
    }

    private func pushToken(token: JsonToken) throws {
        if pushedToken == nil {
            pushedToken = token
        } else {
            throw BSONError.invalidOperation("There is already a pending token.")
        }
    }

    internal class JsonMark: Mark {
        private let pushedToken: JsonToken?
        private let currentValue: Any?
        private let position: Int

        private var jsonReader: JsonReader

        init(jsonReader: JsonReader) {
            self.jsonReader = jsonReader
            self.pushedToken = jsonReader.pushedToken
            self.currentValue = jsonReader.currentValue
            self.position = jsonReader.scanner.getBufferPosition()
            var temp: AbstractBsonReader = jsonReader
            super.init(abstractBsonReader: &temp)
        }

        override public func reset() {
            super.reset()

            jsonReader.pushedToken = pushedToken;
            jsonReader.currentValue = currentValue;
            jsonReader.scanner.setBufferPosition(newPosition: position)
            jsonReader.context = JsonContext(parentContext: jsonReader.context,
                                              contextType: jsonReader.context.contextType)
        }
    }

    internal class JsonContext: Context {
        var parentContext: Context?
        var contextType: BsonContextType

        init(parentContext: Context?, contextType: BsonContextType) {
            self.parentContext = parentContext
            self.contextType = contextType
        }
    }
}
