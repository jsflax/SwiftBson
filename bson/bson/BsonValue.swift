//
//  BsonValue.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

private protocol _BsonValue {
    var bsonType: BsonType { get }
}
/**
 * Base class for any BSON type.
 *
 * @since 3.0
 */
public protocol BsonValue: Codable {

    /**
     * Gets the BSON type of this value.
     *
     * @return the BSON type, which may not be null (but may be BSONType.NULL)
     */
    var bsonType: BsonType { get }
}

extension BsonValue {
    public func isEqual(to: BsonValue) -> Bool {
        guard let sah = self as? AnyHashable,
            let tah = to as? AnyHashable else {
            return false
        }

        return sah == tah
    }

    func asType<T>(_ type: T.Type) throws -> T where T: BsonValue {
        guard let tSelf = self as? T else {
            throw BSONError.invalidOperation(
                "Value expected to be of type \(T.self) is of unexpected type \(self.bsonType)")
        }

        return tSelf
    }

    func asType<T>() throws -> T where T: BsonValue {
        guard let tSelf = self as? T else {
            throw BSONError.invalidOperation(
                "Value expected to be of type \(T.self) is of unexpected type \(self.bsonType)")
        }

        return tSelf
    }
}
