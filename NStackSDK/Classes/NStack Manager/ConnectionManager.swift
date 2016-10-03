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

struct APIConfiguration {
    let appId: String
    let restAPIKey: String
    let isFlat: Bool

    init(appId: String = "", restAPIKey: String = "", isFlat: Bool = false) {
        self.appId = appId
        self.restAPIKey = restAPIKey
        self.isFlat = isFlat
    }
}

enum ConnectionManager {
    
    // MARK: - Setup -
    
    static let kBaseURL = "https://nstack.io/api/v1/"
    static let manager  = SessionManager(configuration: {
        let configuration = SessionManager.default.session.configuration
        configuration.timeoutIntervalForRequest = 20.0
        return configuration
    }())

    static var configuration = APIConfiguration()
    
    static var defaultHeaders: [String : String] {
        return [
            "Accept-Language" : TranslationManager.sharedInstance.acceptLanguageHeaderValueString(),
            "X-Application-id"  : configuration.appId,
            "X-Rest-Api-Key"    : configuration.restAPIKey
        ]
    }

    static let defaultUnwrapper: Parser.Unwrapper = { $0.0["data"] }
    
    // MARK: - API Calls -

    static func postAppOpen(oldVersion: String = VersionUtilities.previousAppVersion(),
                                       currentVersion: String = VersionUtilities.currentAppVersion(),
                                       completion: @escaping ((DataResponse<Any>) -> Void)) {
        var params: [String : AnyObject] = [
            "version"           : currentVersion as AnyObject,
            "guid"              : Configuration.guid() as AnyObject,
            "platform"          : "ios" as AnyObject,
            "last_updated"      : lastUpdatedString() as AnyObject,
            "old_version"       : oldVersion as AnyObject
        ]
        if let overriddenVersion = VersionUtilities.versionOverride {
            params["version"] = overriddenVersion as AnyObject
        }
        
        ConnectionManager.manager.request(kBaseURL + "open", method: .post, parameters: params, headers: defaultHeaders).responseJSON(completionHandler: completion)
    }
    
    static func fetchTranslations(_ completion: @escaping ((DataResponse<TranslationsResponse>) -> Void)) {
        let params:[String : AnyObject] = [
            "version"           : 1.0 as AnyObject,
            "guid"              : Configuration.guid() as AnyObject,
            "last_updated"      : lastUpdatedString() as AnyObject,
        ]

        let slugs = "translate/mobile/keys" + (configuration.isFlat ? "?flat=true" : "")
        ConnectionManager.manager.request(kBaseURL + slugs, method: .get , parameters:params, headers: defaultHeaders).responseSerializable(completion)
    }

    static func fetchCurrentLanguage(_ completion:  @escaping((DataResponse<Language>) -> Void)) {
        let params:[String : AnyObject] = [
            "version"           : 1.0 as AnyObject,
            "guid"              : Configuration.guid() as AnyObject,
            "last_updated"      : lastUpdatedString() as AnyObject,
        ]

        let slugs = "translate/mobile/languages/best_fit?show_inactive_languages=true"
        ConnectionManager.manager.request(kBaseURL + slugs, method: .get, parameters:params, headers: defaultHeaders).responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    static func fetchAvailableLanguages(_ completion:  @escaping ((DataResponse<[Language]>) -> Void)) {
        let params:[String : AnyObject] = [
            "version"           : 1.0 as AnyObject,
            "guid"              : Configuration.guid() as AnyObject,
        ]
        
        ConnectionManager.manager.request(kBaseURL + "translate/mobile/languages", method: .get, parameters:params, headers: defaultHeaders).responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    static func fetchUpdates(oldVersion: String = VersionUtilities.previousAppVersion(),
                                        currentVersion: String = VersionUtilities.currentAppVersion(),
                                        completion: @escaping ((DataResponse<Update>) -> Void)) {
        let params:[String : AnyObject] = [
            "current_version"   : currentVersion as AnyObject,
            "guid"              : Configuration.guid() as AnyObject,
            "platform"          : "ios" as AnyObject,
            "old_version"       : oldVersion as AnyObject,
        ]
        
        ConnectionManager.manager.request(kBaseURL + "notify/updates", method: .get, parameters:params, headers: defaultHeaders).responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
    
    static func markNewerVersionAsSeen(_ id: Int, appStoreButtonPressed:Bool) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid() as AnyObject,
            "update_id"         : id as AnyObject,
            "answer"            : (appStoreButtonPressed ? "yes" : "no") as AnyObject,
            "type"              : "newer_version" as AnyObject
        ]
        
        ConnectionManager.manager.request(kBaseURL + "notify/updates/views", method: .post, parameters:params, headers: defaultHeaders)
    }
    
    static func markWhatsNewAsSeen(_ id: Int) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid() as AnyObject,
            "update_id"         : id as AnyObject,
            "type"              : "new_in_version" as AnyObject,
            "answer"            : "no" as AnyObject,
        ]
        
        ConnectionManager.manager.request(kBaseURL + "notify/updates/views", method: .post, parameters:params, headers: defaultHeaders)
    }
    
    static func markMessageAsRead(_ id: String) {
        let params: [String : AnyObject] = [
            "guid"              : Configuration.guid() as AnyObject,
            "message_id"        : id as AnyObject
        ]
        
        ConnectionManager.manager.request(kBaseURL + "notify/messages/views", method: .post, parameters:params, headers: defaultHeaders)
    }
    
    static func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {
        let params: [String : AnyObject] = [
            "guid"              : Configuration.guid() as AnyObject,
            "platform"          : "ios" as AnyObject,
            "answer"            : answer.rawValue as AnyObject
        ]
        
        ConnectionManager.manager.request(kBaseURL + "notify/rate_reminder/views", method: .post, parameters:params, headers: defaultHeaders)
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

        if let prevAcceptLangString = cache.object(forKey: NStackConstants.prevAcceptedLanguageKey) as? String
            , prevAcceptLangString != currentAcceptLangString {

            cache.setObject(currentAcceptLangString, forKey: NStackConstants.prevAcceptedLanguageKey)
            self.setLastUpdatedToDistantPast()
        }

        let date = cache.object(forKey: NStackConstants.lastUpdatedDateKey) as? Date ?? Date.distantPast
        return date.stringRepresentation()
    }
    
    static func setLastUpdatedToNow() {
        NStack.persistentStore.setObject(Date(), forKey: NStackConstants.lastUpdatedDateKey)
    }
    
    static func setLastUpdatedToDistantPast() {
        NStack.persistentStore.setObject(Date.distantPast, forKey: NStackConstants.lastUpdatedDateKey)
    }
}
