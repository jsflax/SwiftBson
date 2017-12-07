//
//  ExtendedJsonDecimalConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonDecimalConverter: Converter {
    public func convert(value: Decimal, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$numberDecimal")
        try writer.write(string: String(describing: value))
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonDecimalConverter() -> AnyConverter<Decimal> {
    return ExtendedJsonDecimalConverter().wrapped()
}
