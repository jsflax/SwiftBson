//
//  Transformer.swift
//  bson
//
//  Created by Jason Flax on 12/2/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Transforms objects that can be converted to BSON into other Java types, and vice versa.
 */
public protocol Transformer {
    /**
     * Turns the {@code objectToTransform} into some other {@code Object}. This can either be turning a simple BSON-friendly object into a
     * different Java type, or it can be turning a Java type that can't automatically be converted into BSON into something that can.
     *
     * @param objectToTransform the object that needs to be transformed.
     * @return the new transformed object.
     */
    func transform(objectToTransform: Any) -> Any
}
