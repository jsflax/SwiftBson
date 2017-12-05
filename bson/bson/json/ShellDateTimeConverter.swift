//
//  ShellDateTimeConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellDateTimeConverter: Converter {
    func convert(value: Int64, writer: StrictJsonWriter) throws {
        if value >= -59014396800000 && value <= 253399536000000 {
            try writer.write(raw: "ISODate(\"\(Date(timeIntervalSince1970: TimeInterval(value)).iso8601)\")")
        } else {
            try writer.write(raw: "new Date(\(value))")
        }
    }
}

func AnyShellDateTimeConverter() -> AnyConverter<Int64> {
    return ShellDateTimeConverter().wrapped()
}
