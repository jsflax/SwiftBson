//
//  ExtendedJsonInt32Converter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonInt32Converter: Converter {
    public func convert(value: Int32, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$numberInt")
        try writer.write(string: String(value))
        try writer.writeEndObject();
    }
}

func AnyExtendedJsonInt32Converter() -> AnyConverter<Int32> {
    return ExtendedJsonInt32Converter().wrapped()
}
