//
//  BasicOutputBuffer.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A BSON output stream that stores the output in a single, un-pooled byte array.
 */
public class BasicOutputBuffer: OutputBuffer {
    public private(set) var buffer: [Byte]? = [Byte].init(repeating: 0, count: 1024)
    private var _position: Int = 0

    /**
     * Construct an instance with the specified initial byte array size.
     *
     * @param initialSize the initial size of the byte array
     */
    public init(initialSize: Int = 1024) {
        buffer = [Byte].init(repeating: 0, count: initialSize)
    }

    public func position() throws -> Int {
        try ensureOpen()
        return _position
    }

    public func write(_ b: [Byte]) throws {
        try ensureOpen()
        try write(bytes: b, offset: 0, count: b.count)
    }

    public func writeBytes(bytes: [Byte], offset: Int, count: Int) throws {
        try ensureOpen()

        ensure(more: count)
        buffer!.append(contentsOf: bytes)
        _position += count
    }

    public func writeByte(value: Byte) throws {
        try ensureOpen()

        ensure(more: 1)
        buffer![_position] = 0xFF & value
        _position += 1
    }

    public func write(position absolutePosition: Int, value: Int32) throws {
        try ensureOpen();

        if absolutePosition < 0 {
            throw RuntimeError.illegalArgument("position must be >= 0 but was \(absolutePosition)")
        }
        if absolutePosition > _position - 1 {
            throw RuntimeError.illegalArgument("position must be <= \(_position - 1) but was \(absolutePosition)")
        }

        buffer![absolutePosition] = Byte(0xFF & value)
    }

    /**
     * @return size of data so far
     */
    public func size() throws -> Int {
        try ensureOpen()
        return _position
    }

    public func pipe(out: OutputStream) throws -> Int {
        try ensureOpen()
        out.write(buffer!, maxLength: _position)
        return _position
    }

    public func truncateToPosition(newPosition: Int) throws {
        try ensureOpen()
        if newPosition > _position || newPosition < 0 {
            throw RuntimeError.illegalArgument("")
        }
        _position = newPosition;
    }

    public func getByteBuffers() throws -> [[Byte]] {
        try ensureOpen()
        return [buffer!]
    }

    public func isClosed() -> Bool {
        return buffer == nil
    }
    public func close() {
        buffer = nil
    }

    private func ensureOpen() throws {
        if buffer == nil {
            throw RuntimeError.illegalState("The output is closed");
        }
    }

    private func ensure(more: Int) {
        let need = _position + more
        if need <= buffer!.count {
            return
        }

        var newSize = buffer!.count * 2
        if (newSize < need) {
            newSize = need + 128
        }

        var n = [Byte].init(repeating: 0, count: newSize)
        n.append(contentsOf: buffer!)
        buffer = n
    }
}
