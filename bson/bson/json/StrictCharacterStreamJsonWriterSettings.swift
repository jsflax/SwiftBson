//
//  StrictCharacterStreamJsonWriterSettings.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Settings to control the behavior of a {@code JSONWriter} instance.
 *
 * @see StrictCharacterStreamJsonWriter
 * @since 3.5
 */
public final class StrictCharacterStreamJsonWriterSettings {
    /**
     * The indentation mode.  If true, output will be indented.  Otherwise, it will all be on the same line. The default value is {@code
     * false}.
     */
    public let indent: Bool
    /**
     * The new line character(s) to use if indent mode is enabled.  The default value is {@code System.getProperty("line.separator")}.
     */
    public let newLineCharacters: String
    /**
     * The indent characters to use if indent mode is enabled.  The default value is two spaces.
     */
    public let indentCharacters: String

    public init(_ builder: Builder) {
        indent = builder.indent
        newLineCharacters = builder.newLineCharacters
        indentCharacters = builder.indentCharacters
    }

    /**
     * A builder for StrictCharacterStreamJsonWriterSettings
     *
     * @since 3.4
     */
    public struct Builder {
        public var indent = false
        public var newLineCharacters = "\n"
        public var indentCharacters = "  ";

        public init(builder: (inout Builder) -> Void) {
            builder(&self)
        }
    }
}
