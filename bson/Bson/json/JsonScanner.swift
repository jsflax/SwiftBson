//
//  JsonScanner.swift
//  bson
//
//  Created by Jason Flax on 11/26/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * Parses the string representation of a JSON object into a set of {@link JsonToken}-derived objects.
 *
 * @since 3.0
 */
class JsonScanner {
    private let buffer: JsonBuffer

    init(buffer: JsonBuffer) {
        self.buffer = buffer
    }

    init(json: String) {
        self.buffer = JsonBuffer(buffer: json)
    }

    /**
     * @param newPosition the new position of the cursor position in the buffer
     */
    func setBufferPosition(newPosition: Int) {
        buffer.position = newPosition
    }

    /**
     * @return the current location of the cursor in the buffer
     */
    func getBufferPosition() -> Int {
        return buffer.position
    }

    /**
     * Finds and returns the next complete token from this scanner. If scanner reached the end of the source, it will return a token with
     * {@code JSONTokenType.END_OF_FILE} type.
     *
     * @return The next token.
     * @throws JsonParseException if source is invalid.
     */
    public func nextToken() throws -> JsonToken {
        var c = try buffer.read()
        while c != -1 && c.isWhitespace {
            c = try buffer.read()
        }

        switch c {
        case -1: return JsonToken(type: .endOfFile, value: "<eof>")
        case "{": return JsonToken(type: .beginObject, value: "{")
        case "}": return JsonToken(type: .endObject, value: "}")
        case "[": return JsonToken(type: .beginArray, value: "[")
        case "]": return JsonToken(type: .endArray, value: "]")
        case "(": return JsonToken(type: .leftParen, value: "(")
        case ")": return JsonToken(type: .rightParen, value: ")")
        case ":": return JsonToken(type: .colon, value: ":")
        case ",": return JsonToken(type: .comma, value: ",")
        case "'", "\"": return try scanString(quoteCharacter: c)
        case "/": return try scanRegularExpression()
        default:
            if c == "-" || Character.isDigit(c) {
                return try scanNumber(firstChar: c)
            } else if c == "$" || c == "_" || Character.isLetter(c) {
                return try scanUnquotedString()
            } else {
                let position = buffer.position
                buffer.unread(c: c)
                throw JSONError.parse(
                    "Invalid JSON input. Position: \(position). Character: '\(c.characterValue!)'.")
            }
        }
    }

    /**
     * Reads {@code RegularExpressionToken} from source. The following variants of lexemes are possible:
     * <pre>
     *  /pattern/
     *  /\(pattern\)/
     *  /pattern/ims
     * </pre>
     * Options can include 'i','m','x','s'
     *
     * @return The regular expression token.
     * @throws JsonParseException if regular expression representation is not valid.
     */
    private func scanRegularExpression() throws -> JsonToken {
        let start = buffer.position - 1;
        var options = -1

        var state: RegularExpressionState = .inPattern
        while true {
            let c = try buffer.read()
            switch state {
            case .inPattern:
                switch c {
                case -1: state = .invalid
                case "/":
                    state = .inOptions
                    options = buffer.position
                case "\\": state = .inEscapeSequence
                default: state = .inPattern
                }
            case .inEscapeSequence:
                state = .inPattern
            case .inOptions:
                switch c {
                case "i", "m", "x", "s": state = .inOptions
                case ",", "}", "]", ")", -1: state = .done
                default:
                    if c.isWhitespace {
                        state = .done
                    } else {
                        state = .invalid
                    }
                }
            default: break
            }

            switch state {
                case .done:
                    buffer.unread(c: c)
                    let end = buffer.position
                    let regex = BsonRegularExpression(pattern: buffer.substring(beginIndex: start + 1,
                                                                                endIndex: options - 1),
                                                      options: buffer.substring(beginIndex: options,
                                                                                endIndex: end))
                    return JsonToken(type: .regularExpression, value: regex)
                case .invalid:
                    throw JSONError.parse("Invalid JSON regular expression. Position: \(buffer.position).")
                default: break
            }
        }
    }

    /**
     * Reads {@code StringToken} from source.
     *
     * @return The string token.
     */
    private func scanUnquotedString() throws -> JsonToken {
        let start = buffer.position - 1
        var c = try buffer.read()
        while c == "$" || c == "_" || c.characterValue?.isLetterOrDigit ?? false {
            c = try buffer.read()
        }
        buffer.unread(c: c)
        let lexeme = buffer.substring(beginIndex: start, endIndex: buffer.position);
        return JsonToken(type: .unquotedString, value: lexeme);
    }

    /**
     * Reads number token from source. The following variants of lexemes are possible:
     * <pre>
     *  12
     *  123
     *  -0
     *  -345
     *  -0.0
     *  0e1
     *  0e-1
     *  -0e-1
     *  1e12
     *  -Infinity
     * </pre>
     *
     * @return The number token.
     * @throws JsonParseException if number representation is invalid.
     */
    private func scanNumber(firstChar: Int) throws -> JsonToken {
        var c = firstChar

        let start = buffer.position - 1

        var state: NumberState = .sawIntegerDigits

        switch c {
        case "-": state = .sawLeadingMinus
        case "0": state = .sawLeadingZero
        default: state = .sawIntegerDigits
        }

        var type = JsonTokenType.int64

        while true {
            c = try buffer.read()
            switch state {
            case .sawLeadingMinus:
                switch c {
                case "0": state = .sawLeadingZero
                case "I": state = .sawMinusI
                default:
                    if Character.isDigit(c) {
                        state = .sawIntegerDigits
                    } else {
                        state = .invalid
                    }
                }
            case .sawLeadingZero:
                switch c {
                case ".": state = .sawDecimalPoint
                case "e", "E": state = .sawExponentLetter
                case ",", "}", "]", ")", -1: state = .done
                default:
                    if Character.isDigit(c) {
                        state = .sawIntegerDigits
                    } else if c.isWhitespace {
                        state = .done
                    } else {
                        state = .invalid
                    }
                }
            case .sawIntegerDigits:
                switch c {
                case ".": state = .sawDecimalPoint
                case "e", "E": state = .sawExponentLetter
                case ",", "}", "]", ")", -1: state = .done
                default:
                    if Character.isDigit(c) {
                        state = .sawIntegerDigits
                    } else if Character.isWhitespace(c) {
                        state = .done
                    } else {
                        state = .invalid
                    }
                    break;
                }
                break;
            case .sawDecimalPoint:
                type = .double
                if Character.isDigit(c) {
                    state = .sawFractionDigits
                } else {
                    state = .invalid
                }
            case .sawFractionDigits:
                switch (c) {
                case "e", "E": state = .sawExponentLetter
                case ",", "}", "]", ")", -1: state = .done
                default:
                    if Character.isDigit(c) {
                        state = .sawFractionDigits
                    } else if Character.isWhitespace(c) {
                        state = .done
                    } else {
                        state = .invalid
                    }
                }
            case .sawExponentLetter:
                type = .double
                switch (c) {
                case "+", "-": state = .sawExponentSign
                default:
                    if Character.isDigit(c) {
                        state = .sawExponentDigits
                    } else {
                        state = .invalid
                    }
                }
            case .sawExponentSign:
                if Character.isDigit(c) {
                    state = .sawExponentDigits
                } else {
                    state = .invalid
                }
            case .sawExponentDigits:
                switch c {
                case ",", "}", "]", ")": state = .done
                default:
                    if Character.isDigit(c) {
                        state = .sawExponentDigits
                    } else if Character.isWhitespace(c) {
                        state = .done
                    } else {
                        state = .invalid
                    }
                }
            case .sawMinusI:
                var sawMinusInfinity = true
                let nfinity: [Character] = ["n", "f", "i", "n", "i", "t", "y"]
                for char in nfinity {
                    if c != char {
                        sawMinusInfinity = false
                        break
                    }
                    c = try buffer.read()
                }

                if sawMinusInfinity {
                    type = .double
                    switch (c) {
                    case ",", "}", "]", ")", -1: state = .done
                    default:
                        if Character.isWhitespace(c) {
                            state = .done
                        } else {
                            state = .invalid
                        }
                    }
                } else {
                    state = .invalid
                }
            default: break
            }

            switch state {
            case .invalid:
                throw JSONError.parse("Invalid JSON number")
            case .done:
                buffer.unread(c: c)
                let lexeme = buffer.substring(beginIndex: start,
                                              endIndex: buffer.position)
                if type == .double {
                    guard let double = Double(lexeme) else {
                        throw JSONError.parse(
                            "Invalid JSON input. Position: \(buffer.position). Character: '\(c.characterValue!)'.")
                    }
                    return JsonToken(type: .double, value: double)
                } else {
                    guard let value = Int64(lexeme) else {
                        throw JSONError.parse(
                            "Invalid JSON input. Position: \(buffer.position). Character: '\(c.characterValue!)'.")
                    }
                    if value < Int32.min || value > Int32.max {
                        return JsonToken(type: .int64, value: value);
                    } else {
                        return JsonToken(type: .int32, value: Int32(value));
                    }
                }
            default: break
            }
        }
    }

    /**
     * Reads {@code StringToken} from source.
     *
     * @return The string token.
     */
    private func scanString(quoteCharacter: Int) throws -> JsonToken {
        var sb = ""
        while true {
            var c = try buffer.read()
            switch c {
            case "\\":
                c = try buffer.read()
                switch c {
                case "'", "\"", "\\", "/":
                    sb += String(c.characterValue!)
                case "b", "f", "n", "r", "t":
                    sb += "\\" + String(c.characterValue!)
                case "u":
                    // Swift does UnicodeScalars different than most modern languages,
                    // forcing you to use the hex string, which in Swift is surrounded
                    // by braces
                    guard case var u = try buffer.read(),
                        u == "{" else { fallthrough }

                    var hex = [Character]()
                    u = try buffer.read()
                    while u != -1 && u != "}" {
                        hex.append(u.characterValue!)
                        u = try buffer.read()
                    }
                    if u != -1 {
                        guard let int = Int(String(hex), radix: 16)?.characterValue else {
                            fallthrough
                        }
                        sb += String(int)
                    }
                default:
                    throw JSONError.parse(
                        "Invalid escape sequence in JSON string '\\\(String(describing: c.characterValue))'.")
                }
            default:
                if c == quoteCharacter {
                    return JsonToken(type: .string, value: sb)
                }
                if c != -1 {
                    sb.append(String(c.characterValue!))
                }
            }
            if c == -1 {
                throw JSONError.parse("End of file in JSON string.");
            }
        }
    }

    private enum NumberState {
        case sawLeadingMinus,
        sawLeadingZero,
        sawIntegerDigits,
        sawDecimalPoint,
        sawFractionDigits,
        sawExponentLetter,
        sawExponentSign,
        sawExponentDigits,
        sawMinusI,
        done,
        invalid
    }

    private enum RegularExpressionState {
        case inPattern,
        inEscapeSequence,
        inOptions,
        done,
        invalid
    }
}
