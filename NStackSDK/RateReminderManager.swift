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

public enum RateReminderResponse: String {
    case positive
    case negative
    case skip
}

public class RateReminderManager {
    // MARK: - Properties
    internal var repository: RateReminderRepository
    private var alertManager: AlertManager

    // MARK: - Init
    public init(repository: RateReminderRepository,
                alertManager: AlertManager) {
        self.repository = repository
        self.alertManager = alertManager
    }
    
    /// Logs a rate reminder event
    ///
    /// - Parameter action: The Rate Reminder Action that haas been triggered
    /// - Parameter completion: Optional ompletion block returns when the action has been logged
    public func logRateReminderAction(action: RateReminderActionProtocol,
                                      completion: Completion<RateReminderLogEventResponse>?) {
        repository.logRateReminderEvent(action, completion: completion ?? { _ in })
    }
    
    
    /// Check if we should prompt for a review, returns an AlertModel in completion if so
    ///
    /// - Parameter completion: Completion block success returns alert model. This model contains a reminder Id required to send the feedback via  logRateReminderResponse( ) and localization strings to show in an alert if you wish
    public func ratePromptShouldShow(completion: @escaping Completion<RateReminderAlertModel>) {
        repository.checkToShowReviewPrompt { result in
            switch result {
            case .success(let alertModel):
                completion(.success(alertModel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func showNativeRateReminerAlert(alertModel: RateReminderAlertModel,
                                           responseCompletion: @escaping ((RateReminderResponse) -> Void)) {
        alertManager.showRateReminderCheck(alertModel, completion: responseCompletion)
    }
    
    /// Logs a response to a rate reminder prompt
    ///
    /// - Parameter reminderId: This shuld be the id from the RateReminderAlertModel returned when logging a rate reminder action
    /// - Parameter response: The response the user has selected (positive/negative/skip)
    public func logRateReminderResponse(reminderId: Int,
                                        response: RateReminderResponse) {
        switch response {
        case .positive:
            alertManager.requestAppStoreReview()
        case .negative, .skip:
            //do nothing for negative/skip
            break
        }
        repository.logReviewPromptResponse(reminderId: "\(reminderId)", response: response)
    }
}

