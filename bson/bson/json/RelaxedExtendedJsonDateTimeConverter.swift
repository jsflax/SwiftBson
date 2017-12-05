//
//  RelaxedExtendedJsonDateTimeConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

private let lastMsOfYear9999 = 253402300799999

class RelaxedExtendedJsonDateTimeConverter: Converter {
    private static let fallbackConverter = ExtendedJsonDateTimeConverter()

    public func convert(value: Int64, writer: StrictJsonWriter) throws {
        if value < 0 || value > lastMsOfYear9999 {
            try RelaxedExtendedJsonDateTimeConverter.fallbackConverter.convert(value: value,
                                                                               writer: writer)
        } else {
            try writer.writeStartObject()
            try writer.write(name: "$date", string: Date.init(timeIntervalSince1970: TimeInterval(value)).iso8601)
            try writer.writeEndObject()
        }
    }
}

func AnyRelaxedExtendedJsonDateTimeConverter() -> AnyConverter<Int64> {
    return RelaxedExtendedJsonDateTimeConverter().wrapped()
}
