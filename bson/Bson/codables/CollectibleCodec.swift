//
//  CollectibleCodec.swift
//  bson
//
//  Created by Jason Flax on 11/29/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

private protocol CollectibleCodec: BsonCodable {
//    /**
//     * Generates a value for the _id field on the given document, if the document does not have one.
//     *
//     * @param document the document for which to generate a value for the _id.
//     * @return the document with the _id
//     */
//    func generateIdIfAbsentFromDocument(document: BsonDocument) -> Decodee
//
//    /**
//     * Returns true if the given document has an _id.
//     *
//     * @param document the document in which to look for an _id
//     * @return true if the document has an _id
//     */
//    func documentHasId(document: BsonDocument) -> Bool
//
//    /**
//     * Gets the _id of the given document if it contains one, otherwise throws {@code IllegalArgumentException}.  To avoid the latter case,
//     * call {@code documentHasId} first to check.
//     *
//     * @param document the document from which to get the _id
//     * @return the _id of the document
//     * @throws java.lang.IllegalStateException if the document does not contain an _id
//     */
//    func getDocumentId(document: BsonDocument) -> BoxedBsonValue
}

