//
//  JsonJavascriptConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class JsonJavascriptConverter: Converter {
    func convert(value: String, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$code", string: value)
        try writer.writeEndObject();
    }
}

func AnyJsonJavascriptConverter() -> AnyConverter<String> {
    return JsonJavascriptConverter().wrapped()
}
