//
//  BsonReader.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public protocol BsonReader {
    var mark: BsonReaderMark? { get }
    var currentBsonType: BsonType { get set }

    /**
     * Reads BSON Binary data from the reader.
     *
     * @return A Binary.
     */
    @discardableResult
    func readBinaryData() throws -> BsonBinary

    /**
     * Peeks the subtype of the binary data that the reader is positioned at.  This operation is not permitted if the mark is already set.
     *
     * @return the subtype
     * @see #mark()
     */
     func peekBinarySubType() throws -> UInt8

    /**
     * Peeks the size of the binary data that the reader is positioned at.  This operation is not permitted if the mark is already set.
     *
     * @return the size of the binary data
     * @see #mark()
     * @since 3.4
     */
     func peekBinarySize() throws -> Int

    /**
     * Reads a BSON Binary data element from the reader.
     *
     * @param name The name of the element.
     * @return A Binary.
     */
     func readBinaryData(name: String) throws -> BsonBinary

    /**
     * Reads a BSON Boolean from the reader.
     *
     * @return A Boolean.
     */
    @discardableResult
    func readBoolean() throws -> Bool

    /**
     * Reads a BSON Boolean element from the reader.
     *
     * @param name The name of the element.
     * @return A Boolean.
     */
    func readBoolean(name: String) throws -> Bool

    /**
     * Reads a BSONType from the reader.
     *
     * @return A BSONType.
     */
    @discardableResult
    func readBsonType() throws -> BsonType

    /**
     * Reads a BSON DateTime from the reader.
     *
     * @return The number of milliseconds since the Unix epoch.
     */
    @discardableResult
    func readDateTime() throws -> Int64

    /**
     * Reads a BSON DateTime element from the reader.
     *
     * @param name The name of the element.
     * @return The number of milliseconds since the Unix epoch.
     */
    func readDateTime(name: String) throws -> Int64

    /**
     * Reads a BSON Double from the reader.
     *
     * @return A Double.
     */
    @discardableResult
    func readDouble() throws -> Double

    /**
     * Reads a BSON Double element from the reader.
     *
     * @param name The name of the element.
     * @return A Double.
     */
     func readDouble(name: String) throws -> Double

    /**
     * Reads the end of a BSON array from the reader.
     */
    func readEndArray() throws

    /**
     * Reads the end of a BSON document from the reader.
     */
    func readEndDocument() throws

    /**
     * Reads a BSON Int32 from the reader.
     *
     * @return An Int32.
     */
    @discardableResult
    func readInt32() throws -> Int32

    /**
     * Reads a BSON Int32 element from the reader.
     *
     * @param name The name of the element.
     * @return An Int32.
     */
    func readInt32(name: String) throws -> Int32

    /**
     * Reads a BSON Int64 from the reader.
     *
     * @return An Int64.
     */
    @discardableResult
    func readInt64() throws -> Int64

    /**
     * Reads a BSON Int64 element from the reader.
     *
     * @param name The name of the element.
     * @return An Int64.
     */
     func readInt64(name: String) throws -> Int64

    /**
     * Reads a BSON Decimal128 from the reader.
     *
     * @return A Decimal128
     * @since 3.4
     */
    @discardableResult
    func readDecimal() throws -> Decimal

    /**
     * Reads a BSON Decimal128 element from the reader.
     *
     * @param name The name of the element.
     * @return A Decimal128
     * @since 3.4
     */
    func readDecimal(name: String) throws -> Decimal

    /**
     * Reads a BSON JavaScript from the reader.
     *
     * @return A string.
     */
    @discardableResult
    func readJavaScript() throws -> String

    /**
     * Reads a BSON JavaScript element from the reader.
     *
     * @param name The name of the element.
     * @return A string.
     */
    func readJavaScript(name: String) throws -> String

    /**
     * Reads a BSON JavaScript with scope from the reader (call readStartDocument next to read the scope).
     *
     * @return A string.
     */
    @discardableResult
    func readJavaScriptWithScope() throws -> String

    /**
     * Reads a BSON JavaScript with scope element from the reader (call readStartDocument next to read the scope).
     *
     * @param name The name of the element.
     * @return A string.
     */
    func readJavaScriptWithScope(name: String) throws -> String

    /**
     * Reads a BSON MaxKey from the reader.
     */
    func readMaxKey() throws

    /**
     * Reads a BSON MaxKey element from the reader.
     *
     * @param name The name of the element.
     */
    func readMaxKey(name: String) throws

    /**
     * Reads a BSON MinKey from the reader.
     */
    func readMinKey() throws

    /**
     * Reads a BSON MinKey element from the reader.
     *
     * @param name The name of the element.
     */
    func readMinKey(name: String) throws

    /**
     * Reads the name of an element from the reader.
     *
     * @return The name of the element.
     */
    @discardableResult
    func readName() throws -> String

    /**
     * Reads the name of an element from the reader.
     *
     * @param name The name of the element.
     */
    func readName(name: String) throws

    /**
     * Reads a BSON null from the reader.
     */
    func readNull() throws

    /**
     * Reads a BSON null element from the reader.
     *
     * @param name The name of the element.
     */
    func readNull(name: String) throws

    /**
     * Reads a BSON ObjectId from the reader.
     *
     * @return the {@code ObjectId} value
     */
    @discardableResult
    func readObjectId() throws -> ObjectId

    /**
     * Reads a BSON ObjectId element from the reader.
     *
     * @param name The name of the element.
     * @return ObjectId.
     */
    func readObjectId(name: String) throws -> ObjectId

    /**
     * Reads a BSON regular expression from the reader.
     *
     * @return A regular expression.
     */
    func readRegularExpression() throws -> BsonRegularExpression

    /**
     * Reads a BSON regular expression element from the reader.
     *
     * @param name The name of the element.
     * @return A regular expression.
     */
    func readRegularExpression(name: String) throws -> BsonRegularExpression

    /**
     * Reads a BSON DBPointer from the reader.
     *
     * @return A DBPointer.
     */
    func readDBPointer() throws -> BsonDbPointer

    /**
     * Reads a BSON DBPointer element from the reader.
     *
     * @param name The name of the element.
     * @return A DBPointer.
     */
    func readDBPointer(name: String) throws -> BsonDbPointer

    /**
     * Reads the start of a BSON array.
     */
    func readStartArray() throws

    /**
     * Reads the start of a BSON document.
     */
    func readStartDocument() throws

    /**
     * Reads a BSON String from the reader.
     *
     * @return A String.
     */
    func readString() throws -> String

    /**
     * Reads a BSON string element from the reader.
     *
     * @param name The name of the element.
     * @return A String.
     */
    func readString(name: String) throws -> String

    /**
     * Reads a BSON symbol from the reader.
     *
     * @return A string.
     */
    @discardableResult
    func readSymbol() throws -> String

    /**
     * Reads a BSON symbol element from the reader.
     *
     * @param name The name of the element.
     * @return A string.
     */
    func readSymbol(name: String) throws -> String

    /**
     * Reads a BSON timestamp from the reader.
     *
     * @return The combined timestamp/increment.
     */
     func readTimestamp() throws -> BsonTimestamp

    /**
     * Reads a BSON timestamp element from the reader.
     *
     * @param name The name of the element.
     * @return The combined timestamp/increment.
     */
     func readTimestamp(name: String) throws -> BsonTimestamp

    /**
     * Reads a BSON undefined from the reader.
     */
     func readUndefined() throws

    /**
     * Reads a BSON undefined element from the reader.
     *
     * @param name The name of the element.
     */
     func readUndefined(name: String) throws

    /**
     * Skips the name (reader must be positioned on a name).
     */
     func skipName() throws

    /**
     * Skips the value (reader must be positioned on a value).
     */
     func skipValue() throws

    /**
     * Go back to the state at the last mark and removes the mark
     *
     * @throws org.bson.BSONException if no mark has been set
     */
    func reset() throws
}
