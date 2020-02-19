//
//  ContentManager.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 28/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

public class ContentManager {
    // MARK: - Properites

    internal var repository: ContentRepository & ColletionRepository

    // MARK: - Init

    init(repository: ContentRepository & ColletionRepository) {
        self.repository = repository
    }

    // MARK: - Content -

    /// Get content response for slug made on NStack web console
    ///
    /// - Parameters
    ///     slug: The string slug of the required content response
    ///     unwrapper: Optional unwrapper where to look for the required data, default is in the data object
    ///     completion: Completion block with the response as a any object if successful or error if not
    public func getContentResponse<T: Codable>(_ slug: String, key: String? = nil,
                                               completion: @escaping Completion<T>) {
        repository.fetchStaticResponse(slug, completion: completion)
    }

    // MARK: - Collections -

    /// Get collection content for id made on NStack web console
    ///
    /// - Parameters
    ///     id: The integer id of the required collection
    ///     unwrapper: Optional unwrapper where to look for the required data, default is in the data object
    ///     key: Optional string if only one property or object is required, default is nil
    ///     completion: Completion block with the response as a any object if successful or error if not
    public func fetchCollectionResponse<T: Codable>(for id: Int, completion: @escaping Completion<T>) {
        repository.fetchCollection(id, completion: completion)
    }
}
