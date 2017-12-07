//
//  Binary.swift
//  bson
//
//  Created by Jason Flax on 12/3/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

/**
 * Generic binary holder.
 */
public struct Binary: BsonCodable {
    public let type: Byte
    public let data: [Byte]
    public var count: Int { return data.count }


    /**
     * Creates a Binary with the specified type and data.
     *
     * @param type the binary type
     * @param data the binary data
     */
    public init(data: [Byte], type: BsonBinarySubType = .binary) {
        self.data = data
        self.type = type.rawValue
    }

    /**
     * Creates a Binary object
     *
     * @param type type of the field as encoded in BSON
     * @param data raw data
     */
    public init(data: [Byte], type: Byte = BsonBinarySubType.binary.rawValue) {
        self.data = data
        self.type = type
    }

    public init(reader: BsonReader, decoderContext: DecoderContext) throws {
        let binaryData = try reader.readBinaryData()
        self.data = binaryData.data
        self.type = binaryData.type.rawValue
    }

    public func encode(writer: BsonWriter, encoderContext: EncoderContext) throws {
        let type = BsonBinarySubType(rawValue: self.type)
        try writer.writeBinaryData(binary: BsonBinary.init(data: self.data,
                                                           type: type!))
    }
}

extension Binary: Hashable {
    public var hashValue: Int {
        var result = Int(type)
        result = 31 * result + data.reduce(0) { 31 *  $0 + $1.hashValue }
        return result
    }

    public static func ==(lhs: Binary, rhs: Binary) -> Bool {
        return lhs.type == rhs.type && lhs.data.elementsEqual(rhs.data)
    }


}
