//
//  ExtendedJsonUndefinedConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonUndefinedConverter: Converter {
    func convert(value: BsonUndefined, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$undefined", bool: true)
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonUndefinedConverter() -> AnyConverter<BsonUndefined> {
    return ExtendedJsonUndefinedConverter().wrapped()
}
