////
////  CodecCache.swift
////  bson
////
////  Created by Jason Flax on 11/23/17.
////  Copyright © 2017 mongodb. All rights reserved.
////
//
//import Foundation

struct CodecCache {
    private var codecCache = [ObjectIdentifier: BoxedCodec?]()

    func contains<T>(type: T.Type) -> Bool {
        return codecCache.contains { $0.key == ObjectIdentifier(type) }
    }
    
    subscript<T>(type: T.Type) -> BoxedCodec? {
        get {
            if let codec = codecCache[ObjectIdentifier(type)] {
                return codec
            } else {
                return nil
            }
        } set(value) {
            codecCache[ObjectIdentifier(type)] = value
        }
    }
}
