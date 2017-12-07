//
//  JsonStringConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class JsonStringConverter: Converter {
    func convert(value: String, writer: StrictJsonWriter) throws {
        try writer.write(string: value)
    }
}

func AnyJsonStringConverter() -> AnyConverter<String> {
    return JsonStringConverter().wrapped()
}
