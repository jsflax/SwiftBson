//
//  JsonMode.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * An enumeration of the supported output modes of {@code JSONWriter}.
 *
 * @see JsonWriter
 * @since 3.0
 */
public enum JsonMode {
    /**
     * Strict mode representations of BSON types conform to the <a href="http://www.json.org">JSON RFC spec</a>.
     *
     * @deprecated  The format generated with this mode is no longer considered standard for MongoDB tools.
     */
    @available(*, deprecated, message: "The format generated with this mode is no longer considered standard for MongoDB tools.")
    case strict

    /**
     * While not formally documented, this output mode will attempt to produce output that corresponds to what the MongoDB shell actually
     * produces when showing query results.
     */
    case shell,

    /**
     * Standard extended JSON representation.
     *
     * @since 3.5
     * @see <a href="https://github.com/mongodb/specifications/blob/master/source/extended-json.rst">Extended JSON Specification</a>
     */
    extended,

    /**
     * Standard relaxed extended JSON representation.
     *
     * @since 3.5
     * @see <a href="https://github.com/mongodb/specifications/blob/master/source/extended-json.rst">Extended JSON Specification</a>
     */
    relaxed
}

