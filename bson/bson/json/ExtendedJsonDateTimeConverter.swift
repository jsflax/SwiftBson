//
//  ExtendedJsonDateTimeConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation


class ExtendedJsonDateTimeConverter: Converter {
    public func convert(value: Int64, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.writeStartObject(name: "$date")
        try writer.write(name: "$numberLong", string: String(value))
        try writer.writeEndObject()
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonDateTimeConverter() -> AnyConverter<Int64> {
    return ExtendedJsonDateTimeConverter().wrapped()
}
