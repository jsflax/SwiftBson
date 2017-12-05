//
//  LegacyExtendedJsonRegularExpressionConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class LegacyExtendedJsonRegularExpressionConverter: Converter {
    func convert(value: BsonRegularExpression, writer: StrictJsonWriter) throws {
        try writer.writeStartObject()
        try writer.write(name: "$regex", string: value.pattern)
        try writer.write(name: "$options", string: value.options)
        try writer.writeEndObject()
    }
}

func AnyLegacyExtendedJsonRegularExpressionConverter() -> AnyConverter<BsonRegularExpression> {
    return LegacyExtendedJsonRegularExpressionConverter().wrapped()
}
