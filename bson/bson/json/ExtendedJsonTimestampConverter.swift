//
//  ExtendedJsonTimestampConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonTimestampConverter: Converter {
    func convert(value: BsonTimestamp, writer: StrictJsonWriter) throws {
        try writer.writeStartObject();
        try writer.writeStartObject(name: "$timestamp");
        try writer.write(name: "t", number: String(value.time))
        try writer.write(name: "i", number: String(value.inc))
        try writer.writeEndObject();
        try writer.writeEndObject();
    }
}

func AnyExtendedJsonTimestampConverter() -> AnyConverter<BsonTimestamp> {
    return ExtendedJsonTimestampConverter().wrapped()
}
