//
//  ShellMaxKeyConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellMaxKeyConverter: Converter {
    func convert(value: BsonMaxKey, writer: StrictJsonWriter) throws {
        try writer.write(raw: "MaxKey")
    }
}

func AnyShellMaxKeyConverter() -> AnyConverter<BsonMaxKey> {
    return ShellMaxKeyConverter().wrapped()
}
