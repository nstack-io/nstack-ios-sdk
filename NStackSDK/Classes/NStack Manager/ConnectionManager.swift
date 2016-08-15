//
//  ConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Alamofire
import Serializable
import Cashier

struct ConnectionManager {
    
    // MARK: - Setup -
    
    static let kBaseURL = "https://nstack.io/api/v1/"
    static let manager = Manager(configuration: ConnectionManager.configuration())
    
    static func configuration() -> NSURLSessionConfiguration {
        let configuration = Manager.sharedInstance.session.configuration
        configuration.timeoutIntervalForRequest = 20.0
        return configuration
    }
    
    static var defaultHeaders: [String : String] {
        return [
            "Accept-Language": TranslationManager.sharedInstance.acceptLanguageHeaderValueString(),
            "X-Application-id"  : NStack.sharedInstance.configuration.appId,
            "X-Rest-Api-Key"    : NStack.sharedInstance.configuration.restAPIKey
        ]
    }

    static let defaultUnwrapper: Parser.Unwrapper = { $0.0["data"] }
    
    // MARK: - API Calls -

    static func postAppOpen(oldVersion oldVersion: String = VersionUtilities.previousAppVersion(),
                                       currentVersion: String = VersionUtilities.currentAppVersion(),
                                       completion: (Response<AnyObject, NSError> -> Void)) {

        let params: [String : AnyObject] = [
            "version"           : currentVersion,
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "last_updated"      : lastUpdatedString(),
            "old_version"       : oldVersion
        ]
        
        let slugs = "open" + (NStack.sharedInstance.configuration.flat ? "?flat=true" : "")
        ConnectionManager.manager.request(.POST, kBaseURL + slugs, parameters:params, headers: defaultHeaders).responseJSON(completionHandler: completion)
    }
    
    static func fetchTranslations(completion: (Response<AnyObject, NSError> -> Void)) {
        let params:[String : AnyObject] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
            "last_updated"      : lastUpdatedString(),
        ]
        var slugs = "translate/mobile/keys"
        if NStack.sharedInstance.configuration.flat {
            slugs += "?flat=true"
        }
        ConnectionManager.manager.request(.GET, kBaseURL + slugs, parameters:params, headers: defaultHeaders).responseJSON(completionHandler: completion)
    }

    static func fetchCurrentLanguage(completion: (Response<Language, NSError> -> Void)) {
        let params:[String : AnyObject] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
            "last_updated"      : lastUpdatedString(),
        ]
        var slugs = "translate/mobile/languages/best_fit?show_inactive_languages=true"
        if NStack.sharedInstance.configuration.flat {
            slugs += "?flat=true"
        }
        ConnectionManager.manager.request(.GET, kBaseURL + slugs, parameters:params, headers: defaultHeaders).responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    static func fetchAvailableLanguages(completion: (Response<[Language], NSError> -> Void)) {
        let params:[String : AnyObject] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
        ]
        
        ConnectionManager.manager.request(.GET, kBaseURL + "translate/mobile/languages", parameters:params, headers: defaultHeaders).responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    static func fetchUpdates(completion: (Response<Update, NSError> -> Void)) {
        let params:[String : AnyObject] = [
            "current_version"   : VersionUtilities.currentAppVersion(),
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "old_version"      : VersionUtilities.previousAppVersion(),
        ]
        
        ConnectionManager.manager.request(.GET, kBaseURL + "notify/updates", parameters:params, headers: defaultHeaders).responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    static func markNewerVersionAsSeen(id: Int, appStoreButtonPressed:Bool) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "update_id"         : id,
            "answer"            : appStoreButtonPressed ? "yes" : "no",
            "type"              : "newer_version"
        ]
        
        ConnectionManager.manager.request(.POST, kBaseURL + "notify/updates/views", parameters:params, headers: defaultHeaders)
    }
    
    static func markWhatsNewAsSeen(id: Int) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "update_id"         : id,
            "type"              : "new_in_version",
            "answer"            : "no",
        ]
        
        ConnectionManager.manager.request(.POST, kBaseURL + "notify/updates/views", parameters:params, headers: defaultHeaders)
    }
    
    static func markMessageAsRead(id: String) {
        let params: [String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "message_id"        : id
        ]
        
        ConnectionManager.manager.request(.POST, kBaseURL + "notify/messages/views", parameters:params, headers: defaultHeaders)
    }
    
    static func markRateReminderAsSeen(answer: AlertManager.RateReminderResult) {
        let params: [String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "answer"            : answer.rawValue
        ]
        
        ConnectionManager.manager.request(.POST, kBaseURL + "notify/rate_reminder/views", parameters:params, headers: defaultHeaders)
    }
	
	//MARK: Geographic
	
	static func fetchCountries(completion: Response<[Country], NSError> -> Void) {
		NStackConnectionManager.manager.request(.GET, kBaseURL + "geographic/countries", headers: headers()).responseSerializable(completion, unwrapper: { $0.0["data"] })
	}
}

// MARK: - Utility Functions -

extension ConnectionManager {
    
    static func lastUpdatedString() -> String {
        let cache = NStack.persistentStore
        let currentAcceptLangString = TranslationManager.sharedInstance.acceptLanguageHeaderValueString()

        if let prevAcceptLangString = cache.objectForKey(NStackConstants.prevAcceptedLanguageKey) as? String
            where prevAcceptLangString != currentAcceptLangString {

            cache.setObject(currentAcceptLangString, forKey: NStackConstants.prevAcceptedLanguageKey)
            self.setLastUpdatedToDistantPast()
        }

        let date = cache.objectForKey(NStackConstants.lastUpdatedDateKey) as? NSDate ?? NSDate.distantPast()
        return date.stringRepresentation() ?? ""
    }
    
    static func setLastUpdatedToNow() {
        NStack.persistentStore.setObject(NSDate(), forKey: NStackConstants.lastUpdatedDateKey)
    }
    
    static func setLastUpdatedToDistantPast() {
        NStack.persistentStore.setObject(NSDate.distantPast(), forKey: NStackConstants.lastUpdatedDateKey)
    }
}
