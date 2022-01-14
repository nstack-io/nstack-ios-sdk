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
    
    /// For use only when you want to use NStacks Native UI
    /// Logs a rate reminder event, it will then check if we should prompt for a review if so, we do that via the NStack Alert Manager, then returns in a completion block the users response to the rate alert prompt
    ///
    /// - Parameter action: The Rate Reminder Action that haas been triggered
    /// - Parameter completion: Optional completion block returns users response, allwoing you to act on it, for example, request feedback when it is negative
    public func logRateReminderAction(action: RateReminderActionProtocol,
                                      completion: Completion<RateReminderResponse>? = nil) {
        repository.logRateReminderEvent(action) { [weak self] result in
            self?.ratePromptShouldShow(completion: { result in
                switch result {
                case .success(let alertModel):
                    self?.alertManager.showRateReminderCheck(alertModel) { response in
                        completion?(.success(response))
                        self?.logRateReminderResponse(reminderId: alertModel.id,
                                                      response: response)
                    }
                case .failure(let error):
                    //no alert model returned, we should not show
                    completion?(.failure(error))
                    break
                }
            })
        }
    }
    
    /// For use when you want to use our own custom UI
    /// Logs a rate reminder event, it will then check if we should prompt for a review if so,we will return an alert model for you to display any way you want
    /// Once the user responds, you should then calll logRateReminderResponse( ) with the reminder Id returned in the Alert Model
    ///
    /// - Parameter action: The Rate Reminder Action that haas been triggered
    /// - Parameter completion: Completion block returns alert model. This model contains a reminder Id required to send the feedback via  logRateReminderResponse( ) and localization strings to show in an alert if you wish
    public func logRateReminderAction(action: RateReminderActionProtocol,
                                      completion: @escaping Completion<RateReminderAlertModel>) {
        repository.logRateReminderEvent(action) { [weak self] result in
            self?.ratePromptShouldShow(completion: completion)
        }
    }
    
    /// Check if we should prompt for a review
    ///
    /// - Parameter completion: Completion block returns alert model. This model contains a reminder Id required to send the feedback via  logRateReminderResponse( ) and localization strings to show in an alert if you wish
    private func ratePromptShouldShow(completion: @escaping Completion<RateReminderAlertModel>) {
        repository.checkToShowReviewPrompt { result in
            switch result {
            case .success(let alertModel):
                completion(.success(alertModel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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

