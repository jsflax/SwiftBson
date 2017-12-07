//
//  JsonDoubleConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class JsonDoubleConverter: Converter {
    func convert(value: Double, writer: StrictJsonWriter) throws {
        try writer.write(number: String(value))
    }
}

func AnyJsonDoubleConverter() -> AnyConverter<Double> {
    return JsonDoubleConverter().wrapped()
}
