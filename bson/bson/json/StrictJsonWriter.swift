//
//  StrictJsonWriter.swift
//  bson
//
//  Created by Jason Flax on 12/2/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public protocol StrictJsonWriter {
    /**
     * Writes the name of a member to the writer.
     *
     * @param name the member name
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a member name
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func write(name: String) throws

    /**
     * Writes a boolean to the writer.
     *
     * @param value the boolean value.
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a value
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func write(bool: Bool) throws

    /**
     * Writes a a member with a boolean value to the writer.
     *
     * @param name  the member name
     * @param value the boolean value
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a member
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func write(name: String, bool: Bool) throws

    /**
     * Writes a number to the writer.
     *
     * @param value the Double value, as a String so that clients can take full control over formatting
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a value
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func write(number: String) throws

    /**
     * Writes a member with a numeric value to the writer.
     *
     * @param name  the member name
     * @param value the Double value, as a String so that clients can take full control over formatting
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a member
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func write(name: String, number: String) throws

    /**
     * Writes a String to the writer.
     *
     * @param value the String value
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a value
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func write(string: String) throws

    /**
     * Writes a member with a string value to the writer.
     *
     * @param name  the member name
     * @param value the String value
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a member
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func write(name: String, string: String) throws

    /**
     * Writes a raw value without quoting or escaping.
     *
     * @param value the String value
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a value
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func write(raw: String) throws

    /**
     * Writes a member with a raw value without quoting or escaping.
     *
     * @param name  the member name
     * @param value the raw value
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a member
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func write(name: String, raw: String) throws

    /**
     * Writes a null value to the writer.
     *
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a value
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func writeNull() throws

    /**
     * Writes a member with a null value to the writer.
     *
     * @param name the member name
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a member
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func writeNull(name: String) throws

    /**
     * Writes the start of a array to the writer.
     *
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a value
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func writeStartArray() throws

    /**
     * Writes the start of JSON array member to the writer.
     *
     * @param name the member name
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a member
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func writeStartArray(name: String) throws

    /**
     * Writes the start of a JSON object to the writer.
     *
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a value
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func writeStartObject() throws

    /**
     * Writes the start of a JSON object member to the writer.
     *
     * @param name the member name
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write a member
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func writeStartObject(name: String) throws

    /**
     * Writes the end of a JSON array to the writer.
     *
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write the end of an array
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func writeEndArray() throws

    /**
     * Writes the end of a JSON object to the writer.
     *
     * @throws org.bson.BsonInvalidOperationException if not in the correct state to write the end of an object
     * @throws org.bson.BSONException if the underlying Writer throws an IOException
     */
    func writeEndObject() throws
}
