//
//  FieldNameValidator.swift
//  bson
//
//  Created by Jason Flax on 11/29/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A field name validator, for use by BSON writers to validate field names as documents are encoded.
 *
 * @since 3.0
 */
public protocol FieldNameValidator {
    /**
     * Returns true if the field name is valid, false otherwise.
     *
     * @param fieldName the field name
     * @return true if the field name is valid, false otherwise
     */
    func validate(fieldName: String) -> Bool

    /**
     * Gets a new validator to use for the value of the field with the given name.
     *
     * @param fieldName the field name
     * @return a non-null validator
     */
    func getValidator(forFieldName name: String) -> FieldNameValidator
}
