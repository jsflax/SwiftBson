//
//  JsonToken.swift
//  bson
//
//  Created by Jason Flax on 11/26/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

struct JsonToken {
    let type: JsonTokenType
    let value: Any

    init(type: JsonTokenType, value: Any) {
        self.type = type
        self.value = value
    }

    func valueAs<T>() throws -> T {
        return try valueAs(type: T.self)
    }

    func valueAs<T>(type: T.Type) throws -> T {
        do {
            switch type {
            case is Byte.Type:
                if let value = value as? String {
                    return Byte(value) as! T
                } else if let value = value as? Int32 {
                    return Byte(value) as! T
                }
            case is Int32.Type:
                if let value = value as? String {
                    return Int32(value) as! T
                }
            case is Int64.Type:
                if let value = value as? Int32 {
                    return Int64(value) as! T
                } else if let value = value as? String {
                    return Int64(value) as! T
                }
            case is Double.Type:
                if let value = value as? String {
                    return Double(value) as! T
                }
            case is Decimal.Type:
                switch value {
                case let val as Int32: return Decimal(val) as! T
                case let val as Int64: return Decimal(val) as! T
                case let val as Double: return Decimal(val) as! T
                case let val as String: return Decimal(string:val) as! T
                default: break
                }
            default: break
            }
            guard let val = value as? T else {
                throw JSONError.parse("Exception converting value '\(value)' to type \(type)")
            }

            return val
        } catch let err {
            throw err
        }
    }
}
