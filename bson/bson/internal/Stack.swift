//
//  Stack.swift
//  bson
//
//  Created by Jason Flax on 11/29/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public struct Stack<T> {
    private var items = [T]()

    public func peek() -> T {
        return items[items.count - 1]
    }

    public mutating func push(_ item: T) {
        items.append(item)
    }

    @discardableResult
    public mutating func pop() -> T {
        return items.removeLast()
    }
}
