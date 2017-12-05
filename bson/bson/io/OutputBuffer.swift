//
//  OutputBuffer.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * An abstract base class for classes implementing {@code BsonOutput}.
 */
public protocol OutputBuffer: BsonOutput {

    /**
     * Pipe the contents of this output buffer into the given output stream
     *
     * @param out the stream to pipe to
     * @return number of bytes written to the stream
     * @throws java.io.IOException if the stream throws an exception
     */
    func pipe(out: OutputStream) throws -> Int

    /**
     * Get a list of byte buffers that are prepared to be read from in other words, whose position is 0 and whose limit is the number of
     * bytes that should read. <p> Note that the byte buffers may be read-only. </p>
     *
     * @return the non-null list of byte buffers, in LITTLE_ENDIAN order
     */
    func getByteBuffers() throws -> [[Byte]]

    func truncateToPosition(newPosition: Int) throws

    /**
     * Write the specified byte at the specified position.
     *
     * @param position the position, which must be greater than equal to 0 and at least 4 less than the stream size
     * @param value the value to write.  The 24 high-order bits of the value are ignored.
     */
    func write(position: Int, value: Int32) throws
}

extension OutputBuffer {
    public func write(_ b: [Byte]) throws {
        try self.write(bytes: b, offset: 0, count: b.count)
    }

    public func write(bytes: [Byte], offset: Int, count: Int) throws {
        try writeBytes(bytes: bytes, offset: offset, count: count)
    }

    public func writeBytes(bytes: [Byte]) throws {
        try writeBytes(bytes: bytes, offset: 0, count: bytes.count)
    }

    public func writeInt32(value: Int) throws {
        try write(value >> 0)
        try write(value >> 8)
        try write(value >> 16)
        try write(value >> 24)
    }

    public func writeInt32(position: Int, value: Int32) throws {
        try write(position: position, value: value >> 0)
        try write(position: position + 1, value: value >> 8)
        try write(position: position + 2, value: value >> 16)
        try write(position: position + 3, value: value >> 24)
    }

    public func writeInt64(value: Int64) throws {
        try write(0xFF & (value >> 0))
        try write(0xFF & (value >> 8))
        try write(0xFF & (value >> 16))
        try write(0xFF & (value >> 24))
        try write(0xFF & (value >> 32))
        try write(0xFF & (value >> 40))
        try write(0xFF & (value >> 48))
        try write(0xFF & (value >> 56))
    }

    public func writeDouble(value x: Double) throws {
        try writeLong(value: Int64(x.bitPattern))
    }

    public func writeString(value str: String) throws {
        try writeInt32(value: Int32(0)) // making space for size
        let strLen = try writeCharacters(str: str, checkForNullCharacters: false)
        try writeInt32(position: position() - strLen - 4, value: Int32(strLen))
    }

    public func writeCString(value: String) throws {
        try writeCharacters(str: value, checkForNullCharacters: true)
    }

    public func writeObjectId(value: ObjectId) throws {
        try self.write(value.bytes)
    }

    /**
     * Gets a copy of the buffered bytes.
     *
     * @return the byte array
     * @see org.bson.io.OutputBuffer#pipe(java.io.OutputStream)
     */
    public func toByteArray() throws -> [Byte] {
        let bout = OutputStream()
        var bytes = [Byte]()
        bout.write(&bytes, maxLength: try self.pipe(out: bout))
        return bytes
    }

    public func write(_ value: Int) throws {
        try writeByte(value: Byte(value))
    }

    public func write(_ value: Int32) throws {
        try writeByte(value: Byte(value))
    }

    public func write(_ value: Int64) throws {
        try writeByte(value: Byte(value))
    }

    public func write(_ value: UInt32) throws {
        try writeByte(value: Byte(value))
    }

    /**
     * Writes the given integer value to the buffer.
     *
     * @param value the value to write
     * @see #writeInt32
     */
    public func writeInt32(value: Int32) throws {
        try writeInt32(value: value)
    }

    /**
     * Writes the given long value to the buffer.
     *
     * @param value the value to write
     * @see #writeInt64
     */
    public func writeLong(value: Int64) throws {
        try writeInt64(value: value)
    }

    @discardableResult
    private func writeCharacters(str: String, checkForNullCharacters: Bool) throws -> Int {
        let len = str.count
        var total = 0

        var i = 0
        while i < len {
            let c = str[str.index(str.startIndex, offsetBy: i)].unicodeScalarCodePoint()

            if (checkForNullCharacters && c == 0x0) {
                throw BSONError.serialization("BSON cstring '\(str)' is not valid because it contains a null character "
                    + "at index \(i)")
            }
            if c < 0x80 {
                try write(c)
                total += 1
            } else if c < 0x800 {
                try write(0xc0 + (c >> 6))
                try write(0x80 + (c & 0x3f))
                total += 2
            } else if c < 0x10000 {
                try write(0xe0 + (c >> 12))
                try write(0x80 + ((c >> 6) & 0x3f))
                try write(0x80 + (c & 0x3f))
                total += 3
            } else {
                try write(0xf0 + (c >> 18))
                try write(0x80 + ((c >> 12) & 0x3f))
                try write(0x80 + ((c >> 6) & 0x3f))
                try write(0x80 + (c & 0x3f))
                total += 4
            }


            i += c >= 0x010000 ? 2 : 1
        }

        try write(0)
        total += 1
        return total
    }
}
