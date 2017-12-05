//
//  Bytes.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public typealias Byte = UInt8

extension Array where Element == Byte {
    init(base64Encoded string: String) throws {
        guard let data = Data(base64Encoded: string) else {
            throw RuntimeError.illegalArgument(
                "Invalid base64 encoded string: \(string)")
        }

        self.init(data)
    }

    init(fromHexEncodedString hexString: String) throws {
        let hexa = [Character](hexString)
        self.init(stride(from: 0, to: hexString.count, by: 2).flatMap {
            Byte(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16)
        })
    }

    func encodeToBase64() -> String {
        return Data(self).base64EncodedString()
    }
}
