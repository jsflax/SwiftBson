//
//  JsonSymbolConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class JsonSymbolConverter: Converter {
    func convert(value: String, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$symbol", string: value)
        try writer.writeEndObject()
    }
}

func AnyJsonSymbolConverter() -> AnyConverter<String> {
    return JsonSymbolConverter().wrapped()
}
