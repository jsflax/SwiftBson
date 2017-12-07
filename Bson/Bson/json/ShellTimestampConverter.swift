//
//  ShellTimestampConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellTimestampConverter: Converter {
    func convert(value: BsonTimestamp, writer: StrictJsonWriter) throws {
        try writer.write(raw: "Timestamp(\(value.time), \(value.inc)")
    }
}

func AnyShellTimestampConverter() -> AnyConverter<BsonTimestamp> {
    return ShellTimestampConverter().wrapped()
}
