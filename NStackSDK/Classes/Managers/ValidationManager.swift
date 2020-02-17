//
//  ValidationManager.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 28/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

public class ValidationManager {
    // MARK: - Properites
    internal var repository: ValidationRepository
    // MARK: - Init
    init(repository: ValidationRepository) {
        self.repository = repository
    }
    /// Validate an email.
    ///
    /// - Parameters
    ///     email: A string to be validated as a email
    ///     completion: Completion block when the API call has finished.
    public func validateEmail(_ email: String, completion: @escaping ((_ valid: Bool, _ error: Error?) -> Void)) {
        repository.validateEmail(email) { (result) in
            switch result {
            case .success(let data):
                completion(data.ok, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
}
