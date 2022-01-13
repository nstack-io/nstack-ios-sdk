//
//  RateReminderManager.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 11/01/2022.
//  Copyright © 2022 Nodes ApS. All rights reserved.
//

//typesafe protocol used for RateReminderAction
public protocol RateReminderActionProtocol {
    var actionString: String { get }
}

#if canImport(UIKit)

import UIKit

public class RateReminderManager {
    // MARK: - Properties
    internal var repository: RateReminderRepository

    // MARK: - Init
    public init(repository: RateReminderRepository) {
        self.repository = repository
    }
}

#else
public class RateReminderManager {
    // MARK: - Properties
    internal var repository: RateReminderRepository

    // MARK: - Init
    public init(repository: RateReminderRepository) {
        self.repository = repository
    }
}
#endif
