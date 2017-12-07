//
//  LegacyExtendedJsonDateTimeConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class LegacyExtendedJsonDateTimeConverter: Converter {
    func convert(value: Int64, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$date", number: String(value))
        try writer.writeEndObject()
    }
}

func AnyLegacyExtendedJsonDateTimeConverter() -> AnyConverter<Int64> {
    return LegacyExtendedJsonDateTimeConverter().wrapped()
}
