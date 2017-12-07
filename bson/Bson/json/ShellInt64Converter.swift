//
//  ShellInt64Converter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellInt64Converter: Converter {
    func convert(value: Int64, writer: StrictJsonWriter) throws {
        if value >= Int32.min && value <= Int32.max {
            try writer.write(raw: "NumberLong(\(value))")
        } else {
            try writer.write(raw: "NumberLong(\"\(value)\")")
        }
    }
}

func AnyShellInt64Converter() -> AnyConverter<Int64> {
    return ShellInt64Converter().wrapped()
}
