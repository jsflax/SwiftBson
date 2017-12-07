//
//  ValueCodableProvider.swift
//  bson
//
//  Created by Jason Flax on 12/3/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public class ValueCodableProvider: CodableProvider {
    public let codables: [ObjectIdentifier: DecoderLambda] = [
        ObjectIdentifier(Bool.self): Bool.init(reader: decoderContext:)
    ]
}
