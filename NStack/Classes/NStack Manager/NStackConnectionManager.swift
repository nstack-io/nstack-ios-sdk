//
//  NStackConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Alamofire
import Serializable
import Cashier

struct NStackConnectionManager {
    
    //MARK: - Setup
    
    internal static let kBaseURL = "https://nstack.io/api/v1/"
    
    static let manager:Manager = Manager(configuration: NStackConnectionManager.configuration())
    
    static func configuration() -> NSURLSessionConfiguration {
        let configuration = Manager.sharedInstance.session.configuration
        configuration.timeoutIntervalForRequest = 20.0
        return configuration
    }
    
    static func headers() -> [String : String] {
        return [
            "Accept-Language": TranslationManager.sharedInstance.acceptLanguageHeaderValueString(),
            "X-Application-id"  : NStack.sharedInstance.configuration.appId,
            "X-Rest-Api-Key"    : NStack.sharedInstance.configuration.restAPIKey
        ]
    }
    
    //MARK: - API Calls

    static func doAppOpenCall(oldVersion oldVersion: String, currentVersion: String, completion: (Response<AnyObject, NSError> -> Void)) {
        let params:[String : AnyObject] = [
            "version"           : currentVersion,
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "last_updated"      : lastUpdatedString(),
            "old_version"       : NStackVersionUtils.previousAppVersion()
        ]
        
        var slugs = "open"
        if NStack.sharedInstance.configuration.flat {
            slugs += "?flat=true"
        }

        NStackConnectionManager.manager.request(.POST, kBaseURL + slugs, parameters:params, headers: headers()).responseJSON(completionHandler: completion)
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
        NStackConnectionManager.manager.request(.GET, kBaseURL + slugs, parameters:params, headers: headers()).responseJSON(completionHandler: completion)
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
        NStackConnectionManager.manager.request(.GET, kBaseURL + slugs, parameters:params, headers: headers()).responseSerializable(completion, unwrapper: { $0.0["data"] })
    }
    
    static func fetchAvailableLanguages(completion: (Response<[Language], NSError> -> Void)) {
        let params:[String : AnyObject] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
        ]
        
        NStackConnectionManager.manager.request(.GET, kBaseURL + "translate/mobile/languages", parameters:params, headers: headers()).responseSerializable(completion, unwrapper: { $0.0["data"] })
    }
    
    static func fetchUpdates(completion: (Response<Update, NSError> -> Void)) {
        let params:[String : AnyObject] = [
            "current_version"   : NStackVersionUtils.currentAppVersion(),
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "old_version"      : NStackVersionUtils.previousAppVersion(),
        ]
        
        NStackConnectionManager.manager.request(.GET, kBaseURL + "notify/updates", parameters:params, headers: headers()).responseSerializable(completion, unwrapper: { $0.0["data"] })
    }
    
    static func markNewerVersionAsSeen(id: Int, appStoreButtonPressed:Bool) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "update_id"         : id,
            "answer"            : appStoreButtonPressed ? "yes" : "no",
            "type"              : "newer_version"
        ]
        
        NStackConnectionManager.manager.request(.POST, kBaseURL + "notify/updates/views", parameters:params, headers: headers())
    }
    
    static func markWhatsNewAsSeen(id: Int) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "update_id"         : id,
            "type"              : "new_in_version",
            "answer"            : "no",
        ]
        
        NStackConnectionManager.manager.request(.POST, kBaseURL + "notify/updates/views", parameters:params, headers: headers())
    }
    
    static func markMessageAsRead(id: String) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "message_id"        : id
        ]
        
        NStackConnectionManager.manager.request(.POST, kBaseURL + "notify/messages/views", parameters:params, headers: headers())
    }
    
    static func markRateReminderAsSeen(answer:AlertManager.RateReminderResult) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "answer"            : answer.rawValue
        ]
        
        NStackConnectionManager.manager.request(.POST, kBaseURL + "notify/rate_reminder/views", parameters:params, headers: headers())
    }
}

extension NStackConnectionManager {
    //MARK: - Utility functions
    
    internal static func lastUpdatedString() -> String {
        
        let currentAcceptLangString = TranslationManager.sharedInstance.acceptLanguageHeaderValueString()
        if let prevAcceptLangString:String? = NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID).objectForKey(NStackConstants.prevAcceptedLanguageKey) as? String where prevAcceptLangString != currentAcceptLangString {
            NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID).setObject(currentAcceptLangString, forKey: NStackConstants.prevAcceptedLanguageKey)
            self.setLastUpdatedToDistantPast()
        }
        
        let date:NSDate? = NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID).objectForKey(NStackConstants.lastUpdatedDateKey) as? NSDate
        
        let dateObject = date ?? NSDate.distantPast()
        
        return dateObject.stringRepresentation() ?? ""
    }
    
    internal static func setLastUpdatedToNow() {
        NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID).setObject(NSDate(), forKey: NStackConstants.lastUpdatedDateKey)
    }
    
    internal static func setLastUpdatedToDistantPast() {
        NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID).setObject(NSDate.distantPast(), forKey: NStackConstants.lastUpdatedDateKey)
    }
}
