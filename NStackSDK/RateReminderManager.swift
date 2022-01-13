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
    
    /// Logs a rate reminder event, it will then check if we should prompt for a review if so, we do that via the Alert Manager
    public func logRateReminderAction(action: RateReminderActionProtocol) {
        repository.logRateReminderEvent(action) { [weak self] result in
            self?.promptRateReviewIfRequired()
        }
    }
    
    /// Logs a rate reminder event, it will then check if we should prompt for a review if so, we do that via the Alert Manager
    public func promptRateReviewIfRequired() {
        repository.checkToShowReviewPrompt { [weak self] result in
            switch result {
            case .success(let alertModel):
                self?.alertManager.showRateReminderCheck(alertModel) { response in
                    self?.logRateReminderResponse(reminderId: alertModel.id,
                                                  response: response)
                }
            case .failure(let error):
                print(error.localizedDescription)
                return
            }
        }
    }
    
    /// Logs a response to a rate reminder prompt
    private func logRateReminderResponse(reminderId: Int,
                                         response: RateReminderResponse) {
        switch response {
        case .positive:
            alertManager.requestAppStoreReview()
        case .negative:
            //TODO
            //show feedback alert and post it to NStack API
            break
        case .skip:
            break
        }
        repository.logReviewPromptResponse(reminderId: "\(reminderId)", response: response) { _ in 
            //do nothhing with this afaik?
        }
    }
}

