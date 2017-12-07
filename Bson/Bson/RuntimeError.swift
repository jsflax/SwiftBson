//
//  RuntimeError.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public enum RuntimeError: Error {
    case unsupportedOperation(String)
    case illegalArgument(String)
    case illegalState(String)
}
