//
//  BsonContextType.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Used by BsonReader and BsonWriter implementations to represent the current context.
 *
 * @since 3.0
 */
public enum BsonContextType {
    /**
     * The top level of a BSON document.
     */
    case topLevel,

    /**
     * A (possibly embedded) BSON document.
     */
    document,

    /**
     * A BSON array.
     */
    array,

    /**
     * A JAVASCRIPT_WITH_SCOPE BSON value.
     */
    javascriptWithScope,

    /**
     * The scope document of a JAVASCRIPT_WITH_SCOPE BSON value.
     */
    scopeDocument
}
