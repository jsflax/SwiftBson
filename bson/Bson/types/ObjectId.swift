//
//  ObjectId.swift
//  bson
//
//  Created by Jason Flax on 11/25/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

/**
 * <p>A globally unique identifier for objects.</p>
 *
 * <p>Consists of 12 bytes, divided as follows:</p>
 * <table border="1">
 *     <caption>ObjectID layout</caption>
 *     <tr>
 *         <td>0</td><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td><td>11</td>
 *     </tr>
 *     <tr>
 *         <td colspan="4">time</td><td colspan="3">machine</td> <td colspan="2">pid</td><td colspan="3">inc</td>
 *     </tr>
 * </table>
 *
 * <p>Instances of this class are immutable.</p>
 *
 * @mongodb.driver.manual core/object-id ObjectId
 */
private let lowOrderThreeBytes = 0x00ffffff;

public final class ObjectId: BsonCodable {
    public static let machineIdentifier: Int = createMachineIdentifier()
    public static let processIdentifier: Int16 = createProcessIdentifier()

    public static let nextCounter = AtomicInteger(value: SecureRandom().nextInt());

    private static let hexChars: [Character] = "0123456789abcdef".map { $0 }

    public let timestamp: Int64
    public let machineIdentifier: Int
    public let processIdentifier: Int16
    public let counter: Int

    public let bytes: [Byte]

    /**
     * Gets a new object id.
     *
     * @return the new id
     */
    public static func get() throws -> ObjectId {
        return try ObjectId()
    }

    /**
     * Checks if a string could be an {@code ObjectId}.
     *
     * @param hexString a potential ObjectId as a String.
     * @return whether the string could be an object id
     * @throws IllegalArgumentException if hexString is null
     */
    public static func isValid(hexString: String) -> Bool {
        let len = hexString.count
        if (len != 24) {
            return false
        }

        for c in hexString {
            if (c >= "0" && c <= "9") {
                continue;
            }
            if (c >= "a" && c <= "f") {
                continue;
            }
            if (c >= "A" && c <= "F") {
                continue;
            }

            return false;
        }

        return true
    }

    public init(timestamp: Int64 = Int64(Date().timeIntervalSinceNow * 1000),
                 machineIdentifier: Int = ObjectId.machineIdentifier,
                 processIdentifier: Int16 = ObjectId.processIdentifier,
                 counter: Int = ObjectId.nextCounter.incrementAndGet(),
                 checkCounter: Bool = true) throws {
        if ((machineIdentifier & 0xff000000) != 0) {
            throw RuntimeError.illegalArgument(
                "The machine identifier must be between 0 and 16777215 (it must fit in three bytes).")
        }
        if (checkCounter && ((counter & 0xff000000) != 0)) {
            throw RuntimeError.illegalArgument(
                "The counter must be between 0 and 16777215 (it must fit in three bytes).")
        }

        self.timestamp = timestamp
        self.machineIdentifier = machineIdentifier
        self.processIdentifier = processIdentifier
        self.counter = counter & lowOrderThreeBytes

        let data = NSMutableData()
        var tsTemp = timestamp
        data.append(&tsTemp, length: 4)

        var miTemp = machineIdentifier
        data.append(&miTemp, length: 3)

        var piTemp = processIdentifier
        data.append(&piTemp, length: 2)

        var coTemp = counter
        data.append(&coTemp, length: 3)

        self.bytes = [Byte]((data.copy() as! NSData) as Data)
    }

    /**
     * Constructs a new instance from a 24-byte hexadecimal string representation.
     *
     * @param hexString the string to convert
     * @throws IllegalArgumentException if the string is not a valid hex string representation of an ObjectId
     */
    public convenience init(hexString: String) throws {
        try self.init(bytes: try parseHexString(hexString))
    }

    /**
     * Constructs a new instance from the given ByteBuffer
     *
     * @param buffer the ByteBuffer
     * @throws IllegalArgumentException if the buffer is null or does not have at least 12 bytes remaining
     * @since 3.4
     */
    public init(bytes: [Byte]) throws {
        assert(bytes.count >= 12)

        self.timestamp = Int64(
            bigEndian: Data(bytes: bytes[0...3]).withUnsafeBytes { $0.pointee }
        )

        self.machineIdentifier = Int(
            bigEndian: Data(bytes: [0] + bytes[4...6]).withUnsafeBytes { $0.pointee }
        )

        self.processIdentifier = Int16(
            bigEndian: Data(bytes: [0, 0] + bytes[7...8]).withUnsafeBytes { $0.pointee }
        )

        self.counter = Int(
            bigEndian: Data(bytes: [0] + bytes[9...11]).withUnsafeBytes { $0.pointee }
        )

        self.bytes = bytes
    }

    public convenience init(reader: BsonReader, decoderContext: DecoderContext) throws {
        try self.init(bytes: try reader.readObjectId().bytes)
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        try writer.writeObjectId(objectId: self)
    }
    
    /**
     * Converts this instance into a 24-byte hexadecimal string representation.
     *
     * @return a string representation of the ObjectId in hexadecimal format
     */
    public var asHexString: String {
        return self.bytes.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension ObjectId: CustomStringConvertible {
    public var description: String {
        return self.asHexString
    }
}

extension ObjectId: Equatable {
    public static func ==(lhs: ObjectId, rhs: ObjectId) -> Bool {
        if lhs.counter != rhs.counter {
            return false
        }
        if (lhs.machineIdentifier != rhs.machineIdentifier) {
            return false
        }
        if (lhs.processIdentifier != rhs.processIdentifier) {
            return false
        }
        if (lhs.timestamp != rhs.timestamp) {
            return false
        }

        return true
    }
}

extension ObjectId: Comparable {
    public static func <(lhs: ObjectId, rhs: ObjectId) -> Bool {
        for i in 0 ..< 12 {
            if (lhs.bytes[i] != rhs.bytes[i]) {
                return ((lhs.bytes[i] & 0xff) < (rhs.bytes[i] & 0xff))
            }
        }
        return false
    }
}

extension ObjectId: Hashable {
    public var hashValue: Int {
        var result = Int(timestamp)
        result = 31 * result + machineIdentifier
        result = 31 * result + Int(processIdentifier)
        result = 31 * result + counter
        return result
    }
}

private func createMachineIdentifier() -> Int {
    // build a 2-byte machine piece based on NICs info
    var machinePiece: Int
    var sb = ""
    var ifaddrsPtr : UnsafeMutablePointer<ifmaddrs>? = nil
    if getifmaddrs(&ifaddrsPtr) == 0 {
        var ifaddrPtr = ifaddrsPtr
        while ifaddrPtr != nil {
            let addr = ifaddrPtr?.pointee.ifma_addr.pointee
            sb += String(describing: addr?.sa_data.0)
            sb += String(describing: addr?.sa_data.1)
            sb += String(describing: addr?.sa_data.2)

            ifaddrPtr = ifaddrPtr?.pointee.ifma_next
        }
        freeifmaddrs(ifaddrsPtr)
        machinePiece = sb.hashValue
    } else {
        // exception sometimes happens with IBM JVM, use random
        machinePiece = SecureRandom().nextInt()
    }

    machinePiece = machinePiece & lowOrderThreeBytes
    return machinePiece
}

// Creates the process identifier.  This does not have to be unique per class loader because
// NEXT_COUNTER will provide the uniqueness.
private func createProcessIdentifier() -> Int16 {
    return Int16(getpid())
}

private func parseHexString(_ s: String) throws -> [Byte] {
    if !ObjectId.isValid(hexString: s) {
        throw RuntimeError.illegalArgument(
            "invalid hexadecimal representation of an ObjectId: [\(s)]")
    }

    var b = Array<UInt8>.init(repeating: 0, count: 12)
    let s = [Character](s)
    for i in 0 ..< b.count {
        b[i] = UInt8(String(s[i * 2 ..< i * 2 + 2]), radix: 16)!
    }

    return b
}
