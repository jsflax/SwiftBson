//
//  ShellObjectIdConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class ShellObjectIdConverter: Converter {
    public func convert(value: ObjectId, writer: StrictJsonWriter) throws {
        try writer.write(raw: "ObjectId(\"\(value.asHexString)\")")
    }
}

func AnyShellObjectIdConverter() -> AnyConverter<ObjectId> {
    return ShellObjectIdConverter().wrapped()
}
