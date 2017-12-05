//
//  ShellBinaryConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellBinaryConverter: Converter {
    func convert(value: BsonBinary, writer: StrictJsonWriter) throws {
        try writer.write(raw: "new BinData(\(value.type.rawValue & 0xFF), \(value.data.encodeToBase64()))")
    }
}

func AnyShellBinaryConverter() -> AnyConverter<BsonBinary> {
    return ShellBinaryConverter().wrapped()
}
