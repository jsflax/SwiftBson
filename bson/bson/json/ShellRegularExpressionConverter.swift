//
//  ShellRegularExpressionConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellRegularExpressionConverter: Converter {
    func convert(value: BsonRegularExpression, writer: StrictJsonWriter) throws {
        let escaped = (value.pattern == "") ? "(?:)" : value.pattern.replacingOccurrences(of: "/",
                                                                                          with: "\\/")
        try writer.write(raw: "/" + escaped + "/" + value.options)
    }
}

func AnyShellRegularExpressionConverter() -> AnyConverter<BsonRegularExpression> {
    return ShellRegularExpressionConverter().wrapped()
}
