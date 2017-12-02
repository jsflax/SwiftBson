//
//  BsonWriterSettings.swift
//  bson
//
//  Created by Jason Flax on 11/29/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * All the customisable settings for writing BSON.
 *
 * @since 3.0
 */
public class BsonWriterSettings {
    public let maxSerializationDepth: Int

    /**
     * Creates a new instance of the settings with the given maximum serialization depth.
     *
     * @param maxSerializationDepth the maximum number of nested levels to serialise
     */
    public init(maxSerializationDepth: Int) {
        self.maxSerializationDepth = maxSerializationDepth
    }

    /**
     * Creates a new instance of the settings with the default maximum serialization depth of 1024.
     */
    public convenience init() {
        self.init(maxSerializationDepth: 1024)
    }
}
