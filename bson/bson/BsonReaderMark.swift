//
//  BsonReaderMark.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Represents a bookmark that can be used to reset a {@link BsonReader} to its state at the time the mark was created.
 *
 * @see BsonReader#getMark()
 *
 * @since 3.5
 */
public protocol BsonReaderMark {
    /**
     * Reset the {@link BsonReader} to its state at the time the mark was created.
     */
    func reset()
}

