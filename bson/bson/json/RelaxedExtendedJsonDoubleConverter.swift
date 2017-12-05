//
//  RelaxedExtendedJsonDoubleConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class RelaxedExtendedJsonDoubleConverter: Converter {
    private static let fallbackConverter = ExtendedJsonDoubleConverter()

    func convert(value: Double, writer: StrictJsonWriter) throws {
        if value.isNaN || value.isInfinite {
            try RelaxedExtendedJsonDoubleConverter.fallbackConverter.convert(value: value,
                                                                             writer: writer)
        } else {
            try writer.write(number: String(value))
        }
    }
}

func AnyRelaxedExtendedJsonDoubleConverter() -> AnyConverter<Double> {
    return RelaxedExtendedJsonDoubleConverter().wrapped()
}
