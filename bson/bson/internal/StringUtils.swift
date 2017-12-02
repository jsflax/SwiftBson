//
//  StringUtils.swift
//  bson
//
//  Created by Jason Flax on 11/29/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

internal extension String {
    func join(values: Any...) -> String {
        var result = String(describing: values[0])
        for i in 1 ..< values.count {
            result += self
            result += String(describing: values[i])
        }

        return result
    }

    subscript(range: CountableClosedRange<Int>) -> Substring {
        get {
            let lower = self.index(self.startIndex, offsetBy: range.lowerBound)
            let upper = self.index(self.startIndex, offsetBy: range.upperBound)
            return self[lower...upper]
        }
    }
}

internal extension Substring {
    subscript(range: CountableClosedRange<Int>) -> Substring {
        get {
            let lower = self.index(self.startIndex, offsetBy: range.lowerBound)
            let upper = self.index(self.startIndex, offsetBy: range.upperBound)
            return self[lower...upper]
        }
    }

    subscript(range: Int) -> Character {
        get {
            let lower = self.index(self.startIndex, offsetBy: range)
            return self[lower]
        }
    }
}

internal extension Array {
    func join(separator: String) -> String {
        var result = String(describing: self[0])
        for i in 1 ..< self.count {
            result += separator
            result += String(describing: self[i])
        }

        return result
    }
}
