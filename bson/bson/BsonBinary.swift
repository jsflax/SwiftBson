//
//  BsonBinary.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public class BsonBinary: BsonValue {
    public var bsonType: BsonType = .binary

    let type: BsonBinarySubType
    let data: [UInt8]

    init(data: [UInt8], type: BsonBinarySubType = .binary) {
        self.data = data
        self.type = type
    }
}

extension BsonBinary: Hashable {
    public var hashValue: Int {
        var result = Int(type.rawValue)
        result = 31 * result + data.reduce(1, { (result: Int, dat: UInt8) -> Int in
            return 31 * result + Int(dat)
        })
        return result
    }

    public static func ==(lhs: BsonBinary, rhs: BsonBinary) -> Bool {
        return lhs.data.elementsEqual(rhs.data) &&
            lhs.type == rhs.type
    }
}
