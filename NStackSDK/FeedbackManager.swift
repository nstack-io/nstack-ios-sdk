//
//  FeedbackManager.swift
//  NStackSDK
//
//  Created by Tiago Bras on 31/10/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class FeedbackManager {
    // MARK: - Properties
    internal var repository: FeedbackRepository

    // MARK: - Init
    init(repository: FeedbackRepository) {
        self.repository = repository
    }

    #if canImport(UIKit)
    /// Sends app feedback.
    ///
    /// - Parameter type: Feedback type, can be either **bug** or **feedback**.
    /// - Parameter appVersion: App Version.
    /// - Parameter message: Content of the feedback, eg, explaining a bug.
    /// - Parameter name: Reporter's name.
    /// - Parameter email: Reporter's email.
    /// - Parameter completion: Completion block when the API call has finished.
    public func provideFeedback(
        type: FeedbackType,
        appVersion: String,
        message: String,
        image: UIImage? = nil,
        name: String? = nil,
        email: String? = nil,
        completion: @escaping (Result<Void>) -> Void) {

        let feedback = Feedback(
            type: type,
            appVersion: appVersion,
            name: name,
            email: email,
            message: message,
            image: image)

        repository.provideFeedback(feedback, completion: completion)
    }
    #endif
    
    /// Sends app feedback.
    ///
    /// - Parameter type: Feedback type, can be either **bug** or **feedback**.
    /// - Parameter appVersion: App Version.
    /// - Parameter message: Content of the feedback, eg, explaining a bug.
    /// - Parameter name: Reporter's name.
    /// - Parameter email: Reporter's email.
    /// - Parameter completion: Completion block when the API call has finished.
    public func provideFeedback(
        type: FeedbackType,
        appVersion: String,
        message: String,
        name: String? = nil,
        email: String? = nil,
        completion: @escaping (Result<Void>) -> Void) {

        let feedback = Feedback(
            type: type,
            appVersion: appVersion,
            name: name,
            email: email,
            message: message)

        repository.provideFeedback(feedback, completion: completion)
    }
}
