//
//  CodableRegistry.swift
//  bson
//
//  Created by Jason Flax on 12/2/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public class CodableRegistry {
    private let providers: [CodableProvider]

    public static func from(providers: CodableProvider...) -> CodableRegistry {
        return CodableRegistry(providers: providers)
    }

    init(providers: [CodableProvider] = []) {
        self.providers = providers
    }

    func getDecoderLambda<T>(forType type: T.Type) -> DecoderLambda? {
        for provider in providers {
            if let ini = provider.getDecoderLambda(forType: type) {
                return ini
            }
        }
        return nil
    }

    func getDecoderLambda(forIdentifier identifier: ObjectIdentifier) -> DecoderLambda? {
            for provider in providers {
                return provider.getDecoderLambda(forIdentifier: identifier)
            }
            return nil
    }

    func decode<T>(withIdentifier identifier: ObjectIdentifier,
                   reader: BsonReader,
                   decoderContext: DecoderContext) throws -> T {
        guard let decoder = getDecoderLambda(forIdentifier: identifier),
            let value = try decoder(reader, decoderContext) as? T else {
                throw BSONError.unexpected("Registry did not container decoder for type \(T.self)")
        }


        return value
    }

    subscript<T>(type: T.Type) -> DecoderLambda? {
        get {
            return self.getDecoderLambda(forType: type)
        }
    }

    subscript(type: ObjectIdentifier) -> DecoderLambda? {
        get {
            return self.getDecoderLambda(forIdentifier: type)
        }
    }
}

