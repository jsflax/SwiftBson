//
//  JsonWriterSettings.swift
//  bson
//
//  Created by Jason Flax on 12/4/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

fileprivate let jsonNullConverter = AnyJsonNullConverter()
fileprivate let jsonStringConverter = AnyJsonStringConverter()
fileprivate let jsonBooleanConverter = AnyJsonBooleanConverter()
fileprivate let jsonDoubleConverter = AnyJsonDoubleConverter()
fileprivate let extendedJsonDoubleConverter = AnyExtendedJsonDoubleConverter()
fileprivate let relaxedExtendedJsonDoubleConverter = AnyRelaxedExtendedJsonDoubleConverter()
fileprivate let jsonInt32Converter = AnyJsonInt32Converter()
fileprivate let extendedJsonInt32Converter = AnyExtendedJsonInt32Converter()
fileprivate let jsonSymbolConverter = AnyJsonSymbolConverter()
fileprivate let extendedJsonMinKeyConverter = AnyExtendedJsonMinKeyConverter()
fileprivate let shellMinKeyConverter = AnyShellMinKeyConverter()
fileprivate let extendedJsonMaxKeyConverter = AnyExtendedJsonMaxKeyConverter()
fileprivate let shellMaxKeyConverter = AnyShellMaxKeyConverter()
fileprivate let extendedJsonUndefinedConverter = AnyExtendedJsonUndefinedConverter()
fileprivate let shellUndefinedConverter = AnyShellUndefinedConverter()
fileprivate let legacyExtendedJsonDateTimeConverter = AnyLegacyExtendedJsonDateTimeConverter()
fileprivate let extendedJsonDateTimeConverter = AnyExtendedJsonDateTimeConverter()
fileprivate let relaxedExtendedJsonDateTimeConverter = AnyRelaxedExtendedJsonDateTimeConverter()
fileprivate let shellDateTimeConverter = AnyShellDateTimeConverter()
fileprivate let extendedJsonBinaryConverter = AnyExtendedJsonBinaryConverter()
fileprivate let legacyExtendedJsonBinaryConverter = AnyLegacyExtendedJsonBinaryConverter()
fileprivate let shellBinaryConverter = AnyShellBinaryConverter()
fileprivate let extendedJsonInt64Converter = AnyExtendedJsonInt64Converter()
fileprivate let relaxedExtendedJsonInt64Converter = AnyRelaxedExtendedJsonInt64Converter()
fileprivate let shellInt64Converter = AnyShellInt64Converter()
fileprivate let extendedJsonDecimalConverter = AnyExtendedJsonDecimalConverter()
fileprivate let shellDecimalConverter = AnyShellDecimalConverter()
fileprivate let extendedJsonObjectIdConverter = AnyExtendedJsonObjectIdConverter()
fileprivate let shellObjectIdConverter = AnyShellObjectIdConverter()
fileprivate let extendedJsonTimestampConverter = AnyExtendedJsonTimestampConverter()
fileprivate let shellTimestampConverter = AnyShellTimestampConverter()
fileprivate let extendedJsonRegularExpressionConverter = AnyExtendedJsonRegularExpressionConverter()
fileprivate let legacyExtendedJsonRegularExpressionConverter = AnyLegacyExtendedJsonRegularExpressionConverter()
fileprivate let shellRegularExpressionConverter = AnyShellRegularExpressionConverter()

public class JsonWriterSettings: BsonWriterSettings {
    public let indent: Bool
    public let newLineCharacters: String
    public let indentCharacters: String
    public let outputMode: JsonMode
    public let nullConverter: AnyConverter<BsonNull>
    public let stringConverter: AnyConverter<String>
    public let dateTimeConverter: AnyConverter<Int64>
    public let binaryConverter: AnyConverter<BsonBinary>
    public let boolConverter: AnyConverter<Bool>
    public let doubleConverter: AnyConverter<Double>
    public let int32Converter: AnyConverter<Int32>
    public let int64Converter: AnyConverter<Int64>
    public let decimalConverter: AnyConverter<Decimal>
    public let objectIdConverter: AnyConverter<ObjectId>
    public let timestampConverter: AnyConverter<BsonTimestamp>
    public let regularExpressionConverter: AnyConverter<BsonRegularExpression>
    public let symbolConverter: AnyConverter<String>
    public let undefinedConverter: AnyConverter<BsonUndefined>
    public let minKeyConverter: AnyConverter<BsonMinKey>
    public let maxKeyConverter: AnyConverter<BsonMaxKey>
    public let javaScriptConverter: AnyConverter<String>

    public struct Builder {
        public var indent: Bool = false
        public var newLineCharacters: String = "\n"
        public var indentCharacters: String = " "
        public var outputMode: JsonMode = .relaxed
        public var nullConverter: AnyConverter<BsonNull> = jsonNullConverter
        public var stringConverter: AnyConverter<String> = jsonStringConverter
        public var dateTimeConverter: AnyConverter<Int64>?
        public var binaryConverter: AnyConverter<BsonBinary>?
        public var boolConverter: AnyConverter<Bool> = jsonBooleanConverter
        public var doubleConverter: AnyConverter<Double>?
        public var int32Converter: AnyConverter<Int32>?
        public var int64Converter: AnyConverter<Int64>?
        public var decimalConverter: AnyConverter<Decimal>?
        public var objectIdConverter: AnyConverter<ObjectId>?
        public var timestampConverter: AnyConverter<BsonTimestamp>?
        public var regularExpressionConverter: AnyConverter<BsonRegularExpression>?
        public var symbolConverter: AnyConverter<String>?
        public var undefinedConverter: AnyConverter<BsonUndefined>?
        public var minKeyConverter: AnyConverter<BsonMinKey>?
        public var maxKeyConverter: AnyConverter<BsonMaxKey>?
        public var javaScriptConverter: AnyConverter<String>?

        public typealias SettingsBuilder = (inout Builder) -> Void

        public init() {}
        public init(builder: SettingsBuilder) {
            builder(&self)
        }
    }

    public init(_ builderLambda: (inout Builder) -> Void) {
        var builder = Builder()
        builderLambda(&builder)
        self.indent = builder.indent
        self.newLineCharacters = builder.newLineCharacters
        self.indentCharacters = builder.indentCharacters
        let outputMode = builder.outputMode
        self.outputMode = outputMode

        self.nullConverter = builder.nullConverter
        self.stringConverter = builder.stringConverter
        self.boolConverter = builder.boolConverter

        if let converter = builder.doubleConverter {
            doubleConverter = converter
        } else {
            switch outputMode {
            case .extended: doubleConverter = AnyExtendedJsonDoubleConverter()
            case .relaxed: doubleConverter = AnyRelaxedExtendedJsonDoubleConverter()
            default: doubleConverter = AnyJsonDoubleConverter()
            }
        }

        if let converter = builder.int32Converter {
            int32Converter = converter
        } else if outputMode == .extended {
            int32Converter = extendedJsonInt32Converter
        } else {
            int32Converter = jsonInt32Converter
        }

        if let converter = builder.symbolConverter {
            symbolConverter = converter
        } else {
            symbolConverter = jsonSymbolConverter
        }

        if let converter = builder.javaScriptConverter {
            javaScriptConverter = converter
        } else {
            javaScriptConverter = AnyJsonJavascriptConverter()
        }

        if let converter = builder.minKeyConverter {
            minKeyConverter = converter
        } else if outputMode == .strict || outputMode == .extended || outputMode == .relaxed {
            minKeyConverter = extendedJsonMinKeyConverter
        } else {
            minKeyConverter = shellMinKeyConverter
        }

        if let converter = builder.maxKeyConverter {
            maxKeyConverter = converter
        } else if outputMode == .strict || outputMode == .extended || outputMode == .relaxed {
            maxKeyConverter = extendedJsonMaxKeyConverter
        } else {
            maxKeyConverter = shellMaxKeyConverter
        }

        if let converter = builder.undefinedConverter {
            undefinedConverter = converter
        } else if outputMode == .strict || outputMode == .extended || outputMode == .relaxed {
            undefinedConverter = extendedJsonUndefinedConverter
        } else {
            undefinedConverter = shellUndefinedConverter
        }

        if let converter = builder.dateTimeConverter {
            dateTimeConverter = converter
        } else if outputMode == .strict {
            dateTimeConverter = legacyExtendedJsonDateTimeConverter
        } else if outputMode == .extended {
            dateTimeConverter = extendedJsonDateTimeConverter
        } else if outputMode == .relaxed {
            dateTimeConverter = relaxedExtendedJsonDateTimeConverter
        } else {
            dateTimeConverter = shellDateTimeConverter
        }

        if let converter = builder.binaryConverter {
            binaryConverter = converter
        } else if outputMode == .strict {
            binaryConverter = legacyExtendedJsonBinaryConverter
        } else if outputMode == .extended || outputMode == .relaxed {
            binaryConverter = extendedJsonBinaryConverter
        } else {
            binaryConverter = shellBinaryConverter
        }

        if let converter = builder.int64Converter {
            int64Converter = converter
        } else if outputMode == .strict || outputMode == .extended {
            int64Converter = extendedJsonInt64Converter
        } else if outputMode == .relaxed {
            int64Converter = relaxedExtendedJsonInt64Converter
        } else {
            int64Converter = shellInt64Converter
        }

        if let converter = builder.decimalConverter {
            decimalConverter = converter
        } else if outputMode == .strict || outputMode == .extended || outputMode == .relaxed {
            decimalConverter = extendedJsonDecimalConverter
        } else {
            decimalConverter = shellDecimalConverter
        }

        if let converter = builder.objectIdConverter {
            objectIdConverter = converter
        } else if outputMode == .strict || outputMode == .extended || outputMode == .relaxed {
            objectIdConverter = extendedJsonObjectIdConverter
        } else {
            objectIdConverter = shellObjectIdConverter
        }

        if let converter = builder.timestampConverter {
            timestampConverter = converter
        } else if outputMode == .strict || outputMode == .extended || outputMode == .relaxed {
            timestampConverter = extendedJsonTimestampConverter
        } else {
            timestampConverter = shellTimestampConverter
        }

        if let converter = builder.regularExpressionConverter {
            regularExpressionConverter = converter
        } else if outputMode == .extended || outputMode == .relaxed {
            regularExpressionConverter = extendedJsonRegularExpressionConverter
        } else if outputMode == .strict {
            regularExpressionConverter = legacyExtendedJsonRegularExpressionConverter
        } else {
            regularExpressionConverter = shellRegularExpressionConverter
        }

        super.init()
    }
}
