//
//  DynamoValue.swift
//  FluentDynamoDBDriver
//
//  Created by Joe Smith on 4/23/19.
//

import Foundation
import DynamoDB

/// 🔑 Values to uniquely identify an item stored in a DynamoDB Table
public struct DynamoValue: Codable, Equatable {
    enum DynamoValueError: Error {
        case decodingError
    }

    /// The possible values to include in a DynamoDB value
    public enum Attribute: Codable, Equatable {
        case mapping([String: Attribute])
        case null(Bool)
        case stringSet([String])
        case binary(Data)
        case string(String)
        case list([Attribute])
        case bool(Bool)
        case numberSet([String])
        case binarySet([Data])
        /// We send over all numbers to Dynamo as Strings, and cannot use Numeric
        case number(String)

        /// Encodable Support
        public func encode(to encoder: Encoder) throws {
            switch self {
            case .mapping(let map):
                var container = encoder.singleValueContainer()
                try container.encode(map)
            case .null(let null):
                var container = encoder.singleValueContainer()
                try container.encode(null)
            case .stringSet(let strings):
                var container = encoder.singleValueContainer()
                try container.encode(strings)
            case .binary(let datum):
                var container = encoder.singleValueContainer()
                try container.encode(datum)
            case .string(let value):
                var container = encoder.singleValueContainer()
                try container.encode(value)
            case .list(let attributes):
                var container = encoder.singleValueContainer()
                try container.encode(attributes)
            case .bool(let truth):
                var container = encoder.singleValueContainer()
                try container.encode(truth)
            case .numberSet(let numbers):
                var container = encoder.singleValueContainer()
                try container.encode(numbers)
            case .binarySet(let data):
                var container = encoder.singleValueContainer()
                try container.encode(data)
            case .number(let number):
                var container = encoder.singleValueContainer()
                try container.encode(number)
            }
        }

        /// Decodable Support
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode([String: Attribute].self) {
                self = .mapping(value)
                return
            }
            if let value = try? container.decode(Bool.self) {
                self = .null(value)
                return
            }
            if let value = try? container.decode([String].self) {
                self = .stringSet(value)
                return
            }
            if let value = try? container.decode(Data.self) {
                self = .binary(value)
                return
            }
            if let value = try? container.decode(String.self) {
                self = .string(value)
                return
            }
            if let value = try? container.decode([Attribute].self) {
                self = .list(value)
                return
            }
            if let value = try? container.decode(Bool.self) {
                self = .bool(value)
                return
            }
            if let value = try? container.decode([String].self) {
                self = .numberSet(value)
                return
            }
            if let value = try? container.decode([Data].self) {
                self = .binarySet(value)
                return
            }
            if let value = try? container.decode(String.self) {
                self = .number(value)
                return
            }
            throw DynamoValue.DynamoValueError.decodingError
        }
    }

    /// The friendly representation of the attributes of an item stored in DynamoDB
    /// https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
    public let attributes: [String: Attribute]

    public init(attributes: [String: Attribute]) {
        self.attributes = attributes
    }

    /// Encodable Support — Ignore "attributes"
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.attributes)
    }

    /// Decodable Support — Ignore "attributes"
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let attributes = try container.decode([String: Attribute].self)
        self = .init(attributes: attributes)
    }
    private static func decodeAttribute(_ attribute: DynamoDB.AttributeValue) -> Attribute? {
        if let mapping = attribute.m {
            var convertedMap = [String: Attribute]()
            _ = mapping.enumerated().map { _, element in
                let (key, value) = element
                convertedMap[key] = decodeAttribute(value)
            }
            return .mapping(convertedMap)
        } else if let null = attribute.null {
            return .null(null)
        } else if let stringList = attribute.ss {
            return .stringSet(stringList)
        } else if let binary = attribute.b {
            return .binary(binary)
        } else if let string = attribute.s {
            return .string(string)
        } else if let attributeList = attribute.l {
            return .list(attributeList.compactMap(decodeAttribute))
        } else if let bool = attribute.bool {
            return .bool(bool)
        } else if let numberSet = attribute.ns {
            return .numberSet(numberSet)
        } else if let binarySet = attribute.bs {
            return .binarySet(binarySet)
        } else if let number = attribute.n {
            return .number(number)
        }

        //TODO: Come up with a better idea here
        return nil
    }

    public init(attributes: [String: DynamoDB.AttributeValue]?) {
        var convertedAttributes = [String: DynamoValue.Attribute]()
        if let attributes = attributes {
            for (key, value) in attributes {
                if let mapping = value.m {
                    var convertedMap = [String: Attribute]()
                    _ = mapping.enumerated().map { _, element in
                        let (key, value) = element
                        convertedMap[key] = DynamoValue.decodeAttribute(value)
                    }
                    convertedAttributes[key] = .mapping(convertedMap)
                } else if let null = value.null {
                    convertedAttributes[key] = .null(null)
                } else if let stringList = value.ss {
                    convertedAttributes[key] = .stringSet(stringList)
                } else if let binary = value.b {
                    convertedAttributes[key] = .binary(binary)
                } else if let string = value.s {
                    convertedAttributes[key] = .string(string)
                } else if let list = value.l {
                    convertedAttributes[key] = .list(list.compactMap(DynamoValue.decodeAttribute))
                } else if let bool = value.bool {
                    convertedAttributes[key] = .bool(bool)
                } else if let numberSet = value.ns {
                    convertedAttributes[key] = .numberSet(numberSet)
                } else if let binarySet = value.bs {
                    convertedAttributes[key] = .binarySet(binarySet)
                } else if let number = value.n {
                    convertedAttributes[key] = .number(number)
                }
            }
        }
        self.attributes = convertedAttributes
    }

    // Expected to be called by `generate` so this can recursively handle maps+lists
    private func encodeAttribute(_ attribute: Attribute) -> DynamoDB.AttributeValue {
        switch attribute {
        case .mapping(let attributeMap):
            let output = attributeMap.enumerated().map { _, element -> (String, DynamoDB.AttributeValue) in
                let (key, value) = element
                return (key, encodeAttribute(value))
            }
            return DynamoDB.AttributeValue(m: Dictionary(output, uniquingKeysWith: { $1 }))
        case .null(let attributeNull):
            return DynamoDB.AttributeValue(null: attributeNull)
        case .stringSet(let attributeSet):
            return DynamoDB.AttributeValue(ss: attributeSet)
        case .binary(let attributeBinary):
            return DynamoDB.AttributeValue(b: attributeBinary)
        case .string(let attributeString):
            return DynamoDB.AttributeValue(s: attributeString)
        case .list(let attributeList):
            return DynamoDB.AttributeValue(l: attributeList.map(encodeAttribute))
        case .bool(let attributeBool):
            return DynamoDB.AttributeValue(bool: attributeBool)
        case .numberSet(let attributeSet):
            return DynamoDB.AttributeValue(ns: attributeSet)
        case .binarySet(let attributeSet):
            return DynamoDB.AttributeValue(bs: attributeSet)
        case .number(let attributeNumber):
            return DynamoDB.AttributeValue(n: attributeNumber)
        }
    }

    /// Main function to convert an Attribute into a DynamoDB.AttributeValue
    /// This generates the unique identifier for a piece of data stored in DynamoDB
    public var encodedKey: [String: DynamoDB.AttributeValue] {
        // Eventually consider Codable, perhaps
        let converted = self.attributes.enumerated().map { (arg) -> (String, DynamoDB.AttributeValue) in
            let (_, element) = arg
        var mapping: [String: DynamoDB.AttributeValue]?
        var null: Bool?
        var stringSet: [String]?
        var binary: Data?
        var string: String?
        var list: [DynamoDB.AttributeValue]?
        var bool: Bool?
        var numberSet: [String]?
        var binarySet: [Data]?
        var number: String?

        switch element.value {
        case .mapping(let attributeMap):
            let output = attributeMap.enumerated().map { _, element -> (String, DynamoDB.AttributeValue) in
                let (key, value) = element
                return (key, encodeAttribute(value))
            }
            mapping = Dictionary(output, uniquingKeysWith: { $1 })
        case .null(let attributeNull):
            null = attributeNull
        case .stringSet(let attributeSet):
            stringSet = attributeSet
        case .binary(let attributeBinary):
            binary = attributeBinary
        case .string(let attributeString):
            string = attributeString
        case .list(let attributeList):
            list = attributeList.map(encodeAttribute)
        case .bool(let attributeBool):
            bool = attributeBool
        case .numberSet(let attributeSet):
            numberSet = attributeSet
        case .binarySet(let attributeSet):
            binarySet = attributeSet
        case .number(let attributeNumber):
            number = attributeNumber
        }

        return (element.key, DynamoDB.AttributeValue(b: binary, bool: bool, bs: binarySet, l: list, m: mapping, n: number, ns: numberSet, null: null, s: string, ss: stringSet))
    }
    return Dictionary(converted, uniquingKeysWith: { $1 })
    }
}
