//
//  CodecProvider.swift
//  bson
//
//  Created by Jason Flax on 12/2/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public typealias DecoderLambda = (BsonReader, DecoderContext) throws -> Any

prefix operator *
prefix  func *<T>(type: T.Type) -> ObjectIdentifier {
    return ObjectIdentifier(type)
}
public protocol CodableProvider {
    var codables: [ObjectIdentifier: DecoderLambda] { get }
}

extension CodableProvider {
    func getDecoderLambda(forIdentifier identifier: ObjectIdentifier) -> DecoderLambda? {
        return codables[identifier]
    }

    func getDecoderLambda<T>(forType type: T.Type) -> DecoderLambda? {
        return codables[ObjectIdentifier(type)] as? (BsonReader, DecoderContext) throws -> T
    }

    subscript<T>(type: T.Type) -> DecoderLambda? {
        get {
            return self.getDecoderLambda(forType: type)
        }
    }

    subscript(oid: ObjectIdentifier) -> DecoderLambda? {
        get {
            return self.getDecoderLambda(forIdentifier: oid)
        }
    }
}
