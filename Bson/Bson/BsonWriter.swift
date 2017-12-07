//
//  BsonWriter.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * An interface for writing a logical BSON document using a push-oriented API.
 *
 * @since 3.0
 */
public protocol BsonWriter {
    /**
     * Writes a BSON Binary data element to the writer.
     *
     * @param binary The Binary data.
     */
    func writeBinaryData(binary: BsonBinary) throws

    /**
     * Writes a BSON Binary data element to the writer.
     *
     * @param name   The name of the element.
     * @param binary The Binary data value.
     */
    func writeBinaryData(name: String, binary: BsonBinary) throws

    /**
     * Writes a BSON Boolean to the writer.
     *
     * @param value The Boolean value.
     */
    func writeBoolean(value: Bool) throws

    /**
     * Writes a BSON Boolean element to the writer.
     *
     * @param name  The name of the element.
     * @param value The Boolean value.
     */
    func writeBoolean(name: String, value: Bool) throws

    /**
     * Writes a BSON DateTime to the writer.
     *
     * @param value The number of milliseconds since the Unix epoch.
     */
    func writeDateTime(value: Int64) throws

    /**
     * Writes a BSON DateTime element to the writer.
     *
     * @param name  The name of the element.
     * @param value The number of milliseconds since the Unix epoch.
     */
    func writeDateTime(name: String, value: Int64) throws

    /**
     * Writes a BSON DBPointer to the writer.
     *
     * @param value The DBPointer to write
     */
    func writeDBPointer(value: BsonDbPointer) throws

    /**
     * Writes a BSON DBPointer element to the writer.
     *
     * @param name  The name of the element.
     * @param value The DBPointer to write
     */
    func writeDBPointer(name: String, value: BsonDbPointer) throws

    /**
     * Writes a BSON Double to the writer.
     *
     * @param value The Double value.
     */
    func writeDouble(value: Double) throws

    /**
     * Writes a BSON Double element to the writer.
     *
     * @param name  The name of the element.
     * @param value The Double value.
     */
    func writeDouble(name: String, value: Double) throws

    /**
     * Writes the end of a BSON array to the writer.
     */
    func writeEndArray() throws

    /**
     * Writes the end of a BSON document to the writer.
     */
    func writeEndDocument() throws

    /**
     * Writes a BSON Int32 to the writer.
     *
     * @param value The Int32 value.
     */
    func writeInt32(value: Int32) throws

    /**
     * Writes a BSON Int32 element to the writer.
     *
     * @param name  The name of the element.
     * @param value The Int32 value.
     */
    func writeInt32(name: String, value: Int32) throws

    /**
     * Writes a BSON Int64 to the writer.
     *
     * @param value The Int64 value.
     */
    func writeInt64(value: Int64) throws

    /**
     * Writes a BSON Int64 element to the writer.
     *
     * @param name  The name of the element.
     * @param value The Int64 value.
     */
    func writeInt64(name: String, value: Int64) throws

    /**
     * Writes a BSON Decimal128 to the writer.
     *
     * @param value The Decimal128 value.
     * @since 3.4
     */
    func writeDecimal128(value: Decimal) throws

    /**
     * Writes a BSON Decimal128 element to the writer.
     *
     * @param name  The name of the element.
     * @param value The Decimal128 value.
     * @since 3.4
     */
    func writeDecimal128(name: String, value: Decimal) throws

    /**
     * Writes a BSON JavaScript to the writer.
     *
     * @param code The JavaScript code.
     */
    func writeJavaScript(code: String) throws

    /**
     * Writes a BSON JavaScript element to the writer.
     *
     * @param name The name of the element.
     * @param code The JavaScript code.
     */
    func writeJavaScript(name: String, code: String) throws

    /**
     * Writes a BSON JavaScript to the writer (call WriteStartDocument to start writing the scope) throws.
     *
     * @param code The JavaScript code.
     */
    func writeJavaScriptWithScope(code: String) throws

    /**
     * Writes a BSON JavaScript element to the writer (call WriteStartDocument to start writing the scope) throws.
     *
     * @param name The name of the element.
     * @param code The JavaScript code.
     */
    func writeJavaScriptWithScope(name: String, code: String) throws

    /**
     * Writes a BSON MaxKey to the writer.
     */
    func writeMaxKey() throws

    /**
     * Writes a BSON MaxKey element to the writer.
     *
     * @param name The name of the element.
     */
    func writeMaxKey(name: String) throws

    /**
     * Writes a BSON MinKey to the writer.
     */
    func writeMinKey() throws

    /**
     * Writes a BSON MinKey element to the writer.
     *
     * @param name The name of the element.
     */
    func writeMinKey(name: String) throws

    /**
     * Writes the name of an element to the writer.
     *
     * @param name The name of the element.
     */
    func writeName(name: String) throws

    /**
     * Writes a BSON null to the writer.
     */
    func writeNull() throws

    /**
     * Writes a BSON null element to the writer.
     *
     * @param name The name of the element.
     */
    func writeNull(name: String) throws

    /**
     * Writes a BSON ObjectId to the writer.
     *
     * @param objectId The ObjectId value.
     */
    func writeObjectId(objectId: ObjectId) throws

    /**
     * Writes a BSON ObjectId element to the writer.
     *
     * @param name     The name of the element.
     * @param objectId The ObjectId value.
     */
    func writeObjectId(name: String, objectId: ObjectId) throws

    /**
     * Writes a BSON regular expression to the writer.
     *
     * @param regularExpression the regular expression to write.
     */
    func writeRegularExpression(regularExpression: BsonRegularExpression) throws

    /**
     * Writes a BSON regular expression element to the writer.
     *
     * @param name              The name of the element.
     * @param regularExpression The RegularExpression value.
     */
    func writeRegularExpression(name: String, regularExpression: BsonRegularExpression) throws

    /**
     * Writes the start of a BSON array to the writer.
     *
     * @throws BsonSerializationException if maximum serialization depth exceeded.
     */
    func writeStartArray() throws

    /**
     * Writes the start of a BSON array element to the writer.
     *
     * @param name The name of the element.
     */
    func writeStartArray(name: String) throws

    /**
     * Writes the start of a BSON document to the writer.
     *
     * @throws BsonSerializationException if maximum serialization depth exceeded.
     */
    func writeStartDocument() throws

    /**
     * Writes the start of a BSON document element to the writer.
     *
     * @param name The name of the element.
     */
    func writeStartDocument(name: String) throws

    /**
     * Writes a BSON String to the writer.
     *
     * @param value The String value.
     */
    func writeString(value: String) throws

    /**
     * Writes a BSON String element to the writer.
     *
     * @param name  The name of the element.
     * @param value The String value.
     */
    func writeString(name: String, value: String) throws

    /**
     * Writes a BSON Symbol to the writer.
     *
     * @param value The symbol.
     */
    func writeSymbol(value: String) throws

    /**
     * Writes a BSON Symbol element to the writer.
     *
     * @param name  The name of the element.
     * @param value The symbol.
     */
    func writeSymbol(name: String, value: String) throws

    /**
     * Writes a BSON Timestamp to the writer.
     *
     * @param value The combined timestamp/increment value.
     */
    func writeTimestamp(value: BsonTimestamp) throws

    /**
     * Writes a BSON Timestamp element to the writer.
     *
     * @param name  The name of the element.
     * @param value The combined timestamp/increment value.
     */
    func writeTimestamp(name: String, value: BsonTimestamp) throws

    /**
     * Writes a BSON undefined to the writer.
     */
    func writeUndefined() throws

    /**
     * Writes a BSON undefined element to the writer.
     *
     * @param name The name of the element.
     */
    func writeUndefined(name: String) throws

    /**
     * Reads a single document from a BsonReader and writes it to this.
     *
     * @param reader The source.
     */
    func pipe(reader: BsonReader ) throws
}
