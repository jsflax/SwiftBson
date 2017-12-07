//
//  RelaxedExtendedJsonInt64Converter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class RelaxedExtendedJsonInt64Converter: Converter {
    func convert(value: Int64, writer: StrictJsonWriter) throws {
        try writer.write(number: String(value))
    }
}

func AnyRelaxedExtendedJsonInt64Converter() -> AnyConverter<Int64> {
    return RelaxedExtendedJsonInt64Converter().wrapped()
}
