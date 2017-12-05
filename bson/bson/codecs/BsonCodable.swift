//
//  Codec.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Instances of this class are capable of encoding and decoding an instance of the type parameter {@code Mod} into a BSON value.
 *
 * @since 3.0
 */
public protocol BsonCodable: BsonDecodable, BsonEncodable {
}
