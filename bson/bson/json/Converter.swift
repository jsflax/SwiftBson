//
//  Converter.swift
//  bson
//
//  Created by Jason Flax on 12/2/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A converter from a BSON value to JSON.
 *
 * @param <T> the value type to convert
 * @since 3.5
 */
public protocol Converter {
    associatedtype T

    /**
     * Convert the given value to JSON using the JSON writer.
     *
     * @param value the value, which may be null depending on the type
     * @param writer the JSON writer
     */
    func convert(value: T, writer: StrictJsonWriter) throws -> Void
}

extension Converter {
    public func wrapped() -> AnyConverter<T> {
        return AnyConverter(self)
    }
}

public final class AnyConverter<T>: Converter {
    private let _convert: (T, StrictJsonWriter) throws -> Void

    init<U: Converter>(_ converter: U) where U.T == T {
        _convert = converter.convert
    }

    public func convert(value: T, writer: StrictJsonWriter) throws {
        try _convert(value, writer)
    }
}

