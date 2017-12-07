//
//  JsonBoolConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class JsonBooleanConverter: Converter {
    func convert(value: Bool, writer: StrictJsonWriter) throws {
        try writer.write(bool: value)
    }
}

func AnyJsonBooleanConverter() -> AnyConverter<Bool> {
    return JsonBooleanConverter().wrapped()
}
