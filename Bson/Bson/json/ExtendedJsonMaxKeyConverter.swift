//
//  ExtendedJsonMaxKeyConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonMaxKeyConverter: Converter {
    public func convert(value: BsonMaxKey, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$maxKey", number: "1")
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonMaxKeyConverter() -> AnyConverter<BsonMaxKey> {
    return ExtendedJsonMaxKeyConverter().wrapped()
}
