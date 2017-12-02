//
//  NoOpFieldNameValidator.swift
//  bson
//
//  Created by Jason Flax on 12/1/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

class NoOpFieldNameValidator: FieldNameValidator {
    public init() {}
    public func validate(fieldName: String) -> Bool {
        return true;
    }

    public func getValidator(forFieldName name: String) -> FieldNameValidator {
        return self
    }
}
