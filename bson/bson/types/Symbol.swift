//
//  Symbol.swift
//  bson
//
//  Created by Jason Flax on 12/3/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Class to hold an instance of the BSON symbol type.
 */
public class Symbol {

    public let symbol: String

    /**
     * Construct a new instance with the given symbol.
     *
     * @param symbol the symbol
     */
    public init(symbol: String) {
        self.symbol = symbol
    }
}

extension Symbol: Hashable {
    public var hashValue: Int {
        return symbol.hashValue
    }

    public static func ==(lhs: Symbol, rhs: Symbol) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}
