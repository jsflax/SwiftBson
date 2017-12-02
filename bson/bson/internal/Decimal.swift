//
//  Decimal.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

internal extension Decimal {
    var double: Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }

    var int32: Int32 {
        return NSDecimalNumber(decimal:self).int32Value
    }

    var int64: Int64 {
        return NSDecimalNumber(decimal:self).int64Value
    }
}

