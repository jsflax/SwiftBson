//
//  StringWriter.swift
//  bson
//
//  Created by Jason Flax on 12/7/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public class StringWriter: TextOutputStream {
    var chars: [Character] = []
    public func write(_ string: String) {
        chars.append(contentsOf: string)
    }
}
