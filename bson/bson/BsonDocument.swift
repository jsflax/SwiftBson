//
//  BsonDocument.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public typealias BsonElement = (String, BsonValue)

public class BsonDocument: BsonValue, Bson, Collection {
    public var bsonType: BsonType = .document
    private var _storage = [String: BsonValue]()

    public typealias Element = (key: String, value: BsonValue)

    public init() {
    }

    public init(dictionary: [String: BsonValue?]) {
        for (key, value) in dictionary {
            self[key] = value ?? nil
        }
    }

    public func index(after i: Dictionary<String, BsonValue>.Index) -> Dictionary<String, BsonValue>.Index {
        return self._storage.index(after: i)
    }

    public subscript(position: Dictionary<String, BsonValue>.Index) -> (key: String, value: BsonValue) {
        return self._storage[position]
    }

    public var startIndex: Dictionary<String, BsonValue>.Index {
        return self._storage.startIndex
    }

    public var endIndex: Dictionary<String, BsonValue>.Index {
        return self._storage.endIndex
    }

    public subscript(key: String) -> BsonValue? {
        get {
            return self._storage[key]
        }
        set(val) {
            self._storage[key] = val
        }
    }

    func toBsonDocument<TDocument>(documentClass: TDocument.Type,
                                   codecRegistry: CodecRegistry) -> BsonDocument {
        return self
    }

    public func isEqual(to: BsonValue) -> Bool {
        guard let to = to as? BsonDocument else {
            return false
        }

        return self == to
    }
}

extension BsonDocument: Hashable {
    public var hashValue: Int {
        return arc4random().hashValue
    }

    public static func ==(lhs: BsonDocument, rhs: BsonDocument) -> Bool {
        return try! lhs._storage.elementsEqual(rhs._storage,
                                               by: { (l: BsonElement, r: BsonElement) throws -> Bool in
            return l.0 == r.0 && l.1.isEqual(to: r.1)
        })
    }
}
extension Dictionary where Key == String, Value == Any? {
    func get<T>(forKey key: String, defaultValue: T? = nil) throws -> T {
        guard let value = self[key] as? T else {
            if let defaultValue = defaultValue {
                return defaultValue
            }

            throw BSONError.invalidOperation(
                "Value expected to be of type \(T.self) is of " +
                "unexpected type \(String(describing: self[key].self))")
        }

        return value
    }

    func objectId(forKey key: String, defaultValue: ObjectId? = nil) throws -> ObjectId {
        return try get(forKey: key, defaultValue: defaultValue)
    }
}
