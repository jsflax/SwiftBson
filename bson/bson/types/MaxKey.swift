//
//  MaxKey.swift
//  bson
//
//  Created by Jason Flax on 11/27/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Represent the maximum key value regardless of the key's type
 */
public final class MaxKey {
}

extension MaxKey: Equatable {
    public static func ==(lhs: MaxKey, rhs: MaxKey) -> Bool {
        return true
    }
}

extension MaxKey: Hashable {
    public var hashValue: Int { return 0 }
}
