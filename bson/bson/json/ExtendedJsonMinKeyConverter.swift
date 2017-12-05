//
//  ExtendedJsonMinKeyConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonMinKeyConverter: Converter {
    public func convert(value: BsonMinKey, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$minKey", number: "1")
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonMinKeyConverter() -> AnyConverter<BsonMinKey> {
    return ExtendedJsonMinKeyConverter().wrapped()
}
