//
//  FeedbackManager.swift
//  NStackSDK
//
//  Created by Jigna Patel on 06.01.20.
//  Copyright © 2020 Nodes ApS. All rights reserved.
//

import Foundation

internal class APIFeedbackManager: FeedbackManager {

    // MARK: - Properites
    internal var repository: FeedbackRepository
    // MARK: - Init
    init(repository: FeedbackRepository) {
        self.repository = repository
    }

    public func postFeedback(_ message: String, completion: @escaping Completion<Any>) {
        repository.postFeedback(message) { (result) in
            completion(result)
        }
    }
}
