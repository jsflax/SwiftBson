//
//  ExtendedJsonRegularExpressionConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ExtendedJsonRegularExpressionConverter: Converter {
    func convert(value: BsonRegularExpression, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.writeStartObject(name: "$regularExpression")
        try writer.write(name: "pattern", string: value.pattern)
        try writer.write(name: "options", string: value.options)
        try writer.writeEndObject()
        try writer.writeEndObject()
    }
}

func AnyExtendedJsonRegularExpressionConverter() -> AnyConverter<BsonRegularExpression> {
    return ExtendedJsonRegularExpressionConverter().wrapped()
}
