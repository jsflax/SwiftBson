//
//  Bson.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

protocol Bson {
    /**
     * Render the filter into a BsonDocument.
     *
     * @param documentClass the document class in scope for the collection.  This parameter may be ignored, but it may be used to alter
     *                      the structure of the returned {@code BsonDocument} based on some knowledge of the document class.
     * @param codecRegistry the codec registry.  This parameter may be ignored, but it may be used to look up {@code Codec} instances for
     *                      the document class or any other related class.
     * @param <TDocument> the type of the document class
     * @return the BsonDocument
     */
    func toBsonDocument<TDocument>(documentClass: TDocument.Type,
                                   codecRegistry: CodecRegistry) -> BsonDocument
}
