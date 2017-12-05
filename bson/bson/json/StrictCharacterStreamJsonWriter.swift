//
//  StrictCharacterStreamJsonWriter.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * A class that writes JSON texts as a character stream via a provided {@link Writer}.
 *
 * @since 3.5
 */
public final class StrictCharacterStreamJsonWriter: StrictJsonWriter {
    private enum JsonContextType {
        case topLevel,
        document,
        array
    }

    private enum State {
        case initial,
        name,
        value,
        done
    }

    private class StrictJsonContext {
        fileprivate let parentContext: StrictJsonContext?
        fileprivate let contextType: JsonContextType
        fileprivate let indentation: String
        fileprivate var hasElements: Bool = false

        init(parentContext: StrictJsonContext?, contextType: JsonContextType, indentChars: String) {
            self.parentContext = parentContext
            self.contextType = contextType
            self.indentation = (parentContext == nil) ? indentChars : parentContext!.indentation + indentChars
        }
    }

    private var writer: TextOutputStream
    private let settings: StrictCharacterStreamJsonWriterSettings
    private var context = StrictJsonContext(parentContext: nil, contextType: JsonContextType.topLevel, indentChars: "")
    private var state: State = .initial

    /**
     * Construct an instance.
     *
     * @param writer   the writer to write JSON to.
     * @param settings the settings to apply to this writer.
     */
    public init(writer: inout TextOutputStream, settings: StrictCharacterStreamJsonWriterSettings) {
        self.writer = writer
        self.settings = settings
    }

    public func writeStartObject(name: String) throws {
        try write(name: name)
        try writeStartObject()
    }

    public func writeStartArray(name: String) throws {
        try write(name: name)
        try writeStartArray()
    }

    public func write(name: String, bool: Bool) throws {
        try write(name: name)
        try write(bool: bool)
    }

    public func write(name: String, number: String) throws {
        try write(name: name)
        try write(number: number)
    }

    public func write(name: String, string: String) throws {
        try write(name: name)
        try write(string: string)
    }

    public func write(name: String, raw: String) throws {
        try write(name: name)
        try write(raw: raw)
    }

    public func writeNull(name: String) throws {
        try write(name: name)
        try writeNull()
    }

    public func write(name: String) throws {
        try checkPreconditions(validStates: .name)

        if (context.hasElements) {
            try write(",")
        }
        if (settings.indent) {
            try write(settings.newLineCharacters)
            try write(context.indentation)
        } else {
            try write(" ")
        }
        try writeStringHelper(str: name)
        try write(" : ")

        state = .value
    }


    public func write(bool: Bool) throws {
        try checkPreconditions(validStates: .value)
        try preWriteValue()
        try write(bool ? "true" : "false")
        setNextState()
    }


    public func write(number: String) throws {
        try checkPreconditions(validStates: .value)
        try preWriteValue()
        try write(number)
        setNextState()
    }


    public func write(string: String) throws {
        try checkPreconditions(validStates: .value)
        try preWriteValue()
        try writeStringHelper(str: string)
        setNextState()
    }


    public func write(raw: String) throws {
        try checkPreconditions(validStates: .value)
        try preWriteValue()
        try write(raw)
        setNextState()
    }


    public func writeNull() throws {
        try checkPreconditions(validStates: .value)
        try preWriteValue()
        try write("null")
        setNextState()
    }


    public func writeStartObject() throws {
        try checkPreconditions(validStates: .initial, .value)
        try preWriteValue()
        try write("{")
        context = StrictJsonContext(parentContext: context,
                                    contextType: .document,
                                    indentChars: settings.indentCharacters)
        state = .name
    }


    public func writeStartArray() throws {
        try preWriteValue()
        try write("[")
        context = StrictJsonContext(parentContext: context,
                                    contextType: .array,
                                    indentChars: settings.indentCharacters)
        state = .value
    }


    public func writeEndObject() throws {
        try checkPreconditions(validStates: .name)

        if settings.indent && context.hasElements {
            try write(settings.newLineCharacters)
            try write(context.parentContext!.indentation)
        } else {
            try write(" ")
        }
        try write("}")
        context = context.parentContext!
        if context.contextType == .topLevel {
            state = .done
        } else {
            setNextState()
        }
    }


    public func writeEndArray() throws {
        try checkPreconditions(validStates: .value)

        if context.contextType != .array {
            throw BSONError.invalidOperation("Can't end an array if not in an array")
        }

        try write("]")
        context = context.parentContext!
        if context.contextType == .topLevel {
            state = .done
        } else {
            setNextState()
        }
    }

    private func preWriteValue() throws {
        if context.contextType == .array {
            if context.hasElements {
                try write(", ")
            }
        }
        context.hasElements = true
    }

    private func setNextState() {
        if context.contextType == .array {
            state = .value
        } else {
            state = .name
        }
    }

    private func writeStringHelper(str: String) throws {
        try write("\"")
        for char in str {
            let c = char.unicodeValue
            switch c {
            case "\"": try write("\\\"")
            case "\\": try write("\\\\")
            case "\u{8}": try write("\\b")
            case "\u{C}": try write("\\f")
            case "\n": try write("\\n")
            case "\r": try write("\\r")
            case "\t": try write("\\t")
            default:
                switch c {
                case .uppercaseLetters, .lowercaseLetters,
                     .decimalDigits, .symbols,
                     .punctuationCharacters, .alphanumerics,
                     .whitespaces, .decomposables:
                    try write(char)
                default:
                    try write("\\u")
                    try write(String(format: "%02hhx", (c & 0xf000) >> 12))
                    try write(String(format: "%02hhx", (c & 0x0f00) >> 8))
                    try write(String(format: "%02hhx", (c & 0x00f0) >> 4))
                    try write(String(format: "%02hhx", (c & 0x000f)))
                }
            }
        }
        try write("\"")
    }

    private func write(_ str: String) throws {
        writer.write(str)
    }

    private func write(_ c: Character) throws {
        writer.write(String(c))
    }

    private func checkPreconditions(validStates: State...) throws {
        if !checkState(validStates: validStates) {
            throw BSONError.invalidOperation("Invalid state \(state)")
        }
    }

    private func checkState(validStates: [State]) -> Bool {
        for cur in validStates {
            if (cur == state) {
                return true
            }
        }
        return false

    }
}
