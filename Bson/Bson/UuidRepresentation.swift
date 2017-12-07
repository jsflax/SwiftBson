//
//  UuuidRepresentation.swift
//  bson
//
//  Created by Jason Flax on 12/3/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * The representation to use when converting a UUID to a BSON binary value.
 * This class is necessary because the different drivers used to have different
 * ways of encoding UUID, with the BSON subtype: \x03 UUID old.
 *
 * @since 3.0
 */
public enum UuidRepresentation {
    /**
     * The canonical representation of UUID
     *
     * BSON binary subtype 4
     */
    case standard,

    /**
     * The legacy representation of UUID used by the C# driver
     *
     * BSON binary subtype 3
     */
    cSharpLegacy,

    /**
     * The legacy representation of UUID used by the Java driver
     *
     * BSON binary subtype 3
     */
    javaLegacy,

    /**
     * The legacy representation of UUID used by the Python driver, which is the same
     * format as STANDARD, but has the UUID old BSON subtype (\x03)
     *
     * BSON binary subtype 3
     */
    pythonLegacy
}
