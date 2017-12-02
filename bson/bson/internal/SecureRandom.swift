//
//  SecureRandom.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Security

class SecureRandom {
    let bytesCount = 4 // number of bytes
    var randomNum: UInt32 = 0 // variable for random unsigned 32 bit integer
    lazy var randomBytes = [UInt8](repeating: 0, count: bytesCount) // array to hold randoms bytes

    var randoms = [Int]()

    init() {
    }

    func nextInt() -> Int {
        return Int(SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes))
    }
}
