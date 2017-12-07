//
//  BsonNumber.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

protocol BsonNumber: BsonValue, Hashable {
    /**
     * Returns the value of the specified number as an {@code int}, which may involve rounding or truncation.
     *
     * @return the numeric value represented by this object after conversion to type {@code int}.
     */
    var int32: Int32 { get }

    /**
     * Returns the value of the specified number as an {@code long}, which may involve rounding or truncation.
     *
     * @return the numeric value represented by this object after conversion to type {@code long}.
     */
    var int64: Int64 { get }

    /**
     * Returns the value of the specified number as a {@code double}, which may involve rounding.
     *
     * @return the numeric value represented by this object after conversion to type {@code double}.
     */
    var double: Double { get }

    /**
     * Returns the value of the specified number as a {@code Decimal128}, which may involve rounding.
     *
     * @return the numeric value represented by this object after conversion to type {@code Decimal128}.
     */
    var decimal: Decimal { get }
}
