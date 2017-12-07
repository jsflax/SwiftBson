//
//  ExtendedJsonObjectIdConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonObjectIdConverter: Converter {
    func convert(value: ObjectId, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$oid", string: value.asHexString)
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonObjectIdConverter() -> AnyConverter<ObjectId> {
    return ExtendedJsonObjectIdConverter().wrapped()
}
