////
////  MapOfCodecsProvider.swift
////  bson
////
////  Created by Jason Flax on 11/24/17.
////  Copyright © 2017 mongodb. All rights reserved.
////

import Foundation

class MapOfCodecsProvider: CodecProvider {
    private var codecsMap = [ObjectIdentifier: BoxedCodec]()

    init(codecsList: [BoxedCodec]) {
        codecsList.forEach {
            codecsMap[ObjectIdentifier($0.self)] = $0
        }
    }

    func get<T>(registry: CodecRegistry, type: T.Type) -> BoxedCodec? {
        guard let codec = codecsMap[ObjectIdentifier(T.self)] else {
            return nil
        }
        return codec
    }
}
