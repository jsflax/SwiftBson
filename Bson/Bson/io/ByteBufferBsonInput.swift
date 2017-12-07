//
//  ByteBufferBsonInput.swift
//  bson
//
//  Created by Jason Flax on 12/5/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public class ByteBufferBsonInput: BsonInput {
    public var position: Int = 0
    private let buffer: [Byte]

    init(byteBuffer: [Byte]) {
        self.buffer = byteBuffer
    }

    public func readByte() -> Byte {
        fatalError()
    }

    public func readBytes(bytes: [Byte]) {
        fatalError()
    }

    public func readBytes(bytes: [Byte], offset: Int, count: Int) {
        fatalError()
    }

    public func readInt64() -> Int64 {
        fatalError()
    }

    public func readDouble() -> Double {
        fatalError()
    }

    public func readInt32() -> Int32 {
        fatalError()
    }

    public func readString() -> String {
        fatalError()
    }

    public func readObjectId() -> ObjectId {
        fatalError()
    }

    public func readCString() -> String {
        fatalError()
    }

    public func skipCString() {
        fatalError()
    }

    public func skip(numBytes: Int) {
        fatalError()
    }

    public func mark(readLimit: Int) {
        fatalError()
    }

    public func reset() {
        fatalError()
    }

    public func hasRemaining() -> Bool {
        fatalError()
    }
}
