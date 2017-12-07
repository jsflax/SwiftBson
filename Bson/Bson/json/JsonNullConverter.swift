//
//  JsonNullConverter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class JsonNullConverter: Converter {
    func convert(value: BsonNull, writer: StrictJsonWriter) throws {
        try writer.writeNull()
    }
}

func AnyJsonNullConverter() -> AnyConverter<BsonNull> {
    return JsonNullConverter().wrapped()
}
