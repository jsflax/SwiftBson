////
////  ChildCodecRegistry.swift
////  bson
////
////  Created by Jason Flax on 11/23/17.
////  Copyright © 2017 mongodb. All rights reserved.
////
//
//import Foundation
//
// An implementation of CodecRegistry that is used to detect cyclic dependencies between Codecs
class ChildCodecRegistry<T>: CodecRegistry {
    public let codecType: T.Type
    
    private let parent: ChildCodecRegistry?
    private let registry: ProvidersCodecRegistry

    init(registry: ProvidersCodecRegistry) {
        self.parent = nil
        self.registry = registry
        self.codecType = T.self
    }

    private init(parent: ChildCodecRegistry<T>) {
        self.parent = parent
        self.registry = parent.registry
        self.codecType = T.self
    }

    func get<U>(type: U.Type) throws -> BoxedCodec {
        if hasCycles(theType: U.self) {
            return BoxedCodec(LazyCodec<T>(registry: registry))
        } else {
            guard let codec = registry.get(registry: ChildCodecRegistry<T>(parent: self), type: U.self) else {
                throw CodecError.configuration("Codec not found for \(U.self)")
            }

            return codec
        }
    }

    private func hasCycles<T>(theType: T.Type) -> Bool {
        var current: ChildCodecRegistry? = self
        while current != nil {
            if (current!.codecType == theType) {
                return true
            }

            current = current?.parent
        }

        return false
    }
}

extension ChildCodecRegistry: Equatable {
    static func ==(lhs: ChildCodecRegistry,
                   rhs: ChildCodecRegistry) -> Bool {
        if lhs.codecType != rhs.codecType {
            return false;
        }
        if lhs.parent != rhs.parent {
            return false;
        }
        if lhs.registry != rhs.registry {
            return false;
        }

        return true;
    }
}

extension ChildCodecRegistry: Hashable {
    var hashValue: Int {
        var result = self.parent?.hashValue ?? 0
        result = 31 * result + registry.hashValue
        result = 31 * result + ObjectIdentifier(codecType).hashValue
        return result
    }
}


