//
//  BsonBinarySubType.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * The Binary subtype
 *
 * @since 3.0
 */
public enum BsonBinarySubType: UInt8 {
    /**
     * Binary data.
     */
    case binary = 0x00,

    /**
     * A function.
     */
    function = 0x01,

    /**
     * Obsolete binary data subtype (use Binary instead).
     */
    oldBinary = 0x02,

    /**
     * A UUID in a driver dependent legacy byte order.
     */
    uuidLegacy = 0x03,

    /**
     * A UUID in standard network byte order.
     */
    uuidStandard = 0x04,

    /**
     * An MD5 hash.
     */
    md5 = 0x05,

    /**
     * User defined binary data.
     */
    userDefined = 0x80

    /**
     * Returns true if the given value is a UUID subtype
     *
     * @param value the subtype value as a byte
     * @return true if value is a UUID subtype
     * @since 3.4
     */
    public static func isUuid(value: UInt8) -> Bool {
        guard let subType = BsonBinarySubType(rawValue: value) else {
            return false
        }

        switch subType {
        case .uuidLegacy, .uuidStandard: return true
        default: return false
        }
    }
}
