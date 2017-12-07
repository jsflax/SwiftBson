//
//  BsonInput.swift
//  bson
//
//  Created by Jason Flax on 12/5/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * An input stream that is optimized for reading BSON values directly from the underlying stream.
 *
 * @since 3.0
 */
public protocol BsonInput {
    /**
     * Gets the current position in the stream
     *
     * @return the current position
     */
    var position: Int { get set }

    /**
     * Reads a single byte from the stream
     *
     * @return the byte value
     */
    func readByte() -> Byte

    /**
     * Reads the specified number of bytes into the given byte array. This is equivalent to to {@code readBytes(bytes, 0, bytes.length)}.
     *
     * @param bytes the byte array to write into
     */
    func readBytes(bytes: [Byte])

    /**
     * Reads the specified number of bytes into the given byte array starting at the specified offset.
     *
     * @param bytes the byte array to write into
     * @param offset the offset to start writing
     * @param length the number of bytes to write
     */
    func readBytes(bytes: [Byte], offset: Int, count: Int)

    /**
     * Reads a BSON Int64 value from the stream.
     *
     * @return the Int64 value
     */
    func readInt64() -> Int64

    /**
     * Reads a BSON Double value from the stream.
     *
     * @return the double value
     */
    func readDouble() -> Double

    /**
     * Reads a BSON Int32 value from the stream.
     *
     * @return the Int32 value
     */
    func readInt32() -> Int32

    /**
     * Reads a BSON String value from the stream.
     *
     * @return the string
     */
    func readString() -> String

    /**
     * Reads a BSON ObjectId value from the stream.
     *
     * @return the ObjectId
     */
    func readObjectId() -> ObjectId

    /**
     * Reads a BSON CString value from the stream.
     *
     * @return the CString
     */
    func readCString() -> String

    /**
     * Skips a BSON CString value from the stream.
     *
     */
    func skipCString()

    /**
     * Skips the specified number of bytes in the stream.
     *
     * @param numBytes the number of bytes to skip
     */
    func skip(numBytes: Int)

    /**
     * Marks the current position in the stream. This method obeys the contract as specified in the same method in {@code InputStream}.
     *
     * @param readLimit the maximum limit of bytes that can be read before the mark position becomes invalid
     */
    func mark(readLimit: Int)

    /**
     * Resets the stream to the current mark. This method obeys the contract as specified in the same method in {@code InputStream}.
     */
    func reset()

    /**
     * Returns true if there are more bytes left in the stream.
     *
     * @return true if there are more bytes left in the stream.
     */
    func hasRemaining() -> Bool
}
