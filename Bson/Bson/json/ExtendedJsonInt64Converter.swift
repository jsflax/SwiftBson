//
//  ExtendedJsonInt64Converter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonInt64Converter: Converter {
    public func convert(value: Int64, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$numberLong")
        try writer.write(string: String(value))
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonInt64Converter() -> AnyConverter<Int64> {
    return ExtendedJsonInt64Converter().wrapped()
}
