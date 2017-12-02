////
////  ProvidersCodecRegistry.swift
////  bson
////
////  Created by Jason Flax on 11/22/17.
////  Copyright © 2017 mongodb. All rights reserved.
////
//
//import Foundation
//
internal final class ProvidersCodecRegistry: CodecRegistry, CodecProvider {
    private let codecProviders: [CodecProvider]
    private var codecCache = CodecCache()

    init(codecProviders: [CodecProvider]) {
        self.codecProviders = codecProviders
    }

    func get<T>(type: T.Type) throws -> BoxedCodec {
        return try get(context: ChildCodecRegistry<T>(registry: self))
    }

    func get<T>(registry: CodecRegistry, type: T.Type) -> BoxedCodec? {
        for provider in codecProviders {
            if let codec = provider.get(registry: registry, type: type) {
                return codec
            }
        }
        return nil
    }

    func get<T>(context: ChildCodecRegistry<T>) throws -> BoxedCodec {
        if !codecCache.contains(type: context.codecType) {
            for provider in codecProviders {
                if let codec = provider.get(registry: context, type: context.codecType) {
                    codecCache[context.codecType] = codec
                    return codec
                }
            }
            codecCache[context.codecType] = nil
        }
        guard let codec = codecCache[context.codecType] else {
            throw CodecError.configuration("Can't find codec for \(T.self)")
        }
        return codec
    }
}

extension ProvidersCodecRegistry: Equatable {
    static func ==(lhs: ProvidersCodecRegistry, rhs: ProvidersCodecRegistry) -> Bool {
        if lhs.codecProviders.count != rhs.codecProviders.count {
            return false
        }

        return true
    }
}

extension ProvidersCodecRegistry: Hashable {
    var hashValue: Int {
        return self.codecProviders.reduce(0, { (result, codecProvider) -> Int in
            return 31 * result + Int(arc4random())
        })
    }
}


