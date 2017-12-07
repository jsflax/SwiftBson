//
//  JsonTokenType.swift
//  bson
//
//  Created by Jason Flax on 11/26/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

enum JsonTokenType {
    /**
     * An invalid token.
     */
    case invalid,

    /**
     * A begin array token (a '[').
     */
    beginArray,

    /**
     * A begin object token (a '{').
     */
    beginObject,

    /**
     * An end array token (a ']').
     */
    endArray,

    /**
     * A left parenthesis (a '(').
     */
    leftParen,

    /**
     * A right parenthesis (a ')').
     */
    rightParen,

    /**
     * An end object token (a '}').
     */
    endObject,

    /**
     * A colon token (a ':').
     */
    colon,

    /**
     * A comma token (a ',').
     */
    comma,

    /**
     * A Double token.
     */
    double,

    /**
     * An Int32 token.
     */
    int32,

    /**
     * And Int64 token.
     */
    int64,

    /**
     * A regular expression token.
     */
    regularExpression,

    /**
     * A string token.
     */
    string,

    /**
     * An unquoted string token.
     */
    unquotedString,

    /**
     * An end of file token.
     */
    endOfFile
}
