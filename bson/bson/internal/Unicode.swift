//
//  Character.swift
//  bson
//
//  Created by Jason Flax on 11/26/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

internal extension Character {
    var unicodeValue: Int {
        guard let value = UnicodeScalar(String(self))?.value else {
            return -1
        }

        return Int(value)
    }

    internal static func isDigit(_ int: Int) -> Bool {
        return int.characterValue?.isDigit ?? false
    }

    internal static func isLetter(_ int: Int) -> Bool {
        return int.characterValue?.isLetter ?? false
    }

    internal static func isWhitespace(_ int: Int) -> Bool {
        return int.isWhitespace
    }

    var isDigit: Bool {
        guard let scalar = String(self).unicodeScalars.first else {
            return false
        }
        return CharacterSet.decimalDigits.contains(scalar)
    }

    var isLetter: Bool {
        guard let scalar = String(self).unicodeScalars.first else {
            return false
        }
        return CharacterSet.letters.contains(scalar)
    }

    var isLetterOrDigit: Bool {
        guard let scalar = String(self).unicodeScalars.first else {
            return false
        }

        return CharacterSet.alphanumerics.contains(scalar)
    }

    internal static func !=(lhs: Character, rhs: Int) -> Bool {
        let int = lhs.unicodeValue
        return int != rhs
    }
}

internal extension Int {
    var characterValue: Character? {
        guard self >= 0, let scalar = UnicodeScalar(self) else {
            return nil
        }
        return Character(scalar)
    }

    var isWhitespace: Bool {
        guard let scalar = UnicodeScalar(self) else {
            return false
        }

        return CharacterSet.whitespaces.contains(scalar)
    }

    internal static func !=(lhs: Int, rhs: Character) -> Bool {
        guard let char = lhs.characterValue else { return false }
        return char != rhs
    }

    internal static func ==(lhs: Int, rhs: Character) -> Bool {
        guard let char = lhs.characterValue else { return false }
        return char == rhs
    }

    internal static func ~=(pattern: Character, value: Int) -> Bool {
        return value == pattern
    }
}
