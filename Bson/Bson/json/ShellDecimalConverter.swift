//
//  ShellDecimalConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellDecimalConverter: Converter {
    func convert(value: Decimal, writer: StrictJsonWriter) throws {
        try writer.write(raw: "NumberDecimal(\"\(String(describing: value))\")")
    }
}

func AnyShellDecimalConverter() -> AnyConverter<Decimal> {
    return ShellDecimalConverter().wrapped()
}
