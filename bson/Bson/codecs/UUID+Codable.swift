//
//  UUIDCodec.swift
//  bson
//
//  Created by Jason Flax on 12/2/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

extension UUID: BsonCodable {
    public enum UuidCodableKeys {
        case encoderUuidRepresentation
        case decoderUuidRepresentation
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        let subType = try reader.peekBinarySubType()

        if subType != BsonBinarySubType.uuidLegacy.rawValue &&
            subType != BsonBinarySubType.uuidStandard.rawValue {
            throw BSONError.unexpected("Unexpected BsonBinarySubType");
        }

        var bytes = try reader.readBinaryData().data

        if bytes.count != 16 {
            throw BSONError.serialization("Expected length to be 16, not \(bytes.count).")
        }

        if subType == BsonBinarySubType.uuidLegacy.rawValue {
            let decoderUuidRepresentation: UuidRepresentation = try decoderContext.info(
                forKey: UuidCodableKeys.decoderUuidRepresentation)

            switch decoderUuidRepresentation {
            case .cSharpLegacy:
                reverseByteArray(data: &bytes, start: 0, count: 4)
                reverseByteArray(data: &bytes, start: 4, count: 2)
                reverseByteArray(data: &bytes, start: 6, count: 2)
            case .javaLegacy:
                reverseByteArray(data: &bytes, start: 0, count: 8)
                reverseByteArray(data: &bytes, start: 8, count: 8)
            case .pythonLegacy, .standard: break
            }
        }

        self.init(uuidString: sigBitsToUuid(mostSigBits: readLongFromArrayBigEndian(bytes: bytes, offset: 0),
                                            leastSigBits: readLongFromArrayBigEndian(bytes: bytes, offset: 8)))!
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        var binaryData = [Byte].init(repeating: 0, count: 16)

        let (mostSigBits, leastSigBits) = try mostSigLeastSigBits(from: self.uuidString)
        writeLongToArrayBigEndian(bytes: &binaryData, offset: 0, x: mostSigBits)
        writeLongToArrayBigEndian(bytes: &binaryData, offset: 8, x: leastSigBits)

        let encoderUuidRepresentation: UuidRepresentation =
            try encoderContext.info(forKey: UuidCodableKeys.decoderUuidRepresentation)
        switch encoderUuidRepresentation {
        case .cSharpLegacy:
            reverseByteArray(data: &binaryData, start: 0, count: 4)
            reverseByteArray(data: &binaryData, start: 4, count: 2)
            reverseByteArray(data: &binaryData, start: 6, count: 2)
        case .javaLegacy:
            reverseByteArray(data: &binaryData, start: 0, count: 8)
            reverseByteArray(data: &binaryData, start: 8, count: 8)
        case .pythonLegacy, .standard: break
        }
        // changed the default subtype to STANDARD since 3.0
        if encoderUuidRepresentation == .standard {
            try writer.writeBinaryData(binary: BsonBinary(data: binaryData, type: .uuidStandard))
        } else {
            try writer.writeBinaryData(binary: BsonBinary(data: binaryData, type: .uuidLegacy))
        }
    }
}

/**
 * Returns a {@code String} object representing this {@code UUID}.
 *
 * <p> The UUID string representation is as described by this BNF:
 * <blockquote><pre>
 * {@code
 * UUID                   = <time_low> "-" <time_mid> "-"
 *                          <time_high_and_version> "-"
 *                          <variant_and_sequence> "-"
 *                          <node>
 * time_low               = 4*<hexOctet>
 * time_mid               = 2*<hexOctet>
 * time_high_and_version  = 2*<hexOctet>
 * variant_and_sequence   = 2*<hexOctet>
 * node                   = 6*<hexOctet>
 * hexOctet               = <hexDigit><hexDigit>
 * hexDigit               =
 *       "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
 *       | "a" | "b" | "c" | "d" | "e" | "f"
 *       | "A" | "B" | "C" | "D" | "E" | "F"
 * }</pre></blockquote>
 *
 * @return  A string representation of this {@code UUID}
 */
private func sigBitsToUuid(mostSigBits: Int64, leastSigBits: Int64) -> String {
    return (digits(val: mostSigBits >> 32, digits: 8) + "-" +
        digits(val: mostSigBits >> 16, digits: 4) + "-" +
        digits(val: mostSigBits, digits: 4) + "-" +
        digits(val: leastSigBits >> 48, digits: 4) + "-" +
        digits(val: leastSigBits, digits: 12))
}

/** Returns val represented by the specified number of hex digits. */
private func digits(val: Int64, digits: Int) -> String {
    let hi: Int64 = Int64(1 << (digits * 4))
    let hex = String(format: "%02hhx", (hi | (val & (hi - 1))))
    return String(hex[hex.startIndex...hex.index(after: hex.startIndex)])
}

public func reverseByteArray(data: inout [Byte], start: Int, count: Int) {
    var left = start, right = start + count - 1
    while left < right {
        let temp = data[left]
        data[left]  = data[right]
        data[right] = temp

        left += 1; right -= 1
    }
}

private func writeLongToArrayBigEndian(bytes: inout [Byte], offset: Int, x: Int64) {
    bytes[offset + 7] = Byte(0xFF & (x));
    bytes[offset + 6] = Byte(0xFF & (x >> 8));
    bytes[offset + 5] = Byte(0xFF & (x >> 16));
    bytes[offset + 4] = Byte(0xFF & (x >> 24));
    bytes[offset + 3] = Byte(0xFF & (x >> 32));
    bytes[offset + 2] = Byte(0xFF & (x >> 40));
    bytes[offset + 1] = Byte(0xFF & (x >> 48));
    bytes[offset] = Byte(0xFF & (x >> 56));
}

private func readLongFromArrayBigEndian(bytes: [Byte], offset: Int) -> Int64 {
    var x: Int64 = 0;
    x |= Int64(0xFF & bytes[offset + 7])
    x |= Int64(0xFF & bytes[offset + 6]) << 8;
    x |= Int64(0xFF & bytes[offset + 5]) << 16;
    x |= Int64(0xFF & bytes[offset + 4]) << 24;
    x |= Int64(0xFF & bytes[offset + 3]) << 32;
    x |= Int64(0xFF & bytes[offset + 2]) << 40;
    x |= Int64(0xFF & bytes[offset + 1]) << 48;
    x |= Int64(0xFF & bytes[offset]) << 56;
    return x;
}

private func mostSigLeastSigBits(from uuid: String) throws -> (Int64, Int64){
    var components = uuid.split(separator: "-")
    if components.count != 5 {
        throw RuntimeError.illegalArgument("Invalid UUID string: " + uuid)
    }
    for i in 0..<5 {
        components[i] = "0x"+components[i]
    }

    var mostSigBits = try decode(nm: String(components[0]))
    mostSigBits <<= 16;
    mostSigBits |= try decode(nm: String(components[1]))
    mostSigBits <<= 16;
    mostSigBits |= try decode(nm: String(components[2]))

    var leastSigBits = try decode(nm: String(components[3]))
    leastSigBits <<= 48
    leastSigBits |= try decode(nm: String(components[4]))

    return (mostSigBits, leastSigBits)
}

/**
 * Decodes a {@code String} into a {@code Long}.
 * Accepts decimal, hexadecimal, and octal numbers given by the
 * following grammar:
 *
 * <blockquote>
 * <dl>
 * <dt><i>DecodableString:</i>
 * <dd><i>Sign<sub>opt</sub> DecimalNumeral</i>
 * <dd><i>Sign<sub>opt</sub></i> {@code 0x} <i>HexDigits</i>
 * <dd><i>Sign<sub>opt</sub></i> {@code 0X} <i>HexDigits</i>
 * <dd><i>Sign<sub>opt</sub></i> {@code #} <i>HexDigits</i>
 * <dd><i>Sign<sub>opt</sub></i> {@code 0} <i>OctalDigits</i>
 *
 * <dt><i>Sign:</i>
 * <dd>{@code -}
 * <dd>{@code +}
 * </dl>
 * </blockquote>
 *
 * <i>DecimalNumeral</i>, <i>HexDigits</i>, and <i>OctalDigits</i>
 * are as defined in section 3.10.1 of
 * <cite>The Java&trade; Language Specification</cite>,
 * except that underscores are not accepted between digits.
 *
 * <p>The sequence of characters following an optional
 * sign and/or radix specifier ("{@code 0x}", "{@code 0X}",
 * "{@code #}", or leading zero) is parsed as by the {@code
 * Long.parseLong} method with the indicated radix (10, 16, or 8).
 * This sequence of characters must represent a positive value or
 * a {@link NumberFormatException} will be thrown.  The result is
 * negated if first character of the specified {@code String} is
 * the minus sign.  No whitespace characters are permitted in the
 * {@code String}.
 *
 * @param     nm the {@code String} to decode.
 * @return    a {@code Long} object holding the {@code long}
 *            value represented by {@code nm}
 * @throws    NumberFormatException  if the {@code String} does not
 *            contain a parsable {@code long}.
 * @see java.lang.Long#parseLong(String, int)
 * @since 1.2
 */
private func decode(nm: String) throws -> Int64 {
    var radix = 10;
    var index = nm.startIndex
    var negative = false;
    let result: Int64

    if nm.count == 0 {
        throw RuntimeError.illegalArgument("Zero length string");
    }

    let firstChar = nm[nm.startIndex]
    // Handle sign, if present
    if firstChar == "-" {
        negative = true;
        index = nm.index(index, offsetBy: 1)
    } else if firstChar == "+" {
        index = nm.index(index, offsetBy: 1)
    }
    // Handle radix specifier, if present
    var sub = nm[index...nm.endIndex]
    if sub.starts(with: "0x") || sub.starts(with: "0X") {
        index = nm.index(index, offsetBy: 2)
        radix = 16
    } else if sub.starts(with: "#") {
        index = nm.index(index, offsetBy: 1)
        radix = 16
    } else if sub.starts(with: "0") && nm.count  > 1 + index.encodedOffset {
        index = nm.index(index, offsetBy: 1)
        radix = 8
    }
    sub = nm[index...nm.endIndex]
    if nm.starts(with: "-") || nm.starts(with: "+") {
        throw RuntimeError.illegalArgument("Sign character in wrong position");
    }

    if let long = Int64(String(nm[nm.startIndex...index]), radix: radix) {
        result = negative ? -long : long
    } else  {
        // If number is Long.MIN_VALUE, we'll end up here. The next line
        // handles this case, and causes any genuine format error to be
        // rethrown.
        let constant = negative ? ("-" + String(nm[index])) : String(nm[index])
        result = Int64(constant, radix: radix)!
    }
    return result
}

