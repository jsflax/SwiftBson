//
//  JsonBuffer.swift
//  bson
//
//  Created by Jason Flax on 11/26/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class JsonBuffer {
    var position: Int = 0

    private let buffer: [Character]
    private var eof: Bool = false

    init(buffer: String) {
        self.buffer = [Character](buffer)
    }

    public func read() throws -> Int {
        if eof {
            throw JSONError.parse("Trying to read past EOF.")
        } else if position >= buffer.count {
            eof = true
            return -1
        }  else {
            defer { position += 1 }
            return buffer[position].unicodeValue
        }
    }

    public func unread(c: Int) {
        eof = false
        if c != -1 && buffer[position - 1].unicodeValue == c {
            position -= 1
        }
    }

    public func substring(beginIndex: Int) -> String {
        return String(buffer[beginIndex..<buffer.endIndex])
    }

    public func substring(beginIndex: Int, endIndex: Int) -> String {
        return String(buffer[beginIndex..<endIndex])
    }
}
