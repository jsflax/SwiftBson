//
//  BsonDocumentWrapper.swift
//  bson
//
//  Created by Jason Flax on 11/29/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public final class BsonDocumentWrapper<E>: BsonDocument where E: __Encoder__ {
    private var _unwrapped: BsonDocument?
    public var unwrapped: BsonDocument {
        get {
            if _unwrapped == nil {
                let unwrapped = BsonDocument()
                let writer = BsonDocumentWriter(document: unwrapped)
                try? encoder.encode(writer: writer,
                                    value: wrappedDocument,
                                    encoderContext: EncoderContext { _ in })
                self._unwrapped = unwrapped
            }
            return _unwrapped!
        }
    }

    public let wrappedDocument: E.Encodee
    public let encoder: E

    /**
     * Construct a new instance with the given document and encoder for the document.
     *
     * @param wrappedDocument the wrapped document
     * @param encoder  the encoder for the wrapped document
     */
    public init(wrappedDocument: E.Encodee, encoder: E) {
        self.wrappedDocument = wrappedDocument
        self.encoder = encoder
        super.init()
    }

    /**
     * Determine whether the document has been unwrapped already.
     *
     * @return true if the wrapped document has been unwrapped already
     */
    public func isUnwrapped() -> Bool {
        return _unwrapped != nil
    }

    public var count: Int { return unwrapped.count }
}
