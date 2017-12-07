//
//  LegacyExtendedJsonBinaryConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class LegacyExtendedJsonBinaryConverter: Converter {
    func convert(value: BsonBinary, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$binary", string: value.data.encodeToBase64())
        try writer.write(name: "$type", string: String.init(format: "%02X", arguments: [value.type.rawValue]))
        try writer.writeEndObject()
    }
}

func AnyLegacyExtendedJsonBinaryConverter() -> AnyConverter<BsonBinary> {
    return ExtendedJsonBinaryConverter().wrapped()
}
