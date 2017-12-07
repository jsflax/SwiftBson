//
//  BsonOutput.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * An output stream that is optimized for writing BSON values directly to the underlying stream.
 *
 * @since 3.0
 */

public protocol BsonOutput {
    /**
     * Gets the current position in the stream.
     *
     * @return the current position
     */
    func position() throws -> Int

    /**
     * Gets the current size of the stream in number of bytes.
     *
     * @return the size of the stream
     */
    func size() throws -> Int

    /**
     * Truncates this stream to the new position.  After this call, both size and position will equal the new position.
     * @param newPosition the new position, which must be greater than or equal to 0 and less than the current size.
     */
    func truncateToPosition(newPosition: Int) throws

    /**
     * Writes all the bytes in the byte array to the stream.
     * @param bytes the non-null byte array
     */
    func writeBytes(bytes: [Byte]) throws

    /**
     * Writes {@code length} bytes from the byte array, starting at {@code offset}.
     * @param bytes the non-null byte array
     * @param offset the offset to start writing from
     * @param length the number of bytes to write
     */
    func writeBytes(bytes: [Byte], offset: Int, count: Int) throws

    /**
     * Write a single byte to the stream. The byte to be written is the eight low-order bits of the specified value. The 24
     * high-order bits of the value are ignored.
     *
     * @param value the value
     */
    func writeByte(value: Byte) throws

    /**
     * Writes a BSON CString to the stream.
     *
     * @param value the value
     */
    func writeCString(value: String) throws

    /**
     * Writes a BSON String to the stream.
     *
     * @param value the value
     */
    func writeString(value: String) throws

    /**
     * Writes a BSON double to the stream.
     *
     * @param value the value
     */
    func writeDouble(value: Double) throws

    /**
     * Writes a 32-bit BSON integer to the stream.
     *
     * @param value the value
     */
    func writeInt32(value: Int32) throws

    /**
     * Writes a 32-bit BSON integer to the stream at the given position.  This is useful for patching in the size of a document once the
     * last byte of it has been encoded and its size it known.
     *
     * @param position the position to write the value, which must be greater than or equal to 0 and less than or equal to the current size
     * @param value the value
     */
    func writeInt32(position: Int, value: Int32) throws

    /**
     * Writes a 64-bit BSON integer to the stream.
     *
     * @param value the value
     */
    func writeInt64(value: Int64) throws

    /**
     * Writes a BSON ObjectId to the stream.
     *
     * @param value the value
     */
    func writeObjectId(value: ObjectId) throws

    func isClosed() -> Bool
    func close()
}
