//
//  JsonInt32Converter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class JsonInt32Converter: Converter {
    func convert(value: Int32, writer: StrictJsonWriter) throws {
        try writer.write(number: String(value))
    }
}

func AnyJsonInt32Converter() -> AnyConverter<Int32> {
    return JsonInt32Converter().wrapped()
}
