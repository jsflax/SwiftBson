//
//  ExtendedJsonBinaryConverter.swift
//  bson
//
//  Created by Jason Flax on 12/2/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonBinaryConverter: Converter {
    func convert(value: BsonBinary, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.writeStartObject(name: "$binary")
        try writer.write(name: "base64", string: Data(value.data).base64EncodedString())
        try writer.write(name: "subType", string: String.init(format: "%02X", value.type.rawValue))
        try writer.writeEndObject()
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonBinaryConverter() -> AnyConverter<BsonBinary> {
    return ExtendedJsonBinaryConverter().wrapped()
}
