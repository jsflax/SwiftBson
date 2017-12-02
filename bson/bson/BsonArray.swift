//
//  BsonArray.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public struct BsonArray: BsonValue, Collection, ExpressibleByArrayLiteral {
    private var storage: BsonValueArray

    public typealias BsonValueArray = [BsonValue]

    public typealias Index = BsonValueArray.Index
    public typealias Element = BsonValue

    public var bsonType: BsonType = .array

    // The upper and lower bounds of the collection, used in iterations
    public var startIndex: Index { return storage.startIndex }
    public var endIndex: Index { return storage.endIndex }

    public init(_ s: [BsonValue] = [BsonValue]()) {
        storage = BsonValueArray(s)
    }
    // Required subscript, based on a dictionary index
    public subscript(index: Index) -> Element {
        get { return storage[index] }
        set(value) { storage[index] = value }
    }

    public mutating func append(_ newElement: BsonValue) {
        self.storage.append(newElement)
    }
    
    // Method that returns the next index when iterating
    public func index(after i: Index) -> Index {
        return storage.index(after: i)
    }

    public typealias ArrayLiteralElement = BsonValue

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        storage = BsonValueArray.init(elements)
    }
}
