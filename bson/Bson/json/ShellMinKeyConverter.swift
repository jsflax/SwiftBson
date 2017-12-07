//
//  ShellMinKeyConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellMinKeyConverter: Converter {
    func convert(value: BsonMinKey, writer: StrictJsonWriter) throws {
        try writer.write(raw: "MinKey")
    }
}

func AnyShellMinKeyConverter() -> AnyConverter<BsonMinKey> {
    return ShellMinKeyConverter().wrapped()
}
