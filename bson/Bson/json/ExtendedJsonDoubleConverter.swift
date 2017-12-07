//
//  ExtendedJsonDoubleConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonDoubleConverter: Converter {
    func convert(value: Double, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$numberDouble")
        try writer.write(string: String(value))
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonDoubleConverter() -> AnyConverter<Double> {
    return ExtendedJsonDoubleConverter().wrapped()
}
