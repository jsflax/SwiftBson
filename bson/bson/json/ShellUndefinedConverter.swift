//
//  ShellUndefinedConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellUndefinedConverter: Converter {
    public func convert(value: BsonUndefined, writer: StrictJsonWriter) throws {
        try writer.write(raw: "undefined")
    }
}

func AnyShellUndefinedConverter() -> AnyConverter<BsonUndefined> {
    return ShellUndefinedConverter().wrapped()
}
